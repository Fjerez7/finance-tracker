import 'package:flutter/foundation.dart';

/// Represents a set of currency exchange rates relative to a base currency.
@immutable
class ExchangeRateResult {
  final String baseCode;
  final Map<String, double> rates;
  final DateTime lastUpdatedUtc;
  final DateTime? nextUpdateUtc;

  const ExchangeRateResult({
    required this.baseCode,
    required this.rates,
    required this.lastUpdatedUtc,
    this.nextUpdateUtc,
  });

  /// Retrieves the exchange rate for [targetCurrency] relative to [baseCode].
  /// Returns 1.0 if [targetCurrency] matches [baseCode].
  double? getRate(String targetCurrency) {
    final normalized = targetCurrency.toUpperCase();
    if (normalized == baseCode.toUpperCase()) {
      return 1.0;
    }
    return rates[normalized];
  }

  /// Parses an [ExchangeRateResult] from open.er-api.com standard JSON schema.
  factory ExchangeRateResult.fromJson(Map<String, dynamic> json) {
    final baseCode = (json['base_code'] as String? ?? 'USD').toUpperCase();
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final Map<String, double> rates = {};

    rawRates.forEach((key, value) {
      if (value is num) {
        rates[key.toUpperCase()] = value.toDouble();
      }
    });

    DateTime lastUpdated = DateTime.now().toUtc();
    if (json['time_last_update_unix'] is int) {
      lastUpdated = DateTime.fromMillisecondsSinceEpoch(
        (json['time_last_update_unix'] as int) * 1000,
        isUtc: true,
      );
    } else if (json['time_last_update_utc'] is String) {
      try {
        lastUpdated = DateTime.parse(json['time_last_update_utc'] as String).toUtc();
      } catch (_) {}
    }

    DateTime? nextUpdate;
    if (json['time_next_update_unix'] is int) {
      nextUpdate = DateTime.fromMillisecondsSinceEpoch(
        (json['time_next_update_unix'] as int) * 1000,
        isUtc: true,
      );
    }

    return ExchangeRateResult(
      baseCode: baseCode,
      rates: rates,
      lastUpdatedUtc: lastUpdated,
      nextUpdateUtc: nextUpdate,
    );
  }

  /// Serializes to a standard Map representation.
  Map<String, dynamic> toJson() {
    return {
      'base_code': baseCode,
      'rates': rates,
      'time_last_update_unix': lastUpdatedUtc.millisecondsSinceEpoch ~/ 1000,
      if (nextUpdateUtc != null)
        'time_next_update_unix': nextUpdateUtc!.millisecondsSinceEpoch ~/ 1000,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeRateResult &&
          runtimeType == other.runtimeType &&
          baseCode == other.baseCode &&
          mapEquals(rates, other.rates) &&
          lastUpdatedUtc == other.lastUpdatedUtc;

  @override
  int get hashCode =>
      baseCode.hashCode ^ rates.hashCode ^ lastUpdatedUtc.hashCode;
}
