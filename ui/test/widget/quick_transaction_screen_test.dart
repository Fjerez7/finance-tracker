import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/presentation/screens/transactions/quick_transaction_screen.dart';
import 'package:finance_tracker/presentation/widgets/common/calculator_numpad.dart';
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
  Future<List<Category>> getCategories({CategoryType? type}) async {
    if (type != null) {
      return categories.where((c) => c.type == type).toList();
    }
    return categories;
  }

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
  final now = DateTime.parse('2026-09-04T12:00:00Z');

  final Account testAccount = Account(
    id: 'acc-1',
    name: 'Cash Wallet',
    type: AccountType.cash,
    balanceCents: 50000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'payments',
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
    Category(
      id: 'cat-salary',
      name: 'Salary',
      iconName: 'payments',
      colorHex: '#2196F3',
      type: CategoryType.income,
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
      child: const MaterialApp(home: QuickTransactionScreen()),
    );
  }

  group('QuickTransactionScreen Widget Tests', () {
    testWidgets(
      'renders type segmented buttons, amount, and calculator numpad',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        expect(find.text('Add Transaction'), findsOneWidget);
        expect(find.text('Expense'), findsOneWidget);
        expect(find.text('Income'), findsOneWidget);
        expect(find.text('Transfer'), findsOneWidget);
        expect(find.byType(CalculatorNumpad), findsOneWidget);
      },
    );

    testWidgets('entering amount and selecting category creates expense', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Tap 2, 5 -> $25.00
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();

      // Tap category Groceries
      final groceriesFinder = find.text('Groceries');
      expect(groceriesFinder, findsOneWidget);

      await tester.tap(groceriesFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(txRepo.transactions.length, equals(1));
      expect(txRepo.transactions.first.amountCents, equals(2500));
      expect(txRepo.transactions.first.type, equals(TransactionType.expense));
    });
  });
}
