import 'package:intl/intl.dart';
import '../constants/app_currency.dart';

/// Utility class for zero-float integer cent calculations and formatting.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Default active currency used when not explicitly specified.
  static AppCurrency defaultCurrency = AppCurrency.usd;

  /// Converts an integer cent amount to a human-readable currency string.
  /// Example (USD): 1250 cents -> "$12.50"
  /// Example (COP): 5000000 cents -> "$50.000"
  static String formatCents(
    int cents, {
    AppCurrency? currency,
    String? symbol,
    String? locale,
    bool? showDecimals,
  }) {
    final AppCurrency activeCurrency = currency ?? defaultCurrency;
    final double value = cents / 100.0;
    final String activeSymbol = symbol ?? activeCurrency.symbol;
    final String activeLocale = locale ?? activeCurrency.defaultLocale;
    final int digits = showDecimals != null
        ? (showDecimals ? (activeCurrency.decimalDigits > 0 ? activeCurrency.decimalDigits : 2) : 0)
        : activeCurrency.decimalDigits;

    final NumberFormat formatter = NumberFormat.currency(
      locale: activeLocale,
      symbol: activeSymbol,
      decimalDigits: digits,
    );
    return formatter.format(value);
  }

  /// Converts an integer cent value to a double (for presentation/charts only).
  static double centsToDouble(int cents) {
    return cents / 100.0;
  }

  /// Converts a double value (e.g. from a user input) to integer cents.
  static int doubleToCents(double value) {
    return (value * 100).round();
  }

  /// Parses a numeric or currency text string into integer cents.
  /// Handles both period and comma as decimal or thousands separators.
  /// Returns 0 if parsing fails.
  static int parseToCents(String input, {AppCurrency? currency}) {
    if (input.trim().isEmpty) return 0;

    final AppCurrency activeCurrency = currency ?? defaultCurrency;
    final String clean = input.replaceAll(RegExp(r'[^\d.,-]'), '');
    if (clean.isEmpty || clean == '-') return 0;

    final bool isNegative = clean.startsWith('-');
    final String unsigned = isNegative ? clean.substring(1) : clean;

    // For COP, numbers like "50.000" or "50,000" or "50000" represent whole peso units
    if (activeCurrency == AppCurrency.cop) {
      final String digitsOnly = unsigned.replaceAll(RegExp(r'\D'), '');
      final int intVal = int.tryParse(digitsOnly) ?? 0;
      final int totalCents = intVal * 100;
      return isNegative ? -totalCents : totalCents;
    }

    final int lastDot = unsigned.lastIndexOf('.');
    final int lastComma = unsigned.lastIndexOf(',');
    final int decimalIndex = lastDot > lastComma ? lastDot : lastComma;

    String integerPart = unsigned;
    String fractionPart = '';

    if (decimalIndex != -1 && (unsigned.length - 1 - decimalIndex) <= 2) {
      integerPart = unsigned.substring(0, decimalIndex);
      fractionPart = unsigned.substring(decimalIndex + 1);
    }

    final String digitsInt = integerPart.replaceAll(RegExp(r'\D'), '');
    final String digitsFrac = fractionPart.replaceAll(RegExp(r'\D'), '');

    final int intVal = int.tryParse(digitsInt.isEmpty ? '0' : digitsInt) ?? 0;

    int fracVal = 0;
    if (digitsFrac.isNotEmpty) {
      if (digitsFrac.length == 1) {
        fracVal = (int.tryParse(digitsFrac) ?? 0) * 10;
      } else {
        fracVal = int.tryParse(digitsFrac.substring(0, 2)) ?? 0;
      }
    }

    final int totalCents = (intVal * 100) + fracVal;
    return isNegative ? -totalCents : totalCents;
  }

  /// Formats a percentage (e.g. 0.85 -> "85.0%")
  static String formatPercentage(double value, {int decimalDigits = 1}) {
    final NumberFormat formatter = NumberFormat.percentPattern()
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }
}
