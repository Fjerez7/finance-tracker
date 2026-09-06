import 'package:flutter/foundation.dart';
import '../core/services/exchange_rate_service.dart';
import '../domain/repositories/exchange_rate_repository.dart';

/// Provider managing exchange rate retrieval, SQLite caching, and multi-currency conversions.
class ExchangeRateProvider extends ChangeNotifier {
  final ExchangeRateService _service;
  final ExchangeRateRepository _repository;

  final Map<String, Map<String, double>> _ratesCache = {};
  DateTime? _lastFetchTime;
  bool _isLoading = false;
  String? _errorMessage;

  static const Duration cacheTtl = Duration(hours: 24);

  ExchangeRateProvider({
    ExchangeRateService? service,
    required ExchangeRateRepository repository,
  })  : _service = service ?? ExchangeRateService(),
        _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastFetchTime => _lastFetchTime;
  Map<String, Map<String, double>> get ratesCache => Map.unmodifiable(_ratesCache);

  /// Initializes provider by loading cached rates from SQLite and refreshing if stale.
  Future<void> initialize() async {
    // 1. Load local cache from SQLite
    try {
      final cachedUsd = await _repository.getCachedRates('USD');
      if (cachedUsd != null) {
        _ratesCache['USD'] = cachedUsd.rates;
        _lastFetchTime = cachedUsd.lastUpdatedUtc;
      }
      final cachedCop = await _repository.getCachedRates('COP');
      if (cachedCop != null) {
        _ratesCache['COP'] = cachedCop.rates;
      }
    } catch (e) {
      debugPrint('ExchangeRateProvider init error loading cache: $e');
    }

    // 2. Fetch fresh rates from network if cache is empty or stale (>24h)
    final bool shouldFetch = _lastFetchTime == null ||
        DateTime.now().toUtc().difference(_lastFetchTime!) > cacheTtl;

    if (shouldFetch) {
      await fetchRates(baseCurrency: 'USD', force: false);
    } else {
      notifyListeners();
    }
  }

  /// Fetches latest exchange rates from open.er-api.com.
  /// Skips network call if rates were retrieved within [cacheTtl] and [force] is false.
  Future<bool> fetchRates({
    String baseCurrency = 'USD',
    bool force = false,
  }) async {
    final base = baseCurrency.toUpperCase().trim();

    if (!force &&
        _lastFetchTime != null &&
        DateTime.now().toUtc().difference(_lastFetchTime!) < cacheTtl &&
        _ratesCache.containsKey(base)) {
      return true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchLatestRates(baseCurrency: base);

      if (result != null) {
        _ratesCache[base] = result.rates;
        _lastFetchTime = result.lastUpdatedUtc;
        _errorMessage = null;
        await _repository.saveRates(result);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Network or parsing failed; fallback to SQLite cache if available
        final cached = await _repository.getCachedRates(base);
        if (cached != null) {
          _ratesCache[base] = cached.rates;
          _lastFetchTime = cached.lastUpdatedUtc;
        }
        _isLoading = false;
        _errorMessage = 'Failed to fetch live exchange rates. Using cached rates.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Resolves the exchange rate from [fromCurrency] to [toCurrency].
  /// Returns 1.0 if identical. Resolves inverse and USD cross-rates.
  double? getRate(String fromCurrency, String toCurrency) {
    final from = fromCurrency.toUpperCase().trim();
    final to = toCurrency.toUpperCase().trim();

    if (from == to) return 1.0;

    // 1. Direct rate in cache
    if (_ratesCache.containsKey(from) && _ratesCache[from]!.containsKey(to)) {
      return _ratesCache[from]![to];
    }

    // 2. Inverse rate in cache
    if (_ratesCache.containsKey(to) && _ratesCache[to]!.containsKey(from)) {
      final inv = _ratesCache[to]![from]!;
      if (inv != 0) return 1.0 / inv;
    }

    // 3. Cross rate via USD
    if (_ratesCache.containsKey('USD')) {
      final usdRates = _ratesCache['USD']!;
      final rateTo = to == 'USD' ? 1.0 : usdRates[to];
      final rateFrom = from == 'USD' ? 1.0 : usdRates[from];

      if (rateTo != null && rateFrom != null && rateFrom > 0) {
        return rateTo / rateFrom;
      }
    }

    // 4. Offline hardcoded fallback for common pairs if uninitialized
    if (from == 'USD' && to == 'COP') return 4150.0;
    if (from == 'COP' && to == 'USD') return 1.0 / 4150.0;
    if (from == 'EUR' && to == 'USD') return 1.08;
    if (from == 'USD' && to == 'EUR') return 0.92;
    if (from == 'EUR' && to == 'COP') return 4500.0;
    if (from == 'COP' && to == 'EUR') return 1.0 / 4500.0;

    return null;
  }

  /// Converts [amountCents] in [fromCurrency] to equivalent integer cents in [toCurrency].
  /// If [customRate] is provided, uses it directly; otherwise resolves from live/cached rates.
  int convertAmount({
    required int amountCents,
    required String fromCurrency,
    required String toCurrency,
    double? customRate,
  }) {
    final from = fromCurrency.toUpperCase().trim();
    final to = toCurrency.toUpperCase().trim();

    if (from == to || amountCents == 0) {
      return amountCents;
    }

    final double rate = customRate ?? getRate(from, to) ?? 1.0;
    final double converted = amountCents * rate;
    return converted.round();
  }
}
