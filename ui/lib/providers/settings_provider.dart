import 'package:flutter/material.dart';
import '../core/constants/app_currency.dart';
import '../core/utils/currency_formatter.dart';
import '../data/datasources/local/database_helper.dart';

/// Provider managing application-wide settings: Locale and Active Currency.
class SettingsProvider extends ChangeNotifier {
  static const String keyLanguage = 'app_language';
  static const String keyCurrency = 'app_currency';

  final DatabaseHelper _dbHelper;

  Locale? _locale;
  AppCurrency _currency = AppCurrency.usd;
  bool _isInitialized = false;

  SettingsProvider({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Locale? get locale => _locale;
  AppCurrency get currency => _currency;
  bool get isInitialized => _isInitialized;

  /// Loads saved language and currency settings from SQLite.
  Future<void> loadSettings() async {
    try {
      final String? langCode = await _dbHelper.getSetting(keyLanguage);
      if (langCode != null && langCode.isNotEmpty && langCode != 'system') {
        _locale = Locale(langCode);
      } else {
        _locale = null; // System default
      }

      final String? currCode = await _dbHelper.getSetting(keyCurrency);
      if (currCode != null && currCode.isNotEmpty) {
        _currency = AppCurrency.fromCode(currCode);
      } else {
        _currency = AppCurrency.usd;
      }

      CurrencyFormatter.defaultCurrency = _currency;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('SettingsProvider.loadSettings error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Updates the application locale and persists it.
  /// Pass `null` to revert to device system default.
  Future<void> setLocale(Locale? newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;
    notifyListeners();

    final String langValue = newLocale == null ? 'system' : newLocale.languageCode;
    await _dbHelper.setSetting(keyLanguage, langValue);
  }

  /// Updates the active currency and persists it.
  Future<void> setCurrency(AppCurrency newCurrency) async {
    if (_currency == newCurrency) return;

    _currency = newCurrency;
    CurrencyFormatter.defaultCurrency = newCurrency;
    notifyListeners();

    await _dbHelper.setSetting(keyCurrency, newCurrency.code);
  }
}
