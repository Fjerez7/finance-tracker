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

import 'package:flutter/services.dart';
import 'package:finance_tracker/services/screen_security_service.dart';

import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/notification_sync_provider.dart';
import 'package:finance_tracker/providers/subscriptions_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/category_repository_impl.dart';
import 'package:finance_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:finance_tracker/data/repositories/transaction_repository_impl.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late SettingsProvider settingsProvider;
  late AppLockProvider appLockProvider;
  late NotificationSyncProvider notificationSyncProvider;
  late AccountsProvider accountsProvider;
  late TransactionsProvider transactionsProvider;
  late SubscriptionsProvider subscriptionsProvider;
  const channel = MethodChannel(ScreenSecurityService.defaultChannelName);
  const notifChannel = MethodChannel('com.example.financetracker/notifications');

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return true;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getBufferedNotifications') {
        return <dynamic>[];
      }
      return true;
    });
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

    notificationSyncProvider = NotificationSyncProvider(dbHelper: dbHelper);
    await notificationSyncProvider.initialize();

    final accountRepo = AccountRepositoryImpl(databaseHelper: dbHelper);
    final catRepo = CategoryRepositoryImpl(databaseHelper: dbHelper);
    final txRepo = TransactionRepositoryImpl(databaseHelper: dbHelper);
    final subRepo = SubscriptionRepositoryImpl(databaseHelper: dbHelper);

    accountsProvider = AccountsProvider(repository: accountRepo);
    transactionsProvider = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: catRepo,
    );
    subscriptionsProvider = SubscriptionsProvider(
      repository: subRepo,
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifChannel, null);
    await dbHelper.close();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<AppLockProvider>.value(value: appLockProvider),
        ChangeNotifierProvider<NotificationSyncProvider>.value(value: notificationSyncProvider),
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProvider),
        ChangeNotifierProvider<TransactionsProvider>.value(value: transactionsProvider),
        ChangeNotifierProvider<SubscriptionsProvider>.value(value: subscriptionsProvider),
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
      expect(find.text('Notification Bank Sync'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Finance Tracker'), findsOneWidget);
      expect(find.text('Local Database'), findsOneWidget);
    });

    testWidgets('tapping Notification Bank Sync tile navigates to NotificationSyncSettingsScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notification Bank Sync'));
      await tester.pumpAndSettle();

      expect(find.text('Android Notification Access'), findsOneWidget);
      expect(find.text('Monitored Banking Apps'), findsOneWidget);
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

    testWidgets('toggling screen protection switch updates app lock provider', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Screen Protection & Privacy'), findsOneWidget);
      expect(appLockProvider.isScreenProtectionEnabled, isTrue);

      // Tap on the switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Screen Protection & Privacy'));
      await tester.pumpAndSettle();

      expect(appLockProvider.isScreenProtectionEnabled, isFalse);

      // Tap again to re-enable
      await tester.tap(find.widgetWithText(SwitchListTile, 'Screen Protection & Privacy'));
      await tester.pumpAndSettle();

      expect(appLockProvider.isScreenProtectionEnabled, isTrue);
    });
  });
}
