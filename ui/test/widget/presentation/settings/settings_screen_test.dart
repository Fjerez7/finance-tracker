import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/core/constants/app_currency.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/settings/settings_screen.dart';
import 'package:finance_tracker/providers/app_lock_provider.dart';
import 'package:finance_tracker/providers/settings_provider.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late SettingsProvider settingsProvider;
  late AppLockProvider appLockProvider;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    settingsProvider = SettingsProvider(dbHelper: dbHelper);
    await settingsProvider.loadSettings();

    appLockProvider = AppLockProvider();
    await appLockProvider.initialize();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<AppLockProvider>.value(value: appLockProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            locale: settings.locale ?? const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          );
        },
      ),
    );
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all sections and preferences tiles', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
      expect(find.text('Biometric App Lock'), findsOneWidget);
      expect(find.text('Data & Storage'), findsOneWidget);
      expect(find.text('Cloud Backup'), findsOneWidget);
      expect(find.text('Gmail Bank Synchronization'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Finance Tracker'), findsOneWidget);
      expect(find.text('Local Database'), findsOneWidget);
    });

    testWidgets('selecting language in dialog updates provider locale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Open Language Dialog
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('System Default'), findsNWidgets(2));

      // Select Spanish
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(settingsProvider.locale, equals(const Locale('es')));
      // Screen title in Spanish
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Preferencias'), findsOneWidget);
    });

    testWidgets('selecting currency in dialog updates provider currency', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Open Currency Dialog
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.text(r'US Dollar (USD - $)'), findsNWidgets(2));
      expect(find.text(r'Colombian Peso (COP - $)'), findsOneWidget);

      // Select Colombian Peso
      await tester.tap(find.widgetWithText(RadioListTile<AppCurrency>, r'Colombian Peso (COP - $)'));
      await tester.pumpAndSettle();

      expect(settingsProvider.currency, equals(AppCurrency.cop));
      expect(find.text(r'Colombian Peso (COP - $)'), findsOneWidget);
    });
  });
}
