import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/models/inbox_transaction_model.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/category_repository_impl.dart';
import 'package:finance_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:finance_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/settings/notification_sync_settings_screen.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/notification_sync_provider.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/providers/subscriptions_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/services/gemini_extraction_service.dart';
import 'package:finance_tracker/services/notification_bridge_service.dart';

class FakeNotificationBridgeService extends NotificationBridgeService {
  bool permission = true;
  List<String> syncedPackages = [];
  List<Map<String, dynamic>> buffered = [];

  @override
  Future<bool> isNotificationAccessGranted() async => permission;

  @override
  Future<bool> requestNotificationAccess() async => true;

  @override
  Future<bool> syncMonitoredPackages(List<String> packages) async {
    syncedPackages = List.from(packages);
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getBufferedNotifications() async {
    final result = List<Map<String, dynamic>>.from(buffered);
    buffered.clear();
    return result;
  }
}

class FakeGeminiExtractionService implements GeminiExtractionService {
  InboxTransactionModel? mockResult;

  @override
  Future<InboxTransactionModel?> extractTransaction({
    required String emailBody,
    required String emailSubject,
    required String sender,
    required DateTime emailDate,
    required String messageId,
    required String apiKey,
  }) async {
    return mockResult;
  }
}

class FakeDatabaseHelper implements DatabaseHelper {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final List<Map<String, dynamic>> _monitoredApps = [
    {
      'id': 'nubank',
      'package_name': 'com.nu.production',
      'display_name': 'Nubank',
      'is_enabled': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }
  ];
  final List<Map<String, dynamic>> _pendingNotifications = [];

  @override
  Future<List<Map<String, dynamic>>> getMonitoredBankApps() async {
    return List.from(_monitoredApps);
  }

  @override
  Future<int> insertMonitoredBankApp(Map<String, dynamic> row) async {
    _monitoredApps.add(Map.from(row));
    return 1;
  }

  @override
  Future<int> updateMonitoredBankApp(String id, Map<String, dynamic> values) async {
    final index = _monitoredApps.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      _monitoredApps[index] = {..._monitoredApps[index], ...values};
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteMonitoredBankApp(String id) async {
    _monitoredApps.removeWhere((a) => a['id'] == id);
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingBankNotifications({bool unprocessedOnly = false}) async {
    if (unprocessedOnly) {
      return _pendingNotifications.where((n) => n['is_processed'] == 0).toList();
    }
    return List.from(_pendingNotifications);
  }

  @override
  Future<int> insertPendingBankNotification(Map<String, dynamic> row) async {
    _pendingNotifications.add(Map.from(row));
    return 1;
  }

  @override
  Future<int> markPendingBankNotificationProcessed(String id) async {
    final index = _pendingNotifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _pendingNotifications[index]['is_processed'] = 1;
      return 1;
    }
    return 0;
  }

  @override
  Future<void> close() async {}
}

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late FakeDatabaseHelper notifDbHelper;
  late FakeNotificationBridgeService bridgeService;
  late FakeGeminiExtractionService geminiService;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl transactionRepo;
  late SubscriptionRepositoryImpl subscriptionRepo;
  late NotificationSyncProvider notificationSyncProvider;
  late SettingsProvider settingsProvider;
  late AccountsProvider accountsProvider;
  late TransactionsProvider transactionsProvider;
  late SubscriptionsProvider subscriptionsProvider;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    notifDbHelper = FakeDatabaseHelper();
    bridgeService = FakeNotificationBridgeService();
    geminiService = FakeGeminiExtractionService();
    accountRepo = AccountRepositoryImpl(databaseHelper: dbHelper);
    categoryRepo = CategoryRepositoryImpl(databaseHelper: dbHelper);
    transactionRepo = TransactionRepositoryImpl(databaseHelper: dbHelper);
    subscriptionRepo = SubscriptionRepositoryImpl(databaseHelper: dbHelper);

    settingsProvider = SettingsProvider(dbHelper: dbHelper);
    await settingsProvider.loadSettings();

    notificationSyncProvider = NotificationSyncProvider(
      dbHelper: notifDbHelper,
      bridgeService: bridgeService,
      geminiService: geminiService,
    );
    await notificationSyncProvider.initialize();

    accountsProvider = AccountsProvider(repository: accountRepo);
    transactionsProvider = TransactionsProvider(
      transactionRepository: transactionRepo,
      categoryRepository: categoryRepo,
    );
    subscriptionsProvider = SubscriptionsProvider(
      repository: subscriptionRepo,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationSyncProvider>.value(value: notificationSyncProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProvider),
        ChangeNotifierProvider<TransactionsProvider>.value(value: transactionsProvider),
        ChangeNotifierProvider<SubscriptionsProvider>.value(value: subscriptionsProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotificationSyncSettingsScreen(
          accountRepository: accountRepo,
          categoryRepository: categoryRepo,
          transactionRepository: transactionRepo,
          subscriptionRepository: subscriptionRepo,
        ),
      ),
    );
  }

  group('NotificationSyncSettingsScreen Widget Tests', () {
    testWidgets('renders permission card, monitored banks, and sync button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Notification Bank Sync'), findsOneWidget);
      expect(find.text('Android Notification Access'), findsOneWidget);
      expect(find.text('Active & Listening'), findsOneWidget);
      expect(find.text('Monitored Banking Apps'), findsOneWidget);
      expect(find.text('Nubank'), findsOneWidget);
      expect(find.text('com.nu.production'), findsOneWidget);
      expect(find.text('Sync Notifications Now'), findsOneWidget);
    });

    testWidgets('displays permission required when permission is not granted', (
      WidgetTester tester,
    ) async {
      bridgeService.permission = false;
      await notificationSyncProvider.checkPermission();

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Permission Required'), findsOneWidget);
      expect(find.text('Grant Access in Settings'), findsOneWidget);
    });

    testWidgets('toggling bank switch updates provider state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final nuSwitch = find.widgetWithText(SwitchListTile, 'Nubank');
      expect(nuSwitch, findsOneWidget);

      await tester.tap(nuSwitch);
      await tester.pumpAndSettle();

      expect(notificationSyncProvider.monitoredApps.first.isEnabled, isFalse);

      await tester.tap(nuSwitch);
      await tester.pumpAndSettle();

      expect(notificationSyncProvider.monitoredApps.first.isEnabled, isTrue);
    });

    testWidgets('adding a new bank app via dialog adds it to the list', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Add Bank App button
      await tester.tap(find.text('Add Bank App'));
      await tester.pumpAndSettle();

      expect(find.text('Bank Name'), findsOneWidget);
      expect(find.text('Android Package Name'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Nequi');
      await tester.enterText(textFields.at(1), 'com.nequi.MobileApp');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Nequi'), findsOneWidget);
      expect(find.text('com.nequi.MobileApp'), findsOneWidget);
      expect(notificationSyncProvider.monitoredApps.length, 2);
    });

    testWidgets('tapping sync notifications button triggers sync and shows snackbar', (
      WidgetTester tester,
    ) async {
      // Seed account and category
      final nuAccount = Account(
        id: 'acc_nu_credit',
        name: 'Nu',
        type: AccountType.creditCard,
        balanceCents: 0,
        currency: 'COP',
        colorHex: '#8A05BE',
        iconName: 'credit_card',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      await accountRepo.createAccount(nuAccount);

      final cat = Category(
        id: 'cat_groceries',
        name: 'Groceries',
        iconName: 'shopping_cart',
        colorHex: '#4CAF50',
        type: CategoryType.expense,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      await categoryRepo.createCategory(cat);

      // Buffer notification
      bridgeService.buffered = [
        {
          'packageName': 'com.nu.production',
          'notificationKey': 'com_nu_production_1726359000000_1001',
          'title': 'Compra aprobada por \$20.100,00',
          'body': 'Tu compra en BACOOS MARKET LINDEROS por \$20.100,00 con tu tarjeta terminada en 1394 ha sido APROBADA.',
          'postTime': 1726359000000,
        }
      ];

      geminiService.mockResult = InboxTransactionModel(
        id: 'pnotif_1',
        bankName: 'Nubank',
        accountType: 'credit_card',
        accountMask: '1394',
        merchant: 'BACOOS MARKET LINDEROS',
        amountCents: 2010000,
        amount: 20100.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Groceries',
        transactionDate: DateTime.now().toUtc(),
        referenceNumber: 'REF123',
        status: InboxStatus.pending,
        createdAt: DateTime.now().toUtc(),
      );

      await settingsProvider.setGeminiApiKey('mock_gemini_api_key');

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sync Notifications Now'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('✨ 1 transactions synced from notifications'), findsOneWidget);
    });
  });
}
