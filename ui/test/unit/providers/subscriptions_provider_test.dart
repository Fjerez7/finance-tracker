import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/account_repository_impl.dart';
import 'package:finance_tracker/data/repositories/category_repository_impl.dart';
import 'package:finance_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:finance_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/subscriptions_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late AccountRepositoryImpl accountRepository;
  late CategoryRepositoryImpl categoryRepository;
  late TransactionRepositoryImpl transactionRepository;
  late SubscriptionRepositoryImpl subscriptionRepository;

  late AccountsProvider accountsProvider;
  late TransactionsProvider transactionsProvider;
  late SubscriptionsProvider subscriptionsProvider;

  final DateTime now = DateTime.parse('2026-09-05T12:00:00.000Z');

  final Account testBank = Account(
    id: 'acc-bank-p',
    name: 'Main Checking',
    type: AccountType.bank,
    balanceCents: 500000, // $5,000.00
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
    subscriptionRepository = SubscriptionRepositoryImpl(
      databaseHelper: dbHelper,
    );

    await accountRepository.createAccount(testBank);

    accountsProvider = AccountsProvider(repository: accountRepository);
    await accountsProvider.loadAccounts();

    transactionsProvider = TransactionsProvider(
      transactionRepository: transactionRepository,
      categoryRepository: categoryRepository,
    );
    await transactionsProvider.initialize();

    subscriptionsProvider = SubscriptionsProvider(
      repository: subscriptionRepository,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SubscriptionsProvider State & Recurrence Calculations', () {
    test('computes normalized monthly burn rate and annual projection', () async {
      final monthly = Subscription(
        id: 'sub-1',
        name: 'Spotify',
        amountCents: 1000, // $10.00 / month -> 1000 cents
        frequency: RecurrenceFrequency.monthly,
        accountId: 'acc-bank-p',
        categoryId: 'cat_default_subscriptions',
        billingDay: 5,
        nextDueDate: now.add(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );

      final annual = Subscription(
        id: 'sub-2',
        name: 'Amazon Prime',
        amountCents: 12000, // $120.00 / year -> 1000 cents/month
        frequency: RecurrenceFrequency.annual,
        accountId: 'acc-bank-p',
        categoryId: 'cat_default_subscriptions',
        billingDay: 1,
        nextDueDate: now.add(const Duration(days: 20)),
        createdAt: now,
        updatedAt: now,
      );

      final weekly = Subscription(
        id: 'sub-3',
        name: 'Coffee Club',
        amountCents: 500, // $5.00 / week -> (500 * 52) ~/ 12 = 2166 cents/month
        frequency: RecurrenceFrequency.weekly,
        accountId: 'acc-bank-p',
        categoryId: 'cat_default_food',
        billingDay: 1,
        nextDueDate: now.add(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );

      await subscriptionsProvider.addSubscription(monthly);
      await subscriptionsProvider.addSubscription(annual);
      await subscriptionsProvider.addSubscription(weekly);

      // Monthly: 1000 + 1000 + 2166 = 4166
      expect(subscriptionsProvider.totalMonthlyCommitmentCents, equals(4166));
      expect(
        subscriptionsProvider.totalAnnualProjectionCents,
        equals(4166 * 12),
      );
    });

    test('calculates next due dates accurately across all frequencies', () {
      final baseDate = DateTime(2026, 1, 31, 10, 0);

      // Weekly: Jan 31 + 7 days = Feb 7
      final nextWeekly = SubscriptionsProvider.calculateNextDueDate(
        baseDate,
        RecurrenceFrequency.weekly,
      );
      expect(nextWeekly, equals(DateTime(2026, 2, 7, 10, 0)));

      // Biweekly: Jan 31 + 14 days = Feb 14
      final nextBiweekly = SubscriptionsProvider.calculateNextDueDate(
        baseDate,
        RecurrenceFrequency.biweekly,
      );
      expect(nextBiweekly, equals(DateTime(2026, 2, 14, 10, 0)));

      // Monthly: Jan 31 + 1 month with clamp to Feb 28
      final nextMonthly = SubscriptionsProvider.calculateNextDueDate(
        baseDate,
        RecurrenceFrequency.monthly,
        billingDay: 31,
      );
      expect(nextMonthly.month, equals(2));
      expect(nextMonthly.day, equals(28));

      // Annual: Jan 31, 2026 -> Jan 31, 2027
      final nextAnnual = SubscriptionsProvider.calculateNextDueDate(
        baseDate,
        RecurrenceFrequency.annual,
      );
      expect(nextAnnual, equals(DateTime(2027, 1, 31, 10, 0)));
    });

    test(
      'postSubscriptionPayment logs real transaction and advances next due date',
      () async {
        final sub = Subscription(
          id: 'sub-post-1',
          name: 'Netflix',
          amountCents: 1500, // $15.00
          frequency: RecurrenceFrequency.monthly,
          accountId: 'acc-bank-p',
          categoryId: 'cat_default_subscriptions',
          billingDay: 15,
          nextDueDate: DateTime(2026, 9, 15),
          createdAt: now,
          updatedAt: now,
        );

        await subscriptionsProvider.addSubscription(sub);

        // Balance before: $5,000.00 (500,000 cents)
        expect(accountsProvider.totalAssetsCents, equals(500000));

        // Post payment
        await subscriptionsProvider.postSubscriptionPayment(
          sub,
          transactionsProvider: transactionsProvider,
          accountsProvider: accountsProvider,
        );

        // 1. Transaction logged in TransactionsProvider
        expect(transactionsProvider.transactions.length, equals(1));
        expect(transactionsProvider.transactions.first.amountCents, equals(1500));

        // 2. Account balance deducted: 500000 - 1500 = 498500
        expect(accountsProvider.totalAssetsCents, equals(498500));

        // 3. Subscription next due date advanced to Oct 15
        final updatedSub = subscriptionsProvider.subscriptions.first;
        expect(updatedSub.nextDueDate.month, equals(10));
        expect(updatedSub.nextDueDate.day, equals(15));
      },
    );

    test('checkAndProcessAutoRegister automatically processes due items', () async {
      final pastDueAutoSub = Subscription(
        id: 'sub-auto-1',
        name: 'iCloud Storage',
        amountCents: 299,
        frequency: RecurrenceFrequency.monthly,
        accountId: 'acc-bank-p',
        categoryId: 'cat_default_subscriptions',
        billingDay: 1,
        nextDueDate: DateTime.now().subtract(const Duration(days: 1)),
        autoRegister: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final futureAutoSub = Subscription(
        id: 'sub-auto-2',
        name: 'Gym',
        amountCents: 4000,
        frequency: RecurrenceFrequency.monthly,
        accountId: 'acc-bank-p',
        categoryId: 'cat_default_health',
        billingDay: 28,
        nextDueDate: DateTime.now().add(const Duration(days: 20)),
        autoRegister: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await subscriptionsProvider.addSubscription(pastDueAutoSub);
      await subscriptionsProvider.addSubscription(futureAutoSub);

      final int processed = await subscriptionsProvider
          .checkAndProcessAutoRegister(
            transactionsProvider: transactionsProvider,
            accountsProvider: accountsProvider,
          );

      expect(processed, equals(1));
      expect(transactionsProvider.transactions.length, equals(1));
      expect(transactionsProvider.transactions.first.amountCents, equals(299));
    });
  });
}
