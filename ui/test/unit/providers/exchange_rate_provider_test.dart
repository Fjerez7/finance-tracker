import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/core/services/exchange_rate_service.dart';
import 'package:finance_tracker/domain/entities/exchange_rate_result.dart';
import 'package:finance_tracker/domain/repositories/exchange_rate_repository.dart';
import 'package:finance_tracker/providers/exchange_rate_provider.dart';

class FakeExchangeRateRepo implements ExchangeRateRepository {
  final Map<String, ExchangeRateResult> _storage = {};

  @override
  Future<ExchangeRateResult?> getCachedRates(String baseCurrency) async {
    return _storage[baseCurrency.toUpperCase()];
  }

  @override
  Future<void> saveRates(ExchangeRateResult result) async {
    _storage[result.baseCode.toUpperCase()] = result;
  }
}

class FakeExchangeRateService extends ExchangeRateService {
  ExchangeRateResult? stubResult;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<ExchangeRateResult?> fetchLatestRates({String baseCurrency = 'USD'}) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return stubResult;
  }
}

void main() {
  group('ExchangeRateProvider Unit Tests', () {
    late FakeExchangeRateRepo repo;
    late FakeExchangeRateService service;
    late ExchangeRateProvider provider;

    setUp(() {
      repo = FakeExchangeRateRepo();
      service = FakeExchangeRateService();
      provider = ExchangeRateProvider(
        service: service,
        repository: repo,
      );
    });

    test('initializes and populates cache from repository if available', () async {
      final now = DateTime.now().toUtc();
      await repo.saveRates(
        ExchangeRateResult(
          baseCode: 'USD',
          rates: {'COP': 4150.0, 'EUR': 0.85},
          lastUpdatedUtc: now,
        ),
      );

      await provider.initialize();

      expect(provider.getRate('USD', 'COP'), 4150.0);
      expect(provider.getRate('USD', 'EUR'), 0.85);
      expect(provider.getRate('USD', 'USD'), 1.0);
    });

    test('fetches rates from service and persists to repository', () async {
      final now = DateTime.now().toUtc();
      service.stubResult = ExchangeRateResult(
        baseCode: 'USD',
        rates: {'COP': 4200.0, 'EUR': 0.88},
        lastUpdatedUtc: now,
      );

      final success = await provider.fetchRates(baseCurrency: 'USD', force: true);
      expect(success, isTrue);
      expect(provider.getRate('USD', 'COP'), 4200.0);

      final cachedInRepo = await repo.getCachedRates('USD');
      expect(cachedInRepo, isNotNull);
      expect(cachedInRepo!.rates['COP'], 4200.0);
    });

    test('converts amounts between currencies accurately with zero-float integer math', () {
      service.stubResult = ExchangeRateResult(
        baseCode: 'USD',
        rates: {'COP': 4150.0, 'EUR': 0.90},
        lastUpdatedUtc: DateTime.now().toUtc(),
      );
      provider.fetchRates(baseCurrency: 'USD', force: true);

      // USD 15.00 (1500 cents) -> COP 62,250 (6,225,000 cents)
      final copAmount = provider.convertAmount(
        amountCents: 1500,
        fromCurrency: 'USD',
        toCurrency: 'COP',
      );
      expect(copAmount, 6225000);

      // Same currency conversion returns exact amount
      final sameAmount = provider.convertAmount(
        amountCents: 1500,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );
      expect(sameAmount, 1500);

      // Manual custom rate override
      final customCopAmount = provider.convertAmount(
        amountCents: 1500,
        fromCurrency: 'USD',
        toCurrency: 'COP',
        customRate: 4180.0,
      );
      expect(customCopAmount, 6270000);
    });

    test('handles network failure with fallback to SQLite cache and error message', () async {
      await repo.saveRates(
        ExchangeRateResult(
          baseCode: 'USD',
          rates: {'COP': 4100.0},
          lastUpdatedUtc: DateTime.utc(2026, 9, 1),
        ),
      );

      service.shouldThrow = true;
      final success = await provider.fetchRates(baseCurrency: 'USD', force: true);

      expect(success, isFalse);
      expect(provider.errorMessage, isNotNull);
    });
  });
}
