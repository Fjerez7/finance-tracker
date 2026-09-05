import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late AccountRepositoryImpl accountRepository;
  late TransactionRepositoryImpl transactionRepository;

  final DateTime now = DateTime.parse('2026-09-04T12:00:00.000Z');

  final Account testBank = Account(
    id: 'acc-bank-1',
    name: 'Checking Account',
    type: AccountType.bank,
    balanceCents: 500000, // $5,000.00
    creditLimitCents: 0,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );

  final Account testCash = Account(
    id: 'acc-cash-1',
    name: 'Cash Wallet',
    type: AccountType.cash,
    balanceCents: 100000, // $1,000.00
    creditLimitCents: 0,
    currency: 'USD',
    colorHex: '#8BC34A',
    iconName: 'payments',
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );

  final Account testCreditCard = Account(
    id: 'acc-cc-1',
    name: 'Visa Signature',
    type: AccountType.creditCard,
    balanceCents: 20000, // $200.00 debt
    creditLimitCents: 300000, // $3,000.00 limit
    currency: 'USD',
    colorHex: '#2196F3',
    iconName: 'credit_card',
    isArchived: false,
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
    transactionRepository = TransactionRepositoryImpl(databaseHelper: dbHelper);

    // Seed test accounts
    await accountRepository.createAccount(testBank);
    await accountRepository.createAccount(testCash);
    await accountRepository.createAccount(testCreditCard);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('TransactionRepositoryImpl Operations & Balance Synchronization', () {
    test('creating an Expense on asset account deducts balance', () async {
      final tx = Transaction(
        id: 'tx-1',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_groceries',
        amountCents: 5000, // $50.00
        type: TransactionType.expense,
        description: 'Supermarket Groceries',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await transactionRepository.createTransaction(tx);

      final Transaction? retrieved = await transactionRepository
          .getTransactionById('tx-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.amountCents, equals(5000));

      final Account? updatedBank = await accountRepository.getAccountById(
        'acc-bank-1',
      );
      // 500000 - 5000 = 495000
      expect(updatedBank!.balanceCents, equals(495000));
    });

    test(
      'creating an Expense on Credit Card increases liability balance',
      () async {
        final tx = Transaction(
          id: 'tx-2',
          accountId: 'acc-cc-1',
          categoryId: 'cat_default_transport',
          amountCents: 15000, // $150.00
          type: TransactionType.expense,
          description: 'Flight ticket',
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await transactionRepository.createTransaction(tx);

        final Account? updatedCc = await accountRepository.getAccountById(
          'acc-cc-1',
        );
        // Debt increases: 20000 + 15000 = 35000
        expect(updatedCc!.balanceCents, equals(35000));
      },
    );

    test('creating an Income on asset account increases balance', () async {
      final tx = Transaction(
        id: 'tx-3',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_salary',
        amountCents: 200000, // $2,000.00
        type: TransactionType.income,
        description: 'Biweekly Salary',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await transactionRepository.createTransaction(tx);

      final Account? updatedBank = await accountRepository.getAccountById(
        'acc-bank-1',
      );
      // 500000 + 200000 = 700000
      expect(updatedBank!.balanceCents, equals(700000));
    });

    test(
      'creating a Transfer between assets deducts source and increases destination',
      () async {
        final tx = Transaction(
          id: 'tx-4',
          accountId: 'acc-bank-1',
          toAccountId: 'acc-cash-1',
          amountCents: 40000, // $400.00 ATM withdrawal
          type: TransactionType.transfer,
          description: 'ATM Cash Withdrawal',
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await transactionRepository.createTransaction(tx);

        final Account? updatedBank = await accountRepository.getAccountById(
          'acc-bank-1',
        );
        final Account? updatedCash = await accountRepository.getAccountById(
          'acc-cash-1',
        );

        // Bank: 500000 - 40000 = 460000
        expect(updatedBank!.balanceCents, equals(460000));
        // Cash: 100000 + 40000 = 140000
        expect(updatedCash!.balanceCents, equals(140000));
      },
    );

    test(
      'creating a Transfer from Bank to Credit Card pays off card debt',
      () async {
        final tx = Transaction(
          id: 'tx-5',
          accountId: 'acc-bank-1',
          toAccountId: 'acc-cc-1',
          amountCents: 20000, // $200.00
          type: TransactionType.transfer,
          description: 'Credit Card Payment',
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await transactionRepository.createTransaction(tx);

        final Account? updatedBank = await accountRepository.getAccountById(
          'acc-bank-1',
        );
        final Account? updatedCc = await accountRepository.getAccountById(
          'acc-cc-1',
        );

        // Bank: 500000 - 20000 = 480000
        expect(updatedBank!.balanceCents, equals(480000));
        // Credit Card debt paid off: 20000 - 20000 = 0
        expect(updatedCc!.balanceCents, equals(0));
      },
    );

    test('deleting a transaction reverses balance effects', () async {
      final tx = Transaction(
        id: 'tx-6',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_groceries',
        amountCents: 5000,
        type: TransactionType.expense,
        description: 'Erroneous charge',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await transactionRepository.createTransaction(tx);

      // Verify balance reduced
      Account? bank = await accountRepository.getAccountById('acc-bank-1');
      expect(bank!.balanceCents, equals(495000));

      // Delete transaction
      await transactionRepository.deleteTransaction('tx-6');

      final Transaction? deleted = await transactionRepository
          .getTransactionById('tx-6');
      expect(deleted, isNull);

      // Verify balance restored
      bank = await accountRepository.getAccountById('acc-bank-1');
      expect(bank!.balanceCents, equals(500000));
    });

    test('updating a transaction re-synchronizes account balances', () async {
      final tx = Transaction(
        id: 'tx-7',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_groceries',
        amountCents: 5000, // $50.00
        type: TransactionType.expense,
        description: 'Typo amount',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await transactionRepository.createTransaction(tx);

      // Update to $80.00 (8000 cents)
      final updatedTx = tx.copyWith(
        amountCents: 8000,
        description: 'Corrected amount',
      );
      await transactionRepository.updateTransaction(updatedTx);

      final Transaction? retrieved = await transactionRepository
          .getTransactionById('tx-7');
      expect(retrieved!.amountCents, equals(8000));
      expect(retrieved.description, equals('Corrected amount'));

      final Account? bank = await accountRepository.getAccountById(
        'acc-bank-1',
      );
      // 500000 - 8000 = 492000
      expect(bank!.balanceCents, equals(492000));
    });

    test('query filters work for date ranges, accounts, and types', () async {
      final tx1 = Transaction(
        id: 'tx-f1',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_groceries',
        amountCents: 1000,
        type: TransactionType.expense,
        description: 'Coffee',
        transactionDate: DateTime.parse('2026-09-01T10:00:00Z'),
        createdAt: now,
        updatedAt: now,
      );

      final tx2 = Transaction(
        id: 'tx-f2',
        accountId: 'acc-cash-1',
        categoryId: 'cat_default_transport',
        amountCents: 2000,
        type: TransactionType.expense,
        description: 'Taxi',
        transactionDate: DateTime.parse('2026-09-03T14:00:00Z'),
        createdAt: now,
        updatedAt: now,
      );

      final tx3 = Transaction(
        id: 'tx-f3',
        accountId: 'acc-bank-1',
        categoryId: 'cat_default_salary',
        amountCents: 50000,
        type: TransactionType.income,
        description: 'Bonus payment',
        transactionDate: DateTime.parse('2026-09-04T12:00:00Z'),
        createdAt: now,
        updatedAt: now,
      );

      await transactionRepository.createTransaction(tx1);
      await transactionRepository.createTransaction(tx2);
      await transactionRepository.createTransaction(tx3);

      // Filter by account
      final bankTxs = await transactionRepository.getTransactions(
        accountId: 'acc-bank-1',
      );
      expect(bankTxs.length, equals(2));

      // Filter by type
      final expenses = await transactionRepository.getTransactions(
        type: TransactionType.expense,
      );
      expect(expenses.length, equals(2));

      // Filter by date range
      final sep1ToSep2 = await transactionRepository.getTransactions(
        startDate: DateTime.parse('2026-09-01T00:00:00Z'),
        endDate: DateTime.parse('2026-09-02T23:59:59Z'),
      );
      expect(sep1ToSep2.length, equals(1));
      expect(sep1ToSep2.first.id, equals('tx-f1'));

      // Filter by query
      final bonusTxs = await transactionRepository.getTransactions(
        query: 'Bonus',
      );
      expect(bonusTxs.length, equals(1));
      expect(bonusTxs.first.id, equals('tx-f3'));

      // Count check
      final count = await transactionRepository.getTransactionCount(
        accountId: 'acc-bank-1',
      );
      expect(count, equals(2));
    });
  });
}
