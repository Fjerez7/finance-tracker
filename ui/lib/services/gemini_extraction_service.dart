import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/inbox_transaction_model.dart';

/// Contract for AI-powered structured transaction extraction from raw email content.
abstract class GeminiExtractionService {
  /// Extracts a typed [InboxTransactionModel] from email text using Gemini Flash.
  Future<InboxTransactionModel?> extractTransaction({
    required String emailBody,
    required String emailSubject,
    required String sender,
    required DateTime emailDate,
    required String messageId,
    required String apiKey,
  });
}

/// Implementation of [GeminiExtractionService] using Gemini 3.6 / 2.5 Flash REST endpoint.
class GeminiExtractionServiceImpl implements GeminiExtractionService {
  final http.Client _client;
  final String _modelName;

  GeminiExtractionServiceImpl({
    http.Client? client,
    String modelName = 'gemini-3.6-flash',
  })  : _client = client ?? http.Client(),
        _modelName = modelName;

  static const String systemInstruction = '''
You are an expert financial parsing engine. Extract structured transaction details from bank notification emails.
Rules:
1. Set "is_transaction" to true only for confirmed purchases, debits, payments, withdrawals, transfers, or deposits.
2. Security alerts (OTP, login attempts), marketing promotions, or billing statements without immediate charges MUST have "is_transaction": false.
3. Clean merchant/sender names (e.g. "COMPRA POS 123 *UBER" -> "Uber", "SUPERMERCADOS EXITO" -> "Exito", "Transferencia de ALBA MANRIQUE" -> "ALBA MANRIQUE").
4. "type": MUST be "income" for incoming deposits, received transfers ('recibiste una transferencia', 'abono', 'transferencia de', 'consignación'), salary/payroll, cashback, or refunds. MUST be "expense" for purchases ('compra con tarjeta'), bill payments, and outgoing sent transfers ('transferiste a'). "transfer" only for transfers between user's own accounts.
5. "category_suggestion" MUST match one of: Food & Dining, Groceries, Transportation, Housing & Rent, Utilities & Services, Entertainment, Health & Medical, Personal Care, Shopping, Subscriptions & Bills, Other Expenses, Salary & Payroll, Freelance & Business, Investments & Returns, Other Income.
6. "amount_cents" MUST be calculated as Math.round(amount * 100).
7. "transaction_date" MUST use Colombia timezone offset "-05:00" (e.g. "2026-09-13T12:37:00-05:00"). Never append "Z" when extracting Colombian local time.
''';

  static const Map<String, dynamic> jsonSchema = {
    'type': 'OBJECT',
    'properties': {
      'is_transaction': {
        'type': 'BOOLEAN',
        'description': 'True if the email denotes a confirmed financial transaction.',
      },
      'bank_name': {
        'type': 'STRING',
        'description': 'Name of the issuing bank (e.g., Bancolombia, Rappi, Nu, Davivienda).',
      },
      'account_type': {
        'type': 'STRING',
        'enum': ['credit_card', 'debit_card', 'savings', 'checking', 'cash', 'other'],
        'description': 'Payment instrument or account type.',
      },
      'account_mask': {
        'type': 'STRING',
        'description': 'Account mask digits (e.g., *3304, *4892).',
      },
      'merchant': {
        'type': 'STRING',
        'description': 'Cleaned merchant, business, sender, or recipient name.',
      },
      'amount': {
        'type': 'NUMBER',
        'description': 'Exact transaction amount in major currency units.',
      },
      'amount_cents': {
        'type': 'INTEGER',
        'description': 'Total amount converted to integer cents.',
      },
      'currency': {
        'type': 'STRING',
        'description': 'ISO currency code (e.g., COP, USD).',
      },
      'type': {
        'type': 'STRING',
        'enum': ['expense', 'income', 'transfer'],
        'description': 'MUST be "income" for received transfers, deposits, salary; "expense" for purchases and sent transfers.',
      },
      'category_suggestion': {
        'type': 'STRING',
        'description': 'Suggested category conforming to the application default category catalogue.',
      },
      'transaction_date': {
        'type': 'STRING',
        'description': 'ISO 8601 formatted date with Colombia offset -05:00.',
      },
      'reference_number': {
        'type': 'STRING',
        'description': 'Authorization or tracking number if available.',
      },
    },
    'required': ['is_transaction'],
  };

  @override
  Future<InboxTransactionModel?> extractTransaction({
    required String emailBody,
    required String emailSubject,
    required String sender,
    required DateTime emailDate,
    required String messageId,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$apiKey',
    );

    final cleanBody = emailBody.length > 2500 ? emailBody.substring(0, 2500) : emailBody;

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  'Sender: $sender\nSubject: $emailSubject\nEmail Date: ${emailDate.toIso8601String()}\n\nEmail Content:\n$cleanBody',
            }
          ],
        }
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction}
        ],
      },
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': jsonSchema,
        'temperature': 0.1,
      },
    };

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> responseJson = json.decode(response.body);
    final candidates = responseJson['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final parts = candidates.first['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    final String? textContent = parts.first['text'];
    if (textContent == null || textContent.trim().isEmpty) return null;

    final Map<String, dynamic> parsedJson = json.decode(textContent);
    if (parsedJson['is_transaction'] != true) return null;

    parsedJson['id'] = messageId;
    parsedJson['status'] = 'PENDING';
    parsedJson['created_at'] = DateTime.now().toUtc().toIso8601String();

    return InboxTransactionModel.fromMap(messageId, parsedJson);
  }
}
