import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/budget_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/savings_goal_repository.dart';
import 'package:finance_tracker/domain/repositories/subscription_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:finance_tracker/presentation/widgets/cards/hero_net_worth_card.dart';
import 'package:finance_tracker/presentation/widgets/charts/category_expense_pie_chart.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/analytics_provider.dart';
import 'package:finance_tracker/providers/budgets_provider.dart';
import 'package:finance_tracker/providers/subscriptions_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeAccountRepo implements AccountRepository {
  final List<Account> accounts;
  FakeAccountRepo(this.accounts);
  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async =>
      includeArchived ? accounts : accounts.where((a) => !a.isArchived).toList();
  @override
  Future<Account?> getAccountById(String id) async =>
      accounts.where((a) => a.id == id).firstOrNull;
  @override
  Future<void> createAccount(Account account) async => accounts.add(account);
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async =>
      accounts.removeWhere((a) => a.id == id);
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeTransactionRepo implements TransactionRepository {
  final List<Transaction> transactions;
  FakeTransactionRepo(this.transactions);
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
  }) async => transactions;
  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async =>
      transactions;
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
  }) async => transactions.length;
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
  Future<void> createCategory(Category category) async {}
  @override
  Future<void> updateCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

class FakeSubscriptionRepo implements SubscriptionRepository {
  final List<Subscription> subscriptions;
  FakeSubscriptionRepo(this.subscriptions);
  @override
  Future<List<Subscription>> getSubscriptions({
    String? accountId,
    String? categoryId,
    bool? isActive,
  }) async => subscriptions;
  @override
  Future<Subscription?> getSubscriptionById(String id) async => null;
  @override
  Future<void> createSubscription(Subscription subscription) async {}
  @override
  Future<void> updateSubscription(Subscription subscription) async {}
  @override
  Future<void> deleteSubscription(String id) async {}
  @override
  Future<void> toggleActive(String id, bool isActive) async {}
  @override
  Future<void> updateNextDueDate(String id, DateTime nextDueDate) async {}
}

class FakeBudgetRepo implements BudgetRepository {
  @override
  Future<List<Budget>> getBudgets({int? month, int? year, String? categoryId}) async => [];
  @override
  Future<Budget?> getBudgetById(String id) async => null;
  @override
  Future<Budget?> getBudgetForCategory(String categoryId, int month, int year) async => null;
  @override
  Future<void> createBudget(Budget budget) async {}
  @override
  Future<void> updateBudget(Budget budget) async {}
  @override
  Future<void> deleteBudget(String id) async {}
}

class FakeSavingsGoalRepo implements SavingsGoalRepository {
  @override
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted}) async => [];
  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async => null;
  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async {}
  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {}
  @override
  Future<void> deleteSavingsGoal(String id) async {}
  @override
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents) async {}
}

void main() {
  final now = DateTime.now();

  final account = Account(
    id: 'acc-1',
    name: 'Main Checking',
    type: AccountType.bank,
    currency: 'USD',
    balanceCents: 500000, // $5,000.00
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );

  final category = Category(
    id: 'cat-1',
    name: 'Food',
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
    amountCents: 4500, // $45.00
    type: TransactionType.expense,
    description: 'Dinner with friends',
    transactionDate: now,
    createdAt: now,
    updatedAt: now,
  );

  late AccountsProvider accountsProv;
  late TransactionsProvider txProv;
  late SubscriptionsProvider subsProv;
  late BudgetsProvider budgetsProv;
  late AnalyticsProvider analyticsProv;

  setUp(() async {
    accountsProv = AccountsProvider(repository: FakeAccountRepo([account]));
    await accountsProv.loadAccounts();

    txProv = TransactionsProvider(
      transactionRepository: FakeTransactionRepo([transaction]),
      categoryRepository: FakeCategoryRepo([category]),
    );
    await txProv.initialize();

    subsProv = SubscriptionsProvider(
      repository: FakeSubscriptionRepo([]),
    );
    await subsProv.loadSubscriptions();

    budgetsProv = BudgetsProvider(
      budgetRepository: FakeBudgetRepo(),
      savingsGoalRepository: FakeSavingsGoalRepo(),
    );
    await budgetsProv.initialize();

    analyticsProv = AnalyticsProvider();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProv),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<SubscriptionsProvider>.value(value: subsProv),
        ChangeNotifierProvider<BudgetsProvider>.value(value: budgetsProv),
        ChangeNotifierProvider<AnalyticsProvider>.value(value: analyticsProv),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders HeroNetWorthCard, quick action buttons, pie chart and recent transactions', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Finance Tracker'), findsOneWidget);
      expect(find.byType(HeroNetWorthCard), findsOneWidget);
      expect(find.text('NET WORTH'), findsOneWidget);
      expect(find.text(r'$5,000.00'), findsWidgets);

      // Quick action shortcuts
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Subscriptions'), findsOneWidget);

      // Category pie chart card
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.byType(CategoryExpensePieChart), findsOneWidget);

      // Recent transactions
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Dinner with friends'), findsOneWidget);
    });
  });
}
