import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/category_repository_impl.dart';
import 'package:finance_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late AccountRepositoryImpl accountRepository;
  late CategoryRepositoryImpl categoryRepository;
  late TransactionRepositoryImpl transactionRepository;
  late AccountsProvider accountsProvider;
  late TransactionsProvider transactionsProvider;

  final DateTime now = DateTime.parse('2026-09-04T12:00:00.000Z');

  final Account testBank = Account(
    id: 'acc-bank-1',
    name: 'Main Checking',
    type: AccountType.bank,
    balanceCents: 100000, // $1,000.00
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    accountRepository = AccountRepositoryImpl(databaseHelper: dbHelper);
    categoryRepository = CategoryRepositoryImpl(databaseHelper: dbHelper);
    transactionRepository = TransactionRepositoryImpl(databaseHelper: dbHelper);

    await accountRepository.createAccount(testBank);

    accountsProvider = AccountsProvider(repository: accountRepository);
    await accountsProvider.loadAccounts();

    transactionsProvider = TransactionsProvider(
      transactionRepository: transactionRepository,
      categoryRepository: categoryRepository,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('TransactionsProvider State Management', () {
    test('initializes and loads default seeded categories', () async {
      await transactionsProvider.initialize();

      expect(transactionsProvider.categories.length, equals(15));
      expect(transactionsProvider.expenseCategories.isNotEmpty, isTrue);
      expect(transactionsProvider.incomeCategories.isNotEmpty, isTrue);
      expect(transactionsProvider.transactions.isEmpty, isTrue);
    });

    test(
      'addTransaction creates record, updates list, and refreshes AccountsProvider',
      () async {
        await transactionsProvider.initialize();

        final tx = Transaction(
          id: 'tx-p1',
          accountId: 'acc-bank-1',
          categoryId: 'cat_default_groceries',
          amountCents: 15000, // $150.00
          type: TransactionType.expense,
          description: 'Weekly Market',
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await transactionsProvider.addTransaction(
          tx,
          accountsProvider: accountsProvider,
        );

        expect(transactionsProvider.transactions.length, equals(1));
        expect(transactionsProvider.recentTransactions.length, equals(1));
        expect(transactionsProvider.totalExpenseCents, equals(15000));
        expect(transactionsProvider.totalIncomeCents, equals(0));
        expect(transactionsProvider.netCashFlowCents, equals(-15000));

        // Verify AccountsProvider refreshed Net Worth & balance: $1,000 - $150 = $850 (85,000 cents)
        expect(accountsProvider.totalAssetsCents, equals(85000));
        expect(accountsProvider.netWorthCents, equals(85000));
      },
    );

    test('income transaction calculation updates cashflow metrics', () async {
      await transactionsProvider.initialize();

      final expenseTx = Transaction(
        id: 'tx-p2',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_food',
        amountCents: 2000, // $20.00
        type: TransactionType.expense,
        description: 'Lunch',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final incomeTx = Transaction(
        id: 'tx-p3',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_salary',
        amountCents: 50000, // $500.00
        type: TransactionType.income,
        description: 'Bonus',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await transactionsProvider.addTransaction(
        expenseTx,
        accountsProvider: accountsProvider,
      );
      await transactionsProvider.addTransaction(
        incomeTx,
        accountsProvider: accountsProvider,
      );

      expect(transactionsProvider.transactions.length, equals(2));
      expect(transactionsProvider.totalExpenseCents, equals(2000));
      expect(transactionsProvider.totalIncomeCents, equals(50000));
      expect(transactionsProvider.netCashFlowCents, equals(48000));
    });

    test('deleteTransaction updates lists and accountsProvider', () async {
      await transactionsProvider.initialize();

      final tx = Transaction(
        id: 'tx-del-1',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_transport',
        amountCents: 3000,
        type: TransactionType.expense,
        description: 'Train ticket',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await transactionsProvider.addTransaction(
        tx,
        accountsProvider: accountsProvider,
      );
      expect(transactionsProvider.transactions.length, equals(1));
      expect(accountsProvider.totalAssetsCents, equals(97000));

      await transactionsProvider.deleteTransaction(
        'tx-del-1',
        accountsProvider: accountsProvider,
      );
      expect(transactionsProvider.transactions.isEmpty, isTrue);
      expect(accountsProvider.totalAssetsCents, equals(100000));
    });

    test('filter manipulation updates filtered transactions query', () async {
      await transactionsProvider.initialize();

      final txExpense = Transaction(
        id: 'tx-f-exp',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_groceries',
        amountCents: 4500,
        type: TransactionType.expense,
        description: 'Supermarket',
        transactionDate: DateTime.parse('2026-09-01T10:00:00Z'),
        createdAt: now,
        updatedAt: now,
      );

      final txIncome = Transaction(
        id: 'tx-f-inc',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_salary',
        amountCents: 150000,
        type: TransactionType.income,
        description: 'Main salary paycheck',
        transactionDate: DateTime.parse('2026-09-03T10:00:00Z'),
        createdAt: now,
        updatedAt: now,
      );

      await transactionsProvider.addTransaction(txExpense);
      await transactionsProvider.addTransaction(txIncome);

      // Filter by type expense
      transactionsProvider.setFilterType(TransactionType.expense);
      await pumpEventQueue();
      expect(transactionsProvider.transactions.length, equals(1));
      expect(transactionsProvider.transactions.first.id, equals('tx-f-exp'));

      // Filter by search query
      transactionsProvider.clearFilters();
      transactionsProvider.setSearchQuery('paycheck');
      await pumpEventQueue();
      expect(transactionsProvider.transactions.length, equals(1));
      expect(transactionsProvider.transactions.first.id, equals('tx-f-inc'));
    });

    test('custom category creation and resolution', () async {
      await transactionsProvider.initialize();

      final customCat = Category(
        id: 'cat-user-tech',
        name: 'Tech Gadgets',
        iconName: 'devices',
        colorHex: '#3F51B5',
        type: CategoryType.expense,
        createdAt: now,
        updatedAt: now,
      );

      await transactionsProvider.addCategory(customCat);

      final resolved = transactionsProvider.getCategoryById('cat-user-tech');
      expect(resolved, isNotNull);
      expect(resolved!.name, equals('Tech Gadgets'));
    });
  });
}
