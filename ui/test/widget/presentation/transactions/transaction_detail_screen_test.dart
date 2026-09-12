import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/transactions/transaction_detail_screen.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeAccountRepo implements AccountRepository {
  final List<Account> accounts;
  FakeAccountRepo(this.accounts);
  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async =>
      accounts;
  @override
  Future<Account?> getAccountById(String id) async =>
      accounts.where((a) => a.id == id).firstOrNull;
  @override
  Future<void> createAccount(Account account) async => accounts.add(account);
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async {}
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeCategoryRepo implements CategoryRepository {
  final List<Category> categories;
  FakeCategoryRepo(this.categories);
  @override
  Future<List<Category>> getCategories({CategoryType? type}) async =>
      categories;
  @override
  Future<Category?> getCategoryById(String id) async =>
      categories.where((c) => c.id == id).firstOrNull;
  @override
  Future<void> createCategory(Category category) async =>
      categories.add(category);
  @override
  Future<void> updateCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

class FakeTransactionRepo implements TransactionRepository {
  final List<Transaction> transactions = [];
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
  }) async => List.from(transactions);
  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async =>
      List.from(transactions);
  @override
  Future<Transaction?> getTransactionById(String id) async =>
      transactions.where((t) => t.id == id).firstOrNull;
  @override
  Future<void> createTransaction(Transaction transaction) async =>
      transactions.add(transaction);
  @override
  Future<void> updateTransaction(Transaction transaction) async {}
  @override
  Future<void> deleteTransaction(String id) async =>
      transactions.removeWhere((t) => t.id == id);
  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async => transactions.length;
}

void main() {
  final now = DateTime.parse('2026-09-06T12:00:00Z');

  final Account testAccount = Account(
    id: 'acc-usd-1',
    name: 'Main Checking',
    type: AccountType.bank,
    balanceCents: 500000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Category testCategory = Category(
    id: 'cat-shopping',
    name: 'Shopping',
    iconName: 'shopping_bag',
    colorHex: '#9C27B0',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  late FakeAccountRepo accountRepo;
  late FakeCategoryRepo categoryRepo;
  late FakeTransactionRepo txRepo;
  late AccountsProvider accountsProvider;
  late TransactionsProvider txProvider;

  setUp(() async {
    accountRepo = FakeAccountRepo([testAccount]);
    categoryRepo = FakeCategoryRepo([testCategory]);
    txRepo = FakeTransactionRepo();

    accountsProvider = AccountsProvider(repository: accountRepo);
    await accountsProvider.loadAccounts();

    txProvider = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: categoryRepo,
    );
    await txProvider.initialize();
  });

  Widget buildTestableWidget(Transaction tx) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProvider),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProvider),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TransactionDetailScreen(transaction: tx),
      ),
    );
  }

  group('TransactionDetailScreen Widget Tests', () {
    testWidgets('renders standard transaction details correctly', (
      WidgetTester tester,
    ) async {
      final tx = Transaction(
        id: 'tx-std-1',
        accountId: 'acc-usd-1',
        categoryId: 'cat-shopping',
        amountCents: 4999, // $49.99
        type: TransactionType.expense,
        description: 'New shoes',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestableWidget(tx));
      await tester.pumpAndSettle();

      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('-\$49.99'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Main Checking'), findsOneWidget);
      expect(find.text('New shoes'), findsOneWidget);
      expect(find.text('tx-std-1'), findsOneWidget);
    });

    testWidgets('renders foreign multi-currency transaction with conversion details', (
      WidgetTester tester,
    ) async {
      final tx = Transaction(
        id: 'tx-foreign-2',
        accountId: 'acc-usd-1',
        categoryId: 'cat-shopping',
        amountCents: 1500, // $15.00 USD debited
        originalCurrency: 'COP',
        originalAmountCents: 6225000, // 62,250.00 COP
        exchangeRate: 0.00024096, // 1 / 4150
        type: TransactionType.expense,
        description: 'Airport duty free',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestableWidget(tx));
      await tester.pumpAndSettle();

      expect(find.text('Transaction Details'), findsOneWidget);
      // Hero displays foreign amount with converted subtitle
      expect(find.text('-COP 62,250.00'), findsOneWidget);
      expect(find.text('(~-\$15.00)'), findsOneWidget);

      // Metadata card displays detailed rows
      expect(find.text('Original Amount'), findsOneWidget);
      expect(find.text('COP 62,250.00 COP'), findsOneWidget);
      expect(find.text('Exchange Rate'), findsOneWidget);
      expect(find.text('Debited from account'), findsOneWidget);
      expect(find.text('\$15.00 USD'), findsOneWidget);
    });
  });
}
