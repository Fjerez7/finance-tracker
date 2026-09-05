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
import 'package:finance_tracker/presentation/screens/subscriptions/add_edit_subscription_screen.dart';
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
  Future<Account?> getAccountById(String id) async => null;
  @override
  Future<void> createAccount(Account account) async {}
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
  Future<List<Category>> getCategories({CategoryType? type}) async => categories;
  @override
  Future<Category?> getCategoryById(String id) async => null;
  @override
  Future<void> createCategory(Category category) async {}
  @override
  Future<void> updateCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

class FakeTransactionRepo implements TransactionRepository {
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
  }) async => [];
  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async => [];
  @override
  Future<Transaction?> getTransactionById(String id) async => null;
  @override
  Future<void> createTransaction(Transaction transaction) async {}
  @override
  Future<void> updateTransaction(Transaction transaction) async {}
  @override
  Future<void> deleteTransaction(String id) async {}
  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async => 0;
}

void main() {
  final now = DateTime.parse('2026-09-04T12:00:00Z');

  final Account testAccount = Account(
    id: 'acc-1',
    name: 'Debit Card',
    type: AccountType.bank,
    balanceCents: 100000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Category testCategory = Category(
    id: 'cat-gym',
    name: 'Fitness',
    iconName: 'fitness_center',
    colorHex: '#FF9800',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Subscription existingSub = Subscription(
    id: 'sub-existing',
    name: 'Gym Membership',
    amountCents: 3500, // $35.00
    frequency: RecurrenceFrequency.monthly,
    accountId: 'acc-1',
    categoryId: 'cat-gym',
    billingDay: 1,
    nextDueDate: now.add(const Duration(days: 10)),
    autoRegister: false,
    isActive: true,
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
    subRepo = FakeSubscriptionRepo([existingSub]);
    accountRepo = FakeAccountRepo([testAccount]);
    catRepo = FakeCategoryRepo([testCategory]);
    txRepo = FakeTransactionRepo();

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

  Widget buildTestableWidget({Subscription? subscription}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProv),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<SubscriptionsProvider>.value(value: subsProv),
      ],
      child: MaterialApp(
        home: AddEditSubscriptionScreen(subscription: subscription),
      ),
    );
  }

  group('AddEditSubscriptionScreen Widget Tests', () {
    testWidgets('creates a new subscription successfully', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Add Subscription'), findsOneWidget);

      // Enter Service Name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Service Name'),
        'Netflix',
      );

      // Enter Amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Periodic Amount'),
        '15.99',
      );

      // Tap Save
      await tester.tap(find.text('Create Subscription'));
      await tester.pumpAndSettle();

      expect(subRepo.subscriptions.length, equals(2));
      final created = subRepo.subscriptions.last;
      expect(created.name, equals('Netflix'));
      expect(created.amountCents, equals(1599));
    });

    testWidgets('edits existing subscription and updates data', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget(subscription: existingSub));
      await tester.pump();

      expect(find.text('Edit Subscription'), findsOneWidget);
      expect(find.text('Gym Membership'), findsOneWidget);
      expect(find.text('35.00'), findsOneWidget);

      // Change amount to 40.00
      final amountField = find.widgetWithText(TextFormField, 'Periodic Amount');
      await tester.enterText(amountField, '40.00');

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      final updated = subRepo.subscriptions.firstWhere(
        (s) => s.id == 'sub-existing',
      );
      expect(updated.amountCents, equals(4000));
    });

    testWidgets('deletes subscription with confirmation dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(subscription: existingSub));
      await tester.pump();

      // Tap Delete icon button in AppBar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Subscription?'), findsOneWidget);

      // Confirm Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(subRepo.subscriptions.isEmpty, isTrue);
    });
  });
}
