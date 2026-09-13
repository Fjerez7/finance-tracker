import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finance_tracker/services/gemini_extraction_service.dart';

void main() {
  group('GeminiExtractionServiceImpl Tests', () {
    final emailDate = DateTime.parse('2026-09-13T12:37:00.000Z');

    test('extractTransaction parses valid JSON response into InboxTransactionModel', () async {
      final mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'is_transaction': true,
                    'bank_name': 'Bancolombia',
                    'account_type': 'credit_card',
                    'account_mask': '*4892',
                    'merchant': 'Uber',
                    'amount': 25000.0,
                    'amount_cents': 2500000,
                    'currency': 'COP',
                    'type': 'expense',
                    'category_suggestion': 'Transportation',
                    'transaction_date': '2026-09-13T12:37:00-05:00',
                    'reference_number': 'AUT-4892',
                  }),
                }
              ],
            },
          }
        ],
      };

      final client = MockClient((request) async {
        expect(request.url.queryParameters['key'], equals('fake_api_key'));
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = GeminiExtractionServiceImpl(
        client: client,
        modelName: 'gemini-3.6-flash',
      );

      final result = await service.extractTransaction(
        emailBody: 'Compra con tarjeta *4892 en Uber por \$25.000',
        emailSubject: 'Compra Bancolombia',
        sender: 'alertasynotificaciones@bancolombia.com.co',
        emailDate: emailDate,
        messageId: 'msg_123',
        apiKey: 'fake_api_key',
      );

      expect(result, isNotNull);
      expect(result!.id, equals('msg_123'));
      expect(result.merchant, equals('Uber'));
      expect(result.amountCents, equals(2500000));
      expect(result.currency, equals('COP'));
      expect(result.accountMask, equals('*4892'));
      expect(result.categorySuggestion, equals('Transportation'));
    });

    test('extractTransaction returns null when is_transaction is false', () async {
      final mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'is_transaction': false,
                  }),
                }
              ],
            },
          }
        ],
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = GeminiExtractionServiceImpl(client: client);

      final result = await service.extractTransaction(
        emailBody: 'Tu clave dinámica es 123456',
        emailSubject: 'Seguridad Bancolombia',
        sender: 'alertasynotificaciones@bancolombia.com.co',
        emailDate: emailDate,
        messageId: 'msg_otp',
        apiKey: 'fake_api_key',
      );

      expect(result, isNull);
    });

    test('extractTransaction throws Exception when API returns non-200', () async {
      final client = MockClient((request) async {
        return http.Response('Invalid API key', 403);
      });

      final service = GeminiExtractionServiceImpl(client: client);

      expect(
        () => service.extractTransaction(
          emailBody: 'Some text',
          emailSubject: 'Subject',
          sender: 'bank@example.com',
          emailDate: emailDate,
          messageId: 'msg_err',
          apiKey: 'invalid_key',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
