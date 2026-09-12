import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/core/constants/app_currency.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    setUp(() {
      CurrencyFormatter.defaultCurrency = AppCurrency.usd;
    });

    test('formats cents to currency string with 2 decimals by default for USD', () {
      expect(CurrencyFormatter.formatCents(1250), '\$12.50');
      expect(CurrencyFormatter.formatCents(0), '\$0.00');
      expect(CurrencyFormatter.formatCents(99), '\$0.99');
      expect(CurrencyFormatter.formatCents(100000), '\$1,000.00');
    });

    test('formats cents to currency string without decimals for COP', () {
      expect(
        CurrencyFormatter.formatCents(5000000, currency: AppCurrency.cop),
        '50.000\u00a0\$',
      );
      expect(
        CurrencyFormatter.formatCents(100000000, currency: AppCurrency.cop),
        '1.000.000\u00a0\$',
      );
    });

    test('formats cents using defaultCurrency when updated to COP', () {
      CurrencyFormatter.defaultCurrency = AppCurrency.cop;
      expect(CurrencyFormatter.formatCents(5000000), '50.000\u00a0\$');
    });

    test('formats cents without decimals when showDecimals is false for USD', () {
      expect(CurrencyFormatter.formatCents(1250, showDecimals: false), '\$13');
      expect(CurrencyFormatter.formatCents(1200, showDecimals: false), '\$12');
    });

    test('converts cents to double accurately', () {
      expect(CurrencyFormatter.centsToDouble(1250), 12.5);
      expect(CurrencyFormatter.centsToDouble(0), 0.0);
      expect(CurrencyFormatter.centsToDouble(-500), -5.0);
    });

    test('converts double to integer cents accurately', () {
      expect(CurrencyFormatter.doubleToCents(12.5), 1250);
      expect(CurrencyFormatter.doubleToCents(0.99), 99);
      expect(CurrencyFormatter.doubleToCents(100.00), 10000);
    });

    test('parses formatted currency strings to integer cents for USD', () {
      expect(CurrencyFormatter.parseToCents('\$12.50'), 1250);
      expect(CurrencyFormatter.parseToCents('1,000.50'), 100050);
      expect(CurrencyFormatter.parseToCents('45.99'), 4599);
      expect(CurrencyFormatter.parseToCents(''), 0);
    });

    test('parses formatted currency strings to integer cents for COP', () {
      expect(
        CurrencyFormatter.parseToCents('\$50.000', currency: AppCurrency.cop),
        5000000,
      );
      expect(
        CurrencyFormatter.parseToCents('50,000', currency: AppCurrency.cop),
        5000000,
      );
      expect(
        CurrencyFormatter.parseToCents('1000000', currency: AppCurrency.cop),
        100000000,
      );
    });

    test('formats percentage values', () {
      expect(CurrencyFormatter.formatPercentage(0.85), '85.0%');
      expect(CurrencyFormatter.formatPercentage(1.0), '100.0%');
      expect(CurrencyFormatter.formatPercentage(0.1234), '12.3%');
    });
  });
}
