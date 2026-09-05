import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late AccountRepositoryImpl repository;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    // Initialize DB
    await dbHelper.database;

    repository = AccountRepositoryImpl(databaseHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('AccountRepositoryImpl SQLite Operations', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Account testBank = Account(
      id: 'acc-bank-1',
      name: 'Main Checking',
      type: AccountType.bank,
      balanceCents: 250000,
      creditLimitCents: 0,
      currency: 'USD',
      colorHex: '#4CAF50',
      iconName: 'account_balance',
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );

    final Account testCredit = Account(
      id: 'acc-cc-1',
      name: 'Visa Signature',
      type: AccountType.creditCard,
      balanceCents: 45000,
      creditLimitCents: 300000,
      currency: 'USD',
      colorHex: '#2196F3',
      iconName: 'credit_card',
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );

    test('creates and retrieves accounts correctly', () async {
      await repository.createAccount(testBank);
      await repository.createAccount(testCredit);

      final List<Account> accounts = await repository.getAccounts();
      expect(accounts.length, equals(2));

      final Account? retrievedBank = await repository.getAccountById(
        'acc-bank-1',
      );
      expect(retrievedBank, isNotNull);
      expect(retrievedBank!.name, equals('Main Checking'));
      expect(retrievedBank.balanceCents, equals(250000));
      expect(retrievedBank.type, equals(AccountType.bank));
    });

    test('updates account details accurately', () async {
      await repository.createAccount(testBank);

      final Account updated = testBank.copyWith(
        name: 'Primary Checking Updated',
        balanceCents: 300000,
      );

      await repository.updateAccount(updated);

      final Account? retrieved = await repository.getAccountById('acc-bank-1');
      expect(retrieved!.name, equals('Primary Checking Updated'));
      expect(retrieved.balanceCents, equals(300000));
    });

    test('adjusts balance directly', () async {
      await repository.createAccount(testBank);

      await repository.adjustBalance('acc-bank-1', 500000);

      final Account? retrieved = await repository.getAccountById('acc-bank-1');
      expect(retrieved!.balanceCents, equals(500000));
    });

    test('archives and filters accounts', () async {
      await repository.createAccount(testBank);
      await repository.createAccount(testCredit);

      await repository.setArchived('acc-bank-1', true);

      // Active only
      final List<Account> active = await repository.getAccounts(
        includeArchived: false,
      );
      expect(active.length, equals(1));
      expect(active.first.id, equals('acc-cc-1'));

      // All including archived
      final List<Account> all = await repository.getAccounts(
        includeArchived: true,
      );
      expect(all.length, equals(2));
    });

    test('deletes account from database', () async {
      await repository.createAccount(testBank);

      await repository.deleteAccount('acc-bank-1');

      final Account? retrieved = await repository.getAccountById('acc-bank-1');
      expect(retrieved, isNull);
    });
  });
}
