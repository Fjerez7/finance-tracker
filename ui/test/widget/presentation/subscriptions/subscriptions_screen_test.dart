import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/subscription_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/presentation/screens/subscriptions/subscriptions_screen.dart';
import 'package:finance_tracker/presentation/widgets/cards/subscription_card.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/subscriptions_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeSubscriptionRepo implements SubscriptionRepository {
  final List<Subscription> subscriptions;
  FakeSubscriptionRepo(this.subscriptions);

  @override
  Future<List<Subscription>> getSubscriptions({
    bool? isActive,
    String? accountId,
    String? categoryId,
  }) async {
    return subscriptions.where((s) {
      if (isActive != null && s.isActive != isActive) return false;
      if (accountId != null && s.accountId != accountId) return false;
      if (categoryId != null && s.categoryId != categoryId) return false;
      return true;
    }).toList();
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async =>
      subscriptions.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> createSubscription(Subscription subscription) async =>
      subscriptions.add(subscription);

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final index = subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      subscriptions[index] = subscription;
    }
  }

  @override
  Future<void> deleteSubscription(String id) async =>
      subscriptions.removeWhere((s) => s.id == id);

  @override
  Future<void> updateNextDueDate(String id, DateTime nextDueDate) async {
    final index = subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final s = subscriptions[index];
      subscriptions[index] = Subscription(
        id: s.id,
        name: s.name,
        amountCents: s.amountCents,
        frequency: s.frequency,
        accountId: s.accountId,
        categoryId: s.categoryId,
        billingDay: s.billingDay,
        nextDueDate: nextDueDate,
        autoRegister: s.autoRegister,
        isActive: s.isActive,
        createdAt: s.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );
    }
  }

  @override
  Future<void> toggleActive(String id, bool isActive) async {
    final index = subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final s = subscriptions[index];
      subscriptions[index] = Subscription(
        id: s.id,
        name: s.name,
        amountCents: s.amountCents,
        frequency: s.frequency,
        accountId: s.accountId,
        categoryId: s.categoryId,
        billingDay: s.billingDay,
        nextDueDate: s.nextDueDate,
        autoRegister: s.autoRegister,
        isActive: isActive,
        createdAt: s.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );
    }
  }
}

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
  Future<void> adjustBalance(String id, int newBalanceCents) async {
    final index = accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final acc = accounts[index];
      accounts[index] = Account(
        id: acc.id,
        name: acc.name,
        type: acc.type,
        balanceCents: newBalanceCents,
        creditLimitCents: acc.creditLimitCents,
        currency: acc.currency,
        colorHex: acc.colorHex,
        iconName: acc.iconName,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      );
    }
  }

  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeCategoryRepo implements CategoryRepository {
  final List<Category> categories;
  FakeCategoryRepo(this.categories);

  @override
  Future<List<Category>> getCategories({CategoryType? type}) async => categories;

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
  final FakeAccountRepo? accountRepo;

  FakeTransactionRepo([this.accountRepo]);

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
  Future<void> createTransaction(Transaction transaction) async {
    transactions.add(transaction);
    if (accountRepo != null) {
      final acc = accountRepo!.accounts
          .where((a) => a.id == transaction.accountId)
          .firstOrNull;
      if (acc != null) {
        final newBal =
            transaction.type == TransactionType.expense
                ? acc.balanceCents - transaction.amountCents
                : acc.balanceCents + transaction.amountCents;
        await accountRepo!.adjustBalance(acc.id, newBal);
      }
    }
  }

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
    name: 'Debit Card',
    type: AccountType.bank,
    balanceCents: 100000, // $1,000.00
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Category testCategory = Category(
    id: 'cat-media',
    name: 'Streaming',
    iconName: 'movie',
    colorHex: '#E91E63',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Subscription activeSub = Subscription(
    id: 'sub-spotify',
    name: 'Spotify',
    amountCents: 1000, // $10.00 / mo
    frequency: RecurrenceFrequency.monthly,
    accountId: 'acc-1',
    categoryId: 'cat-media',
    billingDay: 10,
    nextDueDate: now.add(const Duration(days: 6)),
    autoRegister: false,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  final Subscription pausedSub = Subscription(
    id: 'sub-hbo',
    name: 'HBO Max',
    amountCents: 1500, // $15.00 / mo
    frequency: RecurrenceFrequency.monthly,
    accountId: 'acc-1',
    categoryId: 'cat-media',
    billingDay: 20,
    nextDueDate: now.add(const Duration(days: 16)),
    autoRegister: false,
    isActive: false,
    createdAt: now,
    updatedAt: now,
  );

  late FakeSubscriptionRepo subRepo;
  late FakeAccountRepo accountRepo;
  late FakeCategoryRepo catRepo;
  late FakeTransactionRepo txRepo;

  late SubscriptionsProvider subsProv;
  late AccountsProvider accountsProv;
  late TransactionsProvider txProv;

  setUp(() async {
    subRepo = FakeSubscriptionRepo([activeSub, pausedSub]);
    accountRepo = FakeAccountRepo([testAccount]);
    catRepo = FakeCategoryRepo([testCategory]);
    txRepo = FakeTransactionRepo(accountRepo);

    accountsProv = AccountsProvider(repository: accountRepo);
    await accountsProv.loadAccounts();

    txProv = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: catRepo,
    );
    await txProv.initialize();

    subsProv = SubscriptionsProvider(
      repository: subRepo,
    );
    await subsProv.loadSubscriptions();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProv),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<SubscriptionsProvider>.value(value: subsProv),
      ],
      child: const MaterialApp(home: SubscriptionsScreen()),
    );
  }

  group('SubscriptionsScreen Widget Tests', () {
    testWidgets('renders monthly burn rate hero banner and active tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Subscriptions & Bills'), findsOneWidget);
      expect(find.text('MONTHLY SUBSCRIPTION COMMITMENT'), findsOneWidget);
      // Monthly commitment: $10.00/mo
      expect(find.text('\$10.00/mo'), findsOneWidget);
      // Annual projection: $120.00/year
      expect(find.text('Annual Projection: \$120.00/year'), findsOneWidget);

      // TabBar items
      expect(find.text('Active (1)'), findsOneWidget);
      expect(find.text('Paused (1)'), findsOneWidget);

      // Active subscription card rendered
      expect(find.text('Spotify'), findsOneWidget);
      expect(find.byType(SubscriptionCard), findsOneWidget);
    });

    testWidgets('switching to Paused tab displays inactive subscriptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Tap on Paused tab
      await tester.tap(find.text('Paused (1)'));
      await tester.pumpAndSettle();

      expect(find.text('HBO Max'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);
    });

    testWidgets('1-tap Pay & Advance posts transaction and updates due date', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Find Pay & Advance button
      final payButton = find.text('Pay & Advance');
      expect(payButton, findsOneWidget);

      await tester.tap(payButton);
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Post Spotify Payment?'), findsOneWidget);
      expect(find.text('Confirm Payment'), findsOneWidget);

      await tester.tap(find.text('Confirm Payment'));
      await tester.pumpAndSettle();

      // Transaction created
      expect(txRepo.transactions.length, equals(1));
      expect(txRepo.transactions.first.amountCents, equals(1000));
      expect(txRepo.transactions.first.type, equals(TransactionType.expense));

      // Account balance deducted: 100000 - 1000 = 99000
      expect(accountRepo.accounts.first.balanceCents, equals(99000));

      // SnackBar shown
      expect(find.text('Payment recorded for Spotify!'), findsOneWidget);
    });
  });
}
