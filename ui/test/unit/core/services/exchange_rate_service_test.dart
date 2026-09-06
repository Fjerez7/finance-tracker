import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finance_tracker/core/services/exchange_rate_service.dart';
import 'package:finance_tracker/domain/entities/exchange_rate_result.dart';

void main() {
  group('ExchangeRateService Unit Tests', () {
    test('successfully fetches and parses USD rates from open.er-api.com', () async {
      final mockResponse = jsonEncode({
        'result': 'success',
        'provider': 'https://www.exchangerate-api.com',
        'base_code': 'USD',
        'time_last_update_unix': 1788652951,
        'time_last_update_utc': 'Sun, 06 Sep 2026 00:02:31 +0000',
        'time_next_update_unix': 1788741021,
        'rates': {
          'USD': 1,
          'COP': 4150.25,
          'EUR': 0.85,
        },
      });

      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://open.er-api.com/v6/latest/USD') {
          return http.Response(mockResponse, 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = ExchangeRateService(client: mockClient);
      final result = await service.fetchLatestRates(baseCurrency: 'USD');

      expect(result, isNotNull);
      expect(result!.baseCode, 'USD');
      expect(result.getRate('USD'), 1.0);
      expect(result.getRate('COP'), 4150.25);
      expect(result.getRate('EUR'), 0.85);
      expect(result.getRate('UNKNOWN'), isNull);
      expect(result.lastUpdatedUtc, DateTime.fromMillisecondsSinceEpoch(1788652951 * 1000, isUtc: true));
    });

    test('returns null when server responds with 500 error or error result', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = ExchangeRateService(client: mockClient);
      final result = await service.fetchLatestRates(baseCurrency: 'USD');

      expect(result, isNull);
    });

    test('returns null on invalid JSON schema or non-success result', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'result': 'error', 'error-type': 'unsupported-code'}), 200);
      });

      final service = ExchangeRateService(client: mockClient);
      final result = await service.fetchLatestRates(baseCurrency: 'XYZ');

      expect(result, isNull);
    });

    test('ExchangeRateResult handles JSON serialization and equality correctly', () {
      final now = DateTime.utc(2026, 9, 6, 12, 0);
      final result1 = ExchangeRateResult(
        baseCode: 'USD',
        rates: {'COP': 4150.0, 'USD': 1.0},
        lastUpdatedUtc: now,
      );

      final json = result1.toJson();
      expect(json['base_code'], 'USD');
      expect(json['rates']['COP'], 4150.0);

      final result2 = ExchangeRateResult.fromJson({
        'base_code': 'USD',
        'rates': {'COP': 4150.0, 'USD': 1.0},
        'time_last_update_unix': now.millisecondsSinceEpoch ~/ 1000,
      });

      expect(result1, equals(result2));
    });
  });
}
