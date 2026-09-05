import 'package:intl/intl.dart';

/// Utility class for zero-float integer cent calculations and formatting.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Converts an integer cent amount to a human-readable currency string.
  /// Example: 1250 cents -> "$12.50"
  static String formatCents(
    int cents, {
    String symbol = '\$',
    String locale = 'en_US',
    bool showDecimals = true,
  }) {
    final double value = cents / 100.0;
    final NumberFormat formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: showDecimals ? 2 : 0,
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
  static int parseToCents(String input) {
    if (input.trim().isEmpty) return 0;

    final String clean = input.replaceAll(RegExp(r'[^\d.,-]'), '');
    if (clean.isEmpty || clean == '-') return 0;

    final bool isNegative = clean.startsWith('-');
    final String unsigned = isNegative ? clean.substring(1) : clean;

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
