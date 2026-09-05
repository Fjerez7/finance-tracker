import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/presentation/screens/transactions/transaction_list_screen.dart';
import 'package:finance_tracker/presentation/widgets/cards/transaction_list_tile.dart';
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
  }) async {
    return transactions.where((t) {
      if (type != null && t.type != type) return false;
      if (query != null &&
          query.isNotEmpty &&
          !t.description.toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

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
  final now = DateTime.parse('2026-09-04T12:00:00Z');

  final Account testAccount = Account(
    id: 'acc-1',
    name: 'Main Checking',
    type: AccountType.bank,
    balanceCents: 200000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final List<Category> testCategories = [
    Category(
      id: 'cat-groceries',
      name: 'Groceries',
      iconName: 'shopping_cart',
      colorHex: '#4CAF50',
      type: CategoryType.expense,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  late FakeAccountRepo accountRepo;
  late FakeCategoryRepo categoryRepo;
  late FakeTransactionRepo txRepo;
  late AccountsProvider accountsProvider;
  late TransactionsProvider txProvider;

  setUp(() async {
    accountRepo = FakeAccountRepo([testAccount]);
    categoryRepo = FakeCategoryRepo(testCategories);
    txRepo = FakeTransactionRepo();

    accountsProvider = AccountsProvider(repository: accountRepo);
    await accountsProvider.loadAccounts();

    txProvider = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: categoryRepo,
    );
    await txProvider.initialize();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProvider),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProvider),
      ],
      child: const MaterialApp(home: TransactionListScreen()),
    );
  }

  group('TransactionListScreen Widget Tests', () {
    testWidgets('renders empty state when no transactions exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Expenses'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Income'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Transfers'), findsOneWidget);
    });

    testWidgets('renders transaction items and filter chips', (
      WidgetTester tester,
    ) async {
      final tx = Transaction(
        id: 'tx-w-1',
        accountId: 'acc-1',
        categoryId: 'cat-groceries',
        amountCents: 4500, // $45.00
        type: TransactionType.expense,
        description: 'Supermarket weekly groceries',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await txProvider.addTransaction(tx);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(TransactionListTile), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Supermarket weekly groceries'), findsOneWidget);
    });
  });
}
