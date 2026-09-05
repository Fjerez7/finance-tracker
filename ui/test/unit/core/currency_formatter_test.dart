import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats cents to currency string with 2 decimals by default', () {
      expect(CurrencyFormatter.formatCents(1250), '\$12.50');
      expect(CurrencyFormatter.formatCents(0), '\$0.00');
      expect(CurrencyFormatter.formatCents(99), '\$0.99');
      expect(CurrencyFormatter.formatCents(100000), '\$1,000.00');
    });

    test('formats cents without decimals when showDecimals is false', () {
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

    test('parses formatted currency strings to integer cents', () {
      expect(CurrencyFormatter.parseToCents('\$12.50'), 1250);
      expect(CurrencyFormatter.parseToCents('1,000.50'), 100050);
      expect(CurrencyFormatter.parseToCents('45.99'), 4599);
      expect(CurrencyFormatter.parseToCents(''), 0);
    });

    test('formats percentage values', () {
      expect(CurrencyFormatter.formatPercentage(0.85), '85.0%');
      expect(CurrencyFormatter.formatPercentage(1.0), '100.0%');
      expect(CurrencyFormatter.formatPercentage(0.1234), '12.3%');
    });
  });
}
