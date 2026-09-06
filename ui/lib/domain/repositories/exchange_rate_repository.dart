import '../entities/exchange_rate_result.dart';

/// Repository contract for caching and reading currency exchange rates.
abstract class ExchangeRateRepository {
  /// Retrieves the cached exchange rates for the specified [baseCurrency].
  /// Returns `null` if no cached rates exist for the base currency.
  Future<ExchangeRateResult?> getCachedRates(String baseCurrency);

  /// Persists or updates the exchange rates for a base currency.
  Future<void> saveRates(ExchangeRateResult result);
}
