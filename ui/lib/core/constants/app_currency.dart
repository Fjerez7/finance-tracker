/// Supported financial currencies in Finance Tracker.
enum AppCurrency {
  usd(
    code: 'USD',
    symbol: '\$',
    decimalDigits: 2,
    displayName: 'US Dollar (USD)',
    defaultLocale: 'en_US',
  ),
  cop(
    code: 'COP',
    symbol: '\$',
    decimalDigits: 0,
    displayName: 'Colombian Peso (COP)',
    defaultLocale: 'es_CO',
  );

  final String code;
  final String symbol;
  final int decimalDigits;
  final String displayName;
  final String defaultLocale;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.decimalDigits,
    required this.displayName,
    required this.defaultLocale,
  });

  static AppCurrency fromCode(String? code) {
    if (code == null) return AppCurrency.usd;
    return AppCurrency.values.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => AppCurrency.usd,
    );
  }
}
