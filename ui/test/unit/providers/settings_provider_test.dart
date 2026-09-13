import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/core/constants/app_currency.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/providers/settings_provider.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late FlutterSecureStorage secureStorage;
  late SettingsProvider settingsProv;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    secureStorage = const FlutterSecureStorage();

    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    settingsProv = SettingsProvider(
      dbHelper: dbHelper,
      secureStorage: secureStorage,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SettingsProvider', () {
    test('initial state has default currency USD and null locale', () {
      expect(settingsProv.currency, AppCurrency.usd);
      expect(settingsProv.locale, isNull);
      expect(settingsProv.isInitialized, isFalse);
    });

    test('loadSettings loads saved settings and initializes provider', () async {
      await dbHelper.setSetting(SettingsProvider.keyLanguage, 'es');
      await dbHelper.setSetting(SettingsProvider.keyCurrency, 'COP');

      int notifications = 0;
      settingsProv.addListener(() => notifications++);

      await settingsProv.loadSettings();

      expect(settingsProv.isInitialized, isTrue);
      expect(settingsProv.locale, const Locale('es'));
      expect(settingsProv.currency, AppCurrency.cop);
      expect(CurrencyFormatter.defaultCurrency, AppCurrency.cop);
      expect(notifications, 1);
    });

    test('setLocale updates state, notifies listeners, and persists to database', () async {
      await settingsProv.loadSettings();

      int notifications = 0;
      settingsProv.addListener(() => notifications++);

      await settingsProv.setLocale(const Locale('es'));

      expect(settingsProv.locale, const Locale('es'));
      expect(notifications, 1);

      final String? savedLang = await dbHelper.getSetting(SettingsProvider.keyLanguage);
      expect(savedLang, 'es');

      // Revert to system default (null)
      await settingsProv.setLocale(null);
      expect(settingsProv.locale, isNull);
      final String? systemLang = await dbHelper.getSetting(SettingsProvider.keyLanguage);
      expect(systemLang, 'system');
    });

    test('setCurrency updates state, notifies listeners, updates CurrencyFormatter, and persists', () async {
      await settingsProv.loadSettings();

      int notifications = 0;
      settingsProv.addListener(() => notifications++);

      await settingsProv.setCurrency(AppCurrency.cop);

      expect(settingsProv.currency, AppCurrency.cop);
      expect(CurrencyFormatter.defaultCurrency, AppCurrency.cop);
      expect(notifications, 1);

      final String? savedCurr = await dbHelper.getSetting(SettingsProvider.keyCurrency);
      expect(savedCurr, 'COP');
    });

    test('setGeminiApiKey writes to FlutterSecureStorage and purges SQLite record', () async {
      await settingsProv.loadSettings();

      await settingsProv.setGeminiApiKey('AIzaSyTestSecureKey98765');

      expect(settingsProv.geminiApiKey, 'AIzaSyTestSecureKey98765');

      final storedSecureKey = await secureStorage.read(key: SettingsProvider.keyGeminiApiKey);
      expect(storedSecureKey, 'AIzaSyTestSecureKey98765');

      final sqliteKey = await dbHelper.getSetting(SettingsProvider.keyGeminiApiKey);
      expect(sqliteKey, isNull);
    });

    test('loadSettings migrates legacy SQLite API key to secure storage and deletes from SQLite', () async {
      // Simulate legacy state where API key was in SQLite
      await dbHelper.setSetting(SettingsProvider.keyGeminiApiKey, 'legacy_api_key_123');

      await settingsProv.loadSettings();

      expect(settingsProv.geminiApiKey, 'legacy_api_key_123');

      // Check it was migrated to secure storage
      final storedSecureKey = await secureStorage.read(key: SettingsProvider.keyGeminiApiKey);
      expect(storedSecureKey, 'legacy_api_key_123');

      // Check it was deleted from SQLite
      final sqliteKey = await dbHelper.getSetting(SettingsProvider.keyGeminiApiKey);
      expect(sqliteKey, isNull);
    });
  });
}
