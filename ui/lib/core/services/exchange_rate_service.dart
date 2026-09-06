import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/exchange_rate_result.dart';

/// Service client fetching exchange rates from the open.er-api.com public endpoint.
class ExchangeRateService {
  final http.Client _client;
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';
  static const Duration defaultTimeout = Duration(seconds: 10);

  ExchangeRateService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetches latest exchange rates for the given [baseCurrency] (default 'USD').
  /// Returns [ExchangeRateResult] upon success or `null` if request fails or times out.
  Future<ExchangeRateResult?> fetchLatestRates({
    String baseCurrency = 'USD',
  }) async {
    final currency = baseCurrency.toUpperCase().trim();
    final url = Uri.parse('$_baseUrl/$currency');

    try {
      final response = await _client
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(defaultTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> &&
            decoded['result'] == 'success') {
          return ExchangeRateResult.fromJson(decoded);
        }
      }
      debugPrint(
        'ExchangeRateService: request to $url returned status ${response.statusCode}',
      );
      return null;
    } on TimeoutException catch (e) {
      debugPrint('ExchangeRateService timeout: $e');
      return null;
    } catch (e, stack) {
      debugPrint('ExchangeRateService error: $e\n$stack');
      return null;
    }
  }

  /// Closes the internal HTTP client when done.
  void dispose() {
    _client.close();
  }
}
