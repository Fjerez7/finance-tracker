import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/core/constants/database_constants.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';

void main() {
  // Initialize FFI for headless desktop SQLite testing
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late Database db;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    // Ensure previous connection is closed
    await dbHelper.close();
    db = await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('DatabaseHelper SQLite Schema & Initialization', () {
    test('initializes and creates all 6 core tables and seed data', () async {
      expect(db.isOpen, isTrue);

      // Verify tables exist
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );

      final List<String> tableNames = tables
          .map((t) => t['name'] as String)
          .toList();

      expect(
        tableNames,
        containsAll([
          DatabaseConstants.tableAccounts,
          DatabaseConstants.tableCategories,
          DatabaseConstants.tableTransactions,
          DatabaseConstants.tableSubscriptions,
          DatabaseConstants.tableBudgets,
          DatabaseConstants.tableSavingsGoals,
        ]),
      );

      // Verify seeded categories
      final List<Map<String, dynamic>> categories = await db.query(
        DatabaseConstants.tableCategories,
      );

      expect(categories.length, greaterThanOrEqualTo(15));
      final List<String> catNames = categories
          .map((c) => c[DatabaseConstants.colName] as String)
          .toList();
      expect(catNames, contains('Groceries'));
      expect(catNames, contains('Salary & Payroll'));
      expect(catNames, contains('Food & Dining'));
    });

    test('enforces foreign keys on transactions', () async {
      final String now = DateTime.now().toUtc().toIso8601String();

      // Inserting transaction with non-existent account must fail with Foreign Key violation
      expect(
        () async => await db.insert(DatabaseConstants.tableTransactions, {
          DatabaseConstants.colId: 'tx-invalid-acc',
          DatabaseConstants.colAccountId: 'acc-does-not-exist',
          DatabaseConstants.colAmountCents: 5000,
          DatabaseConstants.colTransactionType: 'expense',
          DatabaseConstants.colTransactionDate: now,
          DatabaseConstants.colCreatedAt: now,
          DatabaseConstants.colUpdatedAt: now,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test(
      'enforces CHECK constraint on transaction positive amount_cents',
      () async {
        final String now = DateTime.now().toUtc().toIso8601String();

        // Create a valid account first
        await db.insert(DatabaseConstants.tableAccounts, {
          DatabaseConstants.colId: 'acc-valid-1',
          DatabaseConstants.colName: 'Main Bank',
          DatabaseConstants.colAccountType: 'bank',
          DatabaseConstants.colBalanceCents: 10000,
          DatabaseConstants.colCreditLimitCents: 0,
          DatabaseConstants.colCurrency: 'USD',
          DatabaseConstants.colColorHex: '#4CAF50',
          DatabaseConstants.colIconName: 'account_balance',
          DatabaseConstants.colIsArchived: 0,
          DatabaseConstants.colCreatedAt: now,
          DatabaseConstants.colUpdatedAt: now,
        });

        // Inserting transaction with zero amount must violate CHECK constraint
        expect(
          () async => await db.insert(DatabaseConstants.tableTransactions, {
            DatabaseConstants.colId: 'tx-zero-amount',
            DatabaseConstants.colAccountId: 'acc-valid-1',
            DatabaseConstants.colAmountCents: 0,
            DatabaseConstants.colTransactionType: 'expense',
            DatabaseConstants.colTransactionDate: now,
            DatabaseConstants.colCreatedAt: now,
            DatabaseConstants.colUpdatedAt: now,
          }),
          throwsA(isA<DatabaseException>()),
        );

        // Inserting transaction with negative amount must violate CHECK constraint
        expect(
          () async => await db.insert(DatabaseConstants.tableTransactions, {
            DatabaseConstants.colId: 'tx-neg-amount',
            DatabaseConstants.colAccountId: 'acc-valid-1',
            DatabaseConstants.colAmountCents: -500,
            DatabaseConstants.colTransactionType: 'expense',
            DatabaseConstants.colTransactionDate: now,
            DatabaseConstants.colCreatedAt: now,
            DatabaseConstants.colUpdatedAt: now,
          }),
          throwsA(isA<DatabaseException>()),
        );
      },
    );

    test('verifies indexes exist', () async {
      final List<Map<String, dynamic>> indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index';",
      );
      final List<String> indexNames = indexes
          .map((i) => i['name'] as String)
          .toList();

      expect(indexNames, contains('idx_transactions_date'));
      expect(indexNames, contains('idx_transactions_account'));
      expect(indexNames, contains('idx_subscriptions_due_date'));
      expect(indexNames, contains('idx_budgets_period'));
    });
  });
}
