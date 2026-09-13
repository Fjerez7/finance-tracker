import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finance_tracker/data/datasources/remote/gmail_remote_datasource.dart';

void main() {
  group('GmailRemoteDataSourceImpl Tests', () {
    test('fetchUnprocessedBankMessages parses messages and decodes base64 payload', () async {
      final client = MockClient((request) async {
        final path = request.url.path;

        final jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

        if (path.endsWith('/messages')) {
          // list messages endpoint
          return http.Response(
            jsonEncode({
              'messages': [
                {'id': 'msg_001', 'threadId': 'th_001'},
              ],
            }),
            200,
            headers: jsonHeaders,
          );
        } else if (path.endsWith('/messages/msg_001')) {
          // get message endpoint
          final bodyText = 'Bancolombia le informa compra con tarjeta *4892 por \$50.000';
          final base64Body = base64Url.encode(utf8.encode(bodyText)).replaceAll('=', '');

          return http.Response(
            jsonEncode({
              'id': 'msg_001',
              'threadId': 'th_001',
              'internalDate': '1726231020000',
              'labelIds': ['INBOX', 'UNREAD'],
              'payload': {
                'headers': [
                  {'name': 'Subject', 'value': 'Notificación de Transacción'},
                  {'name': 'From', 'value': 'alertasynotificaciones@bancolombia.com.co'},
                ],
                'body': {'data': base64Body},
              },
            }),
            200,
            headers: jsonHeaders,
          );
        }

        return http.Response('Not Found', 404);
      });

      final dataSource = GmailRemoteDataSourceImpl(httpClient: client);
      final messages = await dataSource.fetchUnprocessedBankMessages(
        authHeaders: {'Authorization': 'Bearer token'},
      );

      expect(messages.length, equals(1));
      expect(messages.first.id, equals('msg_001'));
      expect(messages.first.subject, equals('Notificación de Transacción'));
      expect(messages.first.sender, equals('alertasynotificaciones@bancolombia.com.co'));
      expect(messages.first.body, contains('Bancolombia le informa compra con tarjeta *4892'));
    });

    test('markMessageAsProcessed modifies labels via Gmail API', () async {
      bool modifyCalled = false;

      final client = MockClient((request) async {
        final path = request.url.path;
        final jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

        if (path.endsWith('/labels')) {
          return http.Response(
            jsonEncode({
              'labels': [
                {'id': 'lbl_processed', 'name': GmailRemoteDataSourceImpl.processedLabelName},
              ],
            }),
            200,
            headers: jsonHeaders,
          );
        } else if (path.endsWith('/messages/msg_001/modify')) {
          modifyCalled = true;
          return http.Response(
            jsonEncode({'id': 'msg_001', 'labelIds': ['lbl_processed']}),
            200,
            headers: jsonHeaders,
          );
        }

        return http.Response('OK', 200, headers: jsonHeaders);
      });

      final dataSource = GmailRemoteDataSourceImpl(httpClient: client);
      await dataSource.markMessageAsProcessed(
        messageId: 'msg_001',
        authHeaders: {'Authorization': 'Bearer token'},
      );

      expect(modifyCalled, isTrue);
    });
  });
}
