import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/inbox_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/domain/usecases/sync_inbox_transactions_usecase.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/settings/gmail_sync_settings_screen.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/inbox_sync_provider.dart';
import 'package:finance_tracker/providers/settings_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class MockInboxRepo implements InboxRepository {
  @override
  Future<List<InboxTransaction>> getPendingTransactions({String userId = 'user_default'}) async => [];

  @override
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'}) async {}

  @override
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'}) async {}

  @override
  Future<int> syncPendingTransactions({String userId = 'user_default'}) async => 0;

  @override
  Future<int> syncDirectFromGmail({
    required Map<String, String> authHeaders,
    required String geminiApiKey,
    List<String>? bankSenders,
  }) async => 0;
}

class FakeAccountRepo implements AccountRepository {
  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async => [];
  @override
  Future<void> createAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async {}
  @override
  Future<Account?> getAccountById(String id) async => null;
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeTransactionRepo implements TransactionRepository {
  @override
  Future<void> createTransaction(Transaction transaction) async {}
  @override
  Future<Transaction?> getTransactionById(String id) async => null;
  @override
  Future<void> deleteTransaction(String id) async {}
  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async => [];
  @override
  Future<List<Transaction>> getTransactions({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    int? limit,
    int? offset,
  }) async => [];
  @override
  Future<void> updateTransaction(Transaction transaction) async {}
  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async => 0;
}

class FakeCategoryRepo implements CategoryRepository {
  @override
  Future<List<Category>> getCategories({CategoryType? type}) async => [];
  @override
  Future<void> createCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
  @override
  Future<Category?> getCategoryById(String id) async => null;
  @override
  Future<void> updateCategory(Category category) async {}
}

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late SettingsProvider settingsProvider;
  late InboxSyncProvider inboxSyncProvider;
  late AccountsProvider accountsProvider;
  late TransactionsProvider transactionsProvider;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    settingsProvider = SettingsProvider(dbHelper: dbHelper);
    await settingsProvider.loadSettings();

    inboxSyncProvider = InboxSyncProvider(
      syncUseCase: SyncInboxTransactionsUseCase(MockInboxRepo()),
    );

    accountsProvider = AccountsProvider(repository: FakeAccountRepo());
    transactionsProvider = TransactionsProvider(
      transactionRepository: FakeTransactionRepo(),
      categoryRepository: FakeCategoryRepo(),
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<InboxSyncProvider>.value(value: inboxSyncProvider),
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProvider),
        ChangeNotifierProvider<TransactionsProvider>.value(value: transactionsProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GmailSyncSettingsScreen(),
      ),
    );
  }

  group('GmailSyncSettingsScreen Widget Tests', () {
    testWidgets('renders all configuration cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Gmail Bank Synchronization'), findsOneWidget);
      expect(find.text('Google Account'), findsOneWidget);
      expect(find.text('Gemini API Key'), findsOneWidget);
      expect(find.text('Monitored Bank Senders'), findsOneWidget);
      expect(find.text('Automatic Background Sync'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
    });

    testWidgets('saving Gemini API Key updates provider and settings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final apiKeyField = find.byType(TextField).first;
      await tester.enterText(apiKeyField, 'test_gemini_api_key_123');

      final saveButton = find.byIcon(Icons.save).first;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(settingsProvider.geminiApiKey, equals('test_gemini_api_key_123'));
    });
  });
}
