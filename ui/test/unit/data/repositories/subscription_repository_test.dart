import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late AccountRepositoryImpl accountRepository;
  late SubscriptionRepositoryImpl repository;

  final DateTime now = DateTime.parse('2026-09-05T12:00:00.000Z');

  final Account testBank = Account(
    id: 'acc-bank-sub',
    name: 'Checking Account',
    type: AccountType.bank,
    balanceCents: 500000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Account testCredit = Account(
    id: 'acc-cc-sub',
    name: 'Credit Card',
    type: AccountType.creditCard,
    balanceCents: 0,
    creditLimitCents: 200000,
    currency: 'USD',
    colorHex: '#2196F3',
    iconName: 'credit_card',
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
    repository = SubscriptionRepositoryImpl(databaseHelper: dbHelper);

    await accountRepository.createAccount(testBank);
    await accountRepository.createAccount(testCredit);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SubscriptionRepositoryImpl SQLite Operations', () {
    final Subscription netflix = Subscription(
      id: 'sub-netflix',
      name: 'Netflix Premium',
      amountCents: 1599, // $15.99
      frequency: RecurrenceFrequency.monthly,
      accountId: 'acc-cc-sub',
      categoryId: 'cat_default_subscriptions',
      billingDay: 15,
      nextDueDate: DateTime.parse('2026-09-15T00:00:00Z'),
      autoRegister: true,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final Subscription gym = Subscription(
      id: 'sub-gym',
      name: 'Gym Membership',
      amountCents: 5000, // $50.00
      frequency: RecurrenceFrequency.monthly,
      accountId: 'acc-bank-sub',
      categoryId: 'cat_default_health',
      billingDay: 1,
      nextDueDate: DateTime.parse('2026-10-01T00:00:00Z'),
      autoRegister: false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    test('creates and retrieves subscriptions correctly', () async {
      await repository.createSubscription(netflix);
      await repository.createSubscription(gym);

      final List<Subscription> all = await repository.getSubscriptions();
      expect(all.length, equals(2));

      final Subscription? retrieved = await repository.getSubscriptionById(
        'sub-netflix',
      );
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Netflix Premium'));
      expect(retrieved.amountCents, equals(1599));
      expect(retrieved.frequency, equals(RecurrenceFrequency.monthly));
      expect(retrieved.autoRegister, isTrue);
    });

    test('filters subscriptions by active status and account', () async {
      await repository.createSubscription(netflix);
      await repository.createSubscription(gym);

      // Filter by account
      final ccSubs = await repository.getSubscriptions(
        accountId: 'acc-cc-sub',
      );
      expect(ccSubs.length, equals(1));
      expect(ccSubs.first.id, equals('sub-netflix'));

      // Toggle gym inactive
      await repository.toggleActive('sub-gym', false);

      final activeSubs = await repository.getSubscriptions(isActive: true);
      expect(activeSubs.length, equals(1));
      expect(activeSubs.first.id, equals('sub-netflix'));

      final inactiveSubs = await repository.getSubscriptions(isActive: false);
      expect(inactiveSubs.length, equals(1));
      expect(inactiveSubs.first.id, equals('sub-gym'));
    });

    test('updates subscription details', () async {
      await repository.createSubscription(netflix);

      final updated = netflix.copyWith(
        name: 'Netflix 4K Ultra',
        amountCents: 2299,
      );
      await repository.updateSubscription(updated);

      final Subscription? retrieved = await repository.getSubscriptionById(
        'sub-netflix',
      );
      expect(retrieved!.name, equals('Netflix 4K Ultra'));
      expect(retrieved.amountCents, equals(2299));
    });

    test('updates next due date', () async {
      await repository.createSubscription(netflix);

      final nextMonth = DateTime.parse('2026-10-15T00:00:00Z');
      await repository.updateNextDueDate('sub-netflix', nextMonth);

      final Subscription? retrieved = await repository.getSubscriptionById(
        'sub-netflix',
      );
      expect(retrieved!.nextDueDate, equals(nextMonth));
    });

    test('deletes subscription from database', () async {
      await repository.createSubscription(netflix);
      await repository.deleteSubscription('sub-netflix');

      final Subscription? retrieved = await repository.getSubscriptionById(
        'sub-netflix',
      );
      expect(retrieved, isNull);
    });
  });
}
