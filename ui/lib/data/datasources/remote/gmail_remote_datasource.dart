import 'dart:convert';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import '../../../services/google_drive_service.dart';

/// DTO representing an unhandled bank email fetched from Gmail.
class GmailRawMessage {
  final String id;
  final String threadId;
  final String subject;
  final String sender;
  final DateTime date;
  final String body;
  final List<String> labelIds;

  const GmailRawMessage({
    required this.id,
    required this.threadId,
    required this.subject,
    required this.sender,
    required this.date,
    required this.body,
    this.labelIds = const [],
  });
}

/// Remote data source contract for querying and modifying bank emails via Gmail API.
abstract class GmailRemoteDataSource {
  /// Fetches unhandled bank email summaries matching configured senders and time window.
  Future<List<GmailRawMessage>> fetchUnprocessedBankMessages({
    required Map<String, String> authHeaders,
    List<String> bankSenders,
    int maxResults = 25,
  });

  /// Attaches the 'FinanceTracker/Processed' label to the given message ID.
  Future<void> markMessageAsProcessed({
    required String messageId,
    required Map<String, String> authHeaders,
  });

  /// Attaches the 'FinanceTracker/Ignored' label to non-transactional messages.
  Future<void> markMessageAsIgnored({
    required String messageId,
    required Map<String, String> authHeaders,
  });
}

/// Implementation of [GmailRemoteDataSource] using [gmail.GmailApi].
class GmailRemoteDataSourceImpl implements GmailRemoteDataSource {
  static const String processedLabelName = 'FinanceTracker/Processed';
  static const String ignoredLabelName = 'FinanceTracker/Ignored';

  static const List<String> defaultBankSenders = [
    'alertasynotificaciones@bancolombia.com.co',
    'notificaciones@rappicard.co',
    'alertas@notificacionesbancolombia.com',
  ];

  final http.Client? _httpClient;

  GmailRemoteDataSourceImpl({http.Client? httpClient}) : _httpClient = httpClient;

  gmail.GmailApi _getGmailApi(Map<String, String> authHeaders) {
    final client = _httpClient ?? GoogleAuthClient(authHeaders);
    return gmail.GmailApi(client);
  }

  @override
  Future<List<GmailRawMessage>> fetchUnprocessedBankMessages({
    required Map<String, String> authHeaders,
    List<String> bankSenders = defaultBankSenders,
    int maxResults = 25,
  }) async {
    final gmailApi = _getGmailApi(authHeaders);

    final senders = (bankSenders.isNotEmpty ? bankSenders : defaultBankSenders)
        .map((s) => 'from:$s')
        .join(' OR ');

    // Query messages from the last 2 days
    final query = '($senders) newer_than:2d';

    final gmail.ListMessagesResponse response =
        await gmailApi.users.messages.list('me', q: query, maxResults: maxResults);

    final List<gmail.Message> messageRefs = response.messages ?? [];
    if (messageRefs.isEmpty) return [];

    final List<GmailRawMessage> rawMessages = [];

    for (final ref in messageRefs) {
      if (ref.id == null) continue;

      try {
        final gmail.Message fullMsg =
            await gmailApi.users.messages.get('me', ref.id!, format: 'full');

        final String subject = _extractHeader(fullMsg, 'Subject');
        final String sender = _extractHeader(fullMsg, 'From');
        final DateTime date = _extractDate(fullMsg);
        final String body = _extractBody(fullMsg);

        rawMessages.add(
          GmailRawMessage(
            id: fullMsg.id!,
            threadId: fullMsg.threadId ?? fullMsg.id!,
            subject: subject,
            sender: sender,
            date: date,
            body: body,
            labelIds: fullMsg.labelIds ?? [],
          ),
        );
      } catch (_) {
        // Skip individual unparseable message
      }
    }

    return rawMessages;
  }

  @override
  Future<void> markMessageAsProcessed({
    required String messageId,
    required Map<String, String> authHeaders,
  }) async {
    await _applyLabel(messageId, processedLabelName, authHeaders);
  }

  @override
  Future<void> markMessageAsIgnored({
    required String messageId,
    required Map<String, String> authHeaders,
  }) async {
    await _applyLabel(messageId, ignoredLabelName, authHeaders);
  }

  Future<void> _applyLabel(
    String messageId,
    String labelName,
    Map<String, String> authHeaders,
  ) async {
    final gmailApi = _getGmailApi(authHeaders);
    final String labelId = await _getOrCreateLabelId(gmailApi, labelName);

    final modifyRequest = gmail.ModifyMessageRequest(addLabelIds: [labelId]);
    await gmailApi.users.messages.modify(modifyRequest, 'me', messageId);
  }

  Future<String> _getOrCreateLabelId(gmail.GmailApi gmailApi, String labelName) async {
    final gmail.ListLabelsResponse labelsList =
        await gmailApi.users.labels.list('me');

    for (final label in labelsList.labels ?? []) {
      if (label.name == labelName && label.id != null) {
        return label.id!;
      }
    }

    final newLabel = await gmailApi.users.labels.create(
      gmail.Label(
        name: labelName,
        labelListVisibility: 'labelShow',
        messageListVisibility: 'show',
      ),
      'me',
    );

    return newLabel.id!;
  }

  String _extractHeader(gmail.Message message, String headerName) {
    final headers = message.payload?.headers;
    if (headers == null) return '';
    for (final h in headers) {
      if (h.name?.toLowerCase() == headerName.toLowerCase()) {
        return h.value ?? '';
      }
    }
    return '';
  }

  DateTime _extractDate(gmail.Message message) {
    final internalDate = message.internalDate;
    if (internalDate != null) {
      final ms = int.tryParse(internalDate);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    final dateHeader = _extractHeader(message, 'Date');
    if (dateHeader.isNotEmpty) {
      final parsed = DateTime.tryParse(dateHeader);
      if (parsed != null) return parsed;
    }

    return DateTime.now();
  }

  String _extractBody(gmail.Message message) {
    final snippet = message.snippet ?? '';
    final payload = message.payload;
    if (payload == null) return snippet;

    String? decoded = _decodePart(payload);
    if (decoded != null && decoded.isNotEmpty) {
      return decoded;
    }

    if (payload.parts != null) {
      for (final part in payload.parts!) {
        decoded = _decodePart(part);
        if (decoded != null && decoded.isNotEmpty) {
          return decoded;
        }
      }
    }

    return snippet;
  }

  String? _decodePart(gmail.MessagePart part) {
    final bodyData = part.body?.data;
    if (bodyData == null || bodyData.isEmpty) return null;

    try {
      final normalized = base64.normalize(bodyData.replaceAll('-', '+').replaceAll('_', '/'));
      final bytes = base64.decode(normalized);
      final rawText = utf8.decode(bytes, allowMalformed: true);
      return _sanitizeText(rawText);
    } catch (_) {
      return null;
    }
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'https?:\/\/[^\s]+'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}
