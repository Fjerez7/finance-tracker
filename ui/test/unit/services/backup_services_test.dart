import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/core/constants/database_constants.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/services/backup_restore_service.dart';
import 'package:finance_tracker/services/csv_export_service.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late Database db;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    db = await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('CsvExportService Tests', () {
    test('exports transactions with correct headers, decimal conversion and escaping', () {
      final now = DateTime(2026, 9, 5, 14, 30, 0);

      final account = Account(
        id: 'acc-1',
        name: 'Checking, Main',
        type: AccountType.bank,
        currency: 'USD',
        balanceCents: 150000,
        colorHex: '#4CAF50',
        iconName: 'account_balance',
        createdAt: now,
        updatedAt: now,
      );

      final category = Category(
        id: 'cat-1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorHex: '#FF5722',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      final transaction = Transaction(
        id: 'tx-1',
        accountId: 'acc-1',
        categoryId: 'cat-1',
        amountCents: 4550, // $45.50
        type: TransactionType.expense,
        description: 'Dinner "special", with wine',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final csv = CsvExportService.exportTransactionsToCsv(
        transactions: [transaction],
        accounts: [account],
        categories: [category],
      );

      expect(csv, contains('ID,Date,Account,Category,Type,Amount_Formatted,Amount_Cents,Description'));
      expect(csv, contains('tx-1,2026-09-05 14:30:00,"Checking, Main",Food & Dining,expense,45.50,4550,"Dinner ""special"", with wine"'));
    });
  });

  group('BackupRestoreService Tests', () {
    test('creates full database snapshot with valid SHA-256 checksum and restores atomically', () async {
      final String now = DateTime.now().toUtc().toIso8601String();

      // 1. Insert seed account and transaction
      await db.insert(DatabaseConstants.tableAccounts, {
        DatabaseConstants.colId: 'acc-test-1',
        DatabaseConstants.colName: 'Savings Vault',
        DatabaseConstants.colAccountType: 'bank',
        DatabaseConstants.colBalanceCents: 500000,
        DatabaseConstants.colCreditLimitCents: 0,
        DatabaseConstants.colCurrency: 'USD',
        DatabaseConstants.colColorHex: '#4CAF50',
        DatabaseConstants.colIconName: 'account_balance',
        DatabaseConstants.colIsArchived: 0,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      });

      await db.insert(DatabaseConstants.tableTransactions, {
        DatabaseConstants.colId: 'tx-test-1',
        DatabaseConstants.colAccountId: 'acc-test-1',
        DatabaseConstants.colCategoryId: 'cat_default_salary',
        DatabaseConstants.colAmountCents: 500000,
        DatabaseConstants.colTransactionType: 'income',
        DatabaseConstants.colDescription: 'Initial Deposit',
        DatabaseConstants.colTransactionDate: now,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      });

      // 2. Create snapshot
      final snapshot = await BackupRestoreService.createBackupSnapshot(db);

      expect(snapshot['version'], equals(1));
      expect(snapshot['checksum'], isA<String>());
      expect(snapshot['data'], isA<Map<String, dynamic>>());

      // Validate snapshot structure
      expect(() => BackupRestoreService.validateSnapshot(snapshot), returnsNormally);

      // 3. Clear database / insert dummy records that will be overwritten
      await db.delete(DatabaseConstants.tableTransactions);
      await db.delete(DatabaseConstants.tableAccounts);

      final accountsAfterClear = await db.query(DatabaseConstants.tableAccounts);
      expect(accountsAfterClear, isEmpty);

      // 4. Restore from snapshot
      await BackupRestoreService.restoreFromSnapshot(db, snapshot);

      // 5. Verify restored state
      final restoredAccounts = await db.query(DatabaseConstants.tableAccounts);
      expect(restoredAccounts.length, equals(1));
      expect(restoredAccounts.first['name'], equals('Savings Vault'));

      final restoredTxs = await db.query(DatabaseConstants.tableTransactions);
      expect(restoredTxs.length, equals(1));
      expect(restoredTxs.first['description'], equals('Initial Deposit'));
    });

    test('throws BackupValidationException when snapshot data has been tampered with', () async {
      final snapshot = await BackupRestoreService.createBackupSnapshot(db);

      // Tamper with data payload
      final tamperedData = Map<String, dynamic>.from(snapshot['data'] as Map);
      tamperedData['tampered_field'] = 'corrupted_value';

      final tamperedSnapshot = {
        'version': snapshot['version'],
        'exportedAt': snapshot['exportedAt'],
        'checksum': snapshot['checksum'], // original checksum mismatch
        'data': tamperedData,
      };

      expect(
        () => BackupRestoreService.validateSnapshot(tamperedSnapshot),
        throwsA(isA<BackupValidationException>()),
      );
    });
  });
}
