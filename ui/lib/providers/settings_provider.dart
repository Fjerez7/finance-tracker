import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_currency.dart';
import '../core/utils/currency_formatter.dart';
import '../data/datasources/local/database_helper.dart';

/// Provider managing application-wide settings: Locale, Currency, and Gmail/Gemini Bank Sync.
class SettingsProvider extends ChangeNotifier {
  static const String keyLanguage = 'app_language';
  static const String keyCurrency = 'app_currency';
  static const String keyGeminiApiKey = 'gemini_api_key';
  static const String keyBankSenders = 'bank_senders';
  static const String keyGmailSyncEnabled = 'gmail_sync_enabled';

  static const String defaultBankSenders =
      'alertasynotificaciones@bancolombia.com.co,alertasynotificaciones@an.notificacionesbancolombia.com,alertas@notificacionesbancolombia.com,notificaciones@rappicard.co,noreply@rappicard.co,nu@nu.com.co,tucuentanu@nu.com.co,ayuda@nu.com.co,notificaciones@nu.com.co,alertas@nu.com.co';
  static const String defaultGeminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  final DatabaseHelper _dbHelper;
  final FlutterSecureStorage _secureStorage;

  Locale? _locale;
  AppCurrency _currency = AppCurrency.usd;
  String _geminiApiKey = defaultGeminiApiKey;
  String _bankSenders = defaultBankSenders;
  bool _isGmailSyncEnabled = true;
  bool _isInitialized = false;

  SettingsProvider({
    DatabaseHelper? dbHelper,
    FlutterSecureStorage? secureStorage,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Locale? get locale => _locale;
  AppCurrency get currency => _currency;
  String get geminiApiKey => _geminiApiKey.isNotEmpty ? _geminiApiKey : defaultGeminiApiKey;
  String get bankSenders => _bankSenders;
  bool get isGmailSyncEnabled => _isGmailSyncEnabled;
  bool get isInitialized => _isInitialized;

  List<String> get bankSendersList =>
      _bankSenders.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  /// Loads saved language, currency, and sync settings from SQLite and Keystore.
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

      // Hardware-backed secure storage retrieval with transparent SQLite migration
      final String? legacySqliteKey = await _dbHelper.getSetting(keyGeminiApiKey);
      if (legacySqliteKey != null && legacySqliteKey.isNotEmpty) {
        // Migrate to hardware keystore
        await _secureStorage.write(key: keyGeminiApiKey, value: legacySqliteKey);
        // Purge plaintext key from SQLite
        await _dbHelper.deleteSetting(keyGeminiApiKey);
        _geminiApiKey = legacySqliteKey;
      } else {
        final String? secureKey = await _secureStorage.read(key: keyGeminiApiKey);
        if (secureKey != null && secureKey.isNotEmpty) {
          _geminiApiKey = secureKey;
        } else {
          _geminiApiKey = defaultGeminiApiKey;
        }
      }

      _bankSenders = await _dbHelper.getSetting(keyBankSenders) ?? defaultBankSenders;
      final String? syncVal = await _dbHelper.getSetting(keyGmailSyncEnabled);
      _isGmailSyncEnabled = syncVal != 'false';

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

  /// Updates the Gemini API Key for on-device bank email extraction in hardware keystore.
  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key.trim();
    notifyListeners();
    if (_geminiApiKey.isEmpty) {
      await _secureStorage.delete(key: keyGeminiApiKey);
    } else {
      await _secureStorage.write(key: keyGeminiApiKey, value: _geminiApiKey);
    }
    // Defensive cleanup in SQLite
    await _dbHelper.deleteSetting(keyGeminiApiKey);
  }

  /// Updates the list of monitored bank sender emails.
  Future<void> setBankSenders(String senders) async {
    _bankSenders = senders.trim();
    notifyListeners();
    await _dbHelper.setSetting(keyBankSenders, _bankSenders);
  }

  /// Toggles automated in-app Gmail bank synchronization.
  Future<void> setGmailSyncEnabled(bool enabled) async {
    if (_isGmailSyncEnabled == enabled) return;
    _isGmailSyncEnabled = enabled;
    notifyListeners();
    await _dbHelper.setSetting(keyGmailSyncEnabled, enabled.toString());
  }
}
