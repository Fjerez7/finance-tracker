import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/models/inbox_transaction_model.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/category_repository_impl.dart';
import 'package:finance_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';
import 'package:finance_tracker/providers/notification_sync_provider.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late FakeNotificationBridgeService bridgeService;
  late FakeGeminiExtractionService geminiService;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl transactionRepo;
  late NotificationSyncProvider provider;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    bridgeService = FakeNotificationBridgeService();
    geminiService = FakeGeminiExtractionService();
    accountRepo = AccountRepositoryImpl(databaseHelper: dbHelper);
    categoryRepo = CategoryRepositoryImpl(databaseHelper: dbHelper);
    transactionRepo = TransactionRepositoryImpl(databaseHelper: dbHelper);

    provider = NotificationSyncProvider(
      dbHelper: dbHelper,
      bridgeService: bridgeService,
      geminiService: geminiService,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('NotificationSyncProvider Unit Tests', () {
    test('initial state initializes Nubank default and syncs packages', () async {
      expect(provider.isInitialized, isFalse);

      await provider.initialize();

      expect(provider.isInitialized, isTrue);
      expect(provider.isPermissionGranted, isTrue);
      expect(provider.monitoredApps.length, 1);
      expect(provider.monitoredApps.first.packageName, 'com.nu.production');
      expect(provider.monitoredApps.first.displayName, 'Nubank');
      expect(bridgeService.syncedPackages, contains('com.nu.production'));
    });

    test('addMonitoredBankApp adds package and syncs whitelist', () async {
      await provider.initialize();

      final added = await provider.addMonitoredBankApp(
        displayName: 'Nequi',
        packageName: 'com.nequi.MobileApp',
      );

      expect(added, isTrue);
      expect(provider.monitoredApps.length, 2);
      expect(bridgeService.syncedPackages, contains('com.nequi.MobileApp'));

      // Duplicate package should fail
      final duplicate = await provider.addMonitoredBankApp(
        displayName: 'Nequi Clone',
        packageName: 'com.nequi.MobileApp',
      );
      expect(duplicate, isFalse);
    });

    test('toggleBankApp updates state and syncs to native bridge', () async {
      await provider.initialize();

      await provider.toggleBankApp('nubank', false);
      expect(provider.monitoredApps.first.isEnabled, isFalse);
      expect(provider.activeApps.isEmpty, isTrue);
      expect(bridgeService.syncedPackages.isEmpty, isTrue);

      await provider.toggleBankApp('nubank', true);
      expect(provider.monitoredApps.first.isEnabled, isTrue);
      expect(bridgeService.syncedPackages, contains('com.nu.production'));
    });

    test('syncPendingNotifications parses buffered notification and creates transaction', () async {
      // Create a Nu Credit Card account
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

      // Create a Category
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

      // Buffer a notification
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

      await provider.initialize();

      final syncedCount = await provider.syncPendingNotifications(
        geminiApiKey: 'test_key',
        accountRepository: accountRepo,
        categoryRepository: categoryRepo,
        transactionRepository: transactionRepo,
      );

      expect(syncedCount, 1);
      expect(provider.lastSyncCount, 1);

      // Verify transaction in SQLite
      final txs = await transactionRepo.getTransactions();
      expect(txs.length, 1);
      expect(txs.first.amountCents, 2010000);
      expect(txs.first.description, 'BACOOS MARKET LINDEROS');
      expect(txs.first.accountId, 'acc_nu_credit');

      // Verify account liability balance updated
      final updatedAcc = await accountRepo.getAccountById('acc_nu_credit');
      expect(updatedAcc?.balanceCents, 2010000); // Credit card debt increased
    });

    test('syncPendingNotifications discards debit card notification when only credit card account exists', () async {
      // User only has a Nu Credit Card account
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

      // Debit notification received
      bridgeService.buffered = [
        {
          'packageName': 'com.nu.production',
          'notificationKey': 'com_nu_production_debit_1002',
          'title': 'Compra con tarjeta de débito',
          'body': 'Pagaste \$50.000 con tu tarjeta de débito Nu en Restaurante.',
          'postTime': 1726359000000,
        }
      ];

      geminiService.mockResult = InboxTransactionModel(
        id: 'pnotif_2',
        bankName: 'Nu',
        accountType: 'debit_card',
        accountMask: '5678',
        merchant: 'Restaurante',
        amountCents: 5000000,
        amount: 50000.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Food & Dining',
        transactionDate: DateTime.now().toUtc(),
        referenceNumber: 'REFDEB',
        status: InboxStatus.pending,
        createdAt: DateTime.now().toUtc(),
      );

      await provider.initialize();

      final syncedCount = await provider.syncPendingNotifications(
        geminiApiKey: 'test_key',
        accountRepository: accountRepo,
        categoryRepository: categoryRepo,
        transactionRepository: transactionRepo,
      );

      expect(syncedCount, 0);
      expect(provider.lastSyncCount, 0);

      final txs = await transactionRepo.getTransactions();
      expect(txs.isEmpty, isTrue);
    });

    test('syncPendingNotifications discards promotional or non-transaction notification', () async {
      bridgeService.buffered = [
        {
          'packageName': 'com.nu.production',
          'notificationKey': 'com_nu_production_promo_1003',
          'title': '¡Abre tu cajita Nu!',
          'body': 'Haz crecer tu dinero con una tasa del 13% E.A.',
          'postTime': 1726359000000,
        }
      ];

      // Gemini returns null for marketing/promotions (is_transaction = false)
      geminiService.mockResult = null;

      await provider.initialize();

      final syncedCount = await provider.syncPendingNotifications(
        geminiApiKey: 'test_key',
        accountRepository: accountRepo,
        categoryRepository: categoryRepo,
        transactionRepository: transactionRepo,
      );

      expect(syncedCount, 0);
      expect(provider.lastSyncCount, 0);

      final txs = await transactionRepo.getTransactions();
      expect(txs.isEmpty, isTrue);
    });
  });
}
