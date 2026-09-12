import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/core/services/exchange_rate_service.dart';
import 'package:finance_tracker/domain/entities/exchange_rate_result.dart';
import 'package:finance_tracker/domain/repositories/exchange_rate_repository.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/widgets/cards/currency_conversion_card.dart';
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

  @override
  Future<ExchangeRateResult?> fetchLatestRates({String baseCurrency = 'USD'}) async {
    return stubResult ??
        ExchangeRateResult(
          baseCode: 'USD',
          rates: {'COP': 4150.0, 'USD': 1.0, 'EUR': 0.85},
          lastUpdatedUtc: DateTime.now().toUtc(),
        );
  }
}

void main() {
  group('CurrencyConversionCard Widget Tests', () {
    late FakeExchangeRateRepo repo;
    late FakeExchangeRateService service;
    late ExchangeRateProvider exchangeProv;

    setUp(() {
      repo = FakeExchangeRateRepo();
      service = FakeExchangeRateService();
      exchangeProv = ExchangeRateProvider(
        service: service,
        repository: repo,
      );
    });

    Widget buildTestableWidget({
      required String fromCurrency,
      required String toCurrency,
      required int amountCents,
      double? customRate,
      required ValueChanged<double?> onCustomRateChanged,
    }) {
      return ChangeNotifierProvider<ExchangeRateProvider>.value(
        value: exchangeProv,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CurrencyConversionCard(
              fromCurrency: fromCurrency,
              toCurrency: toCurrency,
              amountCents: amountCents,
              customRate: customRate,
              onCustomRateChanged: onCustomRateChanged,
            ),
          ),
        ),
      );
    }

    testWidgets('renders CurrencyConversionCard with converted debited amount', (
      WidgetTester tester,
    ) async {
      await exchangeProv.fetchRates(baseCurrency: 'USD', force: true);

      double? updatedRate;

      await tester.pumpWidget(
        buildTestableWidget(
          fromCurrency: 'USD',
          toCurrency: 'COP',
          amountCents: 1500, // $15.00 USD
          onCustomRateChanged: (rate) => updatedRate = rate,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Currency Conversion'), findsOneWidget);
      expect(find.text('1 USD = 4150.00 COP'), findsOneWidget);
      expect(find.text('Debited from account'), findsOneWidget);
      expect(find.text('62.250\u00a0\$'), findsOneWidget);

      // Open Edit Rate Dialog
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Edit Exchange Rate'), findsOneWidget);

      // Enter custom rate
      await tester.enterText(find.byType(TextField), '4200.0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(updatedRate, 4200.0);
    });

    testWidgets('displays Custom Rate badge when customRate is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          fromCurrency: 'USD',
          toCurrency: 'COP',
          amountCents: 1500,
          customRate: 4300.0,
          onCustomRateChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Rate'), findsOneWidget);
      expect(find.text('1 USD = 4300.00 COP'), findsOneWidget);
    });
  });
}
