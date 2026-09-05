import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/budget_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/savings_goal_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/budgets_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeBudgetRepository implements BudgetRepository {
  final List<Budget> budgets;
  FakeBudgetRepository(this.budgets);

  @override
  Future<List<Budget>> getBudgets({
    int? month,
    int? year,
    String? categoryId,
  }) async {
    return budgets.where((b) {
      if (month != null && b.month != month) return false;
      if (year != null && b.year != year) return false;
      if (categoryId != null && b.categoryId != categoryId) return false;
      return true;
    }).toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async =>
      budgets.where((b) => b.id == id).firstOrNull;

  @override
  Future<Budget?> getBudgetForCategory(
    String categoryId,
    int month,
    int year,
  ) async {
    return budgets
        .where(
          (b) =>
              b.categoryId == categoryId &&
              b.month == month &&
              b.year == year,
        )
        .firstOrNull;
  }

  @override
  Future<void> createBudget(Budget budget) async => budgets.add(budget);

  @override
  Future<void> updateBudget(Budget budget) async {
    final index = budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) budgets[index] = budget;
  }

  @override
  Future<void> deleteBudget(String id) async =>
      budgets.removeWhere((b) => b.id == id);
}

class FakeSavingsGoalRepository implements SavingsGoalRepository {
  final List<SavingsGoal> goals;
  FakeSavingsGoalRepository(this.goals);

  @override
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted}) async {
    if (isCompleted != null) {
      return goals.where((g) => g.isCompleted == isCompleted).toList();
    }
    return List.from(goals);
  }

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async =>
      goals.where((g) => g.id == id).firstOrNull;

  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async => goals.add(goal);

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) goals[index] = goal;
  }

  @override
  Future<void> deleteSavingsGoal(String id) async =>
      goals.removeWhere((g) => g.id == id);

  @override
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = goals[index];
      final bool completed = newCurrentAmountCents >= g.targetAmountCents;
      goals[index] = g.copyWith(
        currentAmountCents: newCurrentAmountCents,
        isCompleted: completed,
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
  final DateTime now = DateTime.parse('2026-09-05T12:00:00.000Z');

  final Account testAccount = Account(
    id: 'acc-1',
    name: 'Main Checking',
    type: AccountType.bank,
    balanceCents: 500000, // $5,000.00
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Category foodCategory = Category(
    id: 'cat-food',
    name: 'Food & Dining',
    iconName: 'restaurant',
    colorHex: '#FF5722',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Category shoppingCategory = Category(
    id: 'cat-shopping',
    name: 'Shopping',
    iconName: 'shopping_bag',
    colorHex: '#009688',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Budget foodBudget = Budget(
    id: 'b-food',
    categoryId: 'cat-food',
    month: 9,
    year: 2026,
    limitCents: 50000, // $500.00 limit
    createdAt: now,
    updatedAt: now,
  );

  final Budget shoppingBudget = Budget(
    id: 'b-shopping',
    categoryId: 'cat-shopping',
    month: 9,
    year: 2026,
    limitCents: 20000, // $200.00 limit
    createdAt: now,
    updatedAt: now,
  );

  final SavingsGoal emergencyGoal = SavingsGoal(
    id: 'g-emergency',
    name: 'Emergency Fund',
    targetAmountCents: 100000, // $1,000.00
    currentAmountCents: 40000, // $400.00 (40%)
    colorHex: '#4CAF50',
    iconName: 'savings',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
  );

  final SavingsGoal vacationGoal = SavingsGoal(
    id: 'g-vacation',
    name: 'Vacation',
    targetAmountCents: 50000, // $500.00
    currentAmountCents: 50000, // $500.00 (completed)
    colorHex: '#2196F3',
    iconName: 'flight',
    isCompleted: true,
    createdAt: now,
    updatedAt: now,
  );

  late FakeBudgetRepository budgetRepo;
  late FakeSavingsGoalRepository goalRepo;
  late FakeAccountRepo accountRepo;
  late FakeCategoryRepo catRepo;
  late FakeTransactionRepo txRepo;

  late BudgetsProvider budgetsProvider;
  late AccountsProvider accountsProvider;
  late TransactionsProvider txProvider;

  setUp(() async {
    budgetRepo = FakeBudgetRepository([foodBudget, shoppingBudget]);
    goalRepo = FakeSavingsGoalRepository([emergencyGoal, vacationGoal]);
    accountRepo = FakeAccountRepo([testAccount]);
    catRepo = FakeCategoryRepo([foodCategory, shoppingCategory]);
    txRepo = FakeTransactionRepo(accountRepo);

    accountsProvider = AccountsProvider(repository: accountRepo);
    await accountsProvider.loadAccounts();

    txProvider = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: catRepo,
    );
    await txProvider.initialize();

    budgetsProvider = BudgetsProvider(
      budgetRepository: budgetRepo,
      savingsGoalRepository: goalRepo,
      initialMonth: 9,
      initialYear: 2026,
    );
    await budgetsProvider.initialize();
  });

  group('BudgetsProvider State & Financial Calculations', () {
    test('initializes and calculates total monthly budget limits correctly', () {
      expect(budgetsProvider.budgets.length, equals(2));
      // $500.00 + $200.00 = $700.00 (70000 cents)
      expect(budgetsProvider.totalMonthlyBudgetLimitCents, equals(70000));
      expect(budgetsProvider.selectedMonth, equals(9));
      expect(budgetsProvider.selectedYear, equals(2026));
    });

    test('computes category spend and total monthly spend from transactions', () async {
      // Add $300 food expense in Sep 2026
      await txProvider.addTransaction(
        Transaction(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-food',
          amountCents: 30000, // $300.00
          type: TransactionType.expense,
          description: 'Dinner',
          transactionDate: DateTime(2026, 9, 10),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Add $100 shopping expense in Sep 2026
      await txProvider.addTransaction(
        Transaction(
          id: 'tx-2',
          accountId: 'acc-1',
          categoryId: 'cat-shopping',
          amountCents: 10000, // $100.00
          type: TransactionType.expense,
          description: 'Shoes',
          transactionDate: DateTime(2026, 9, 12),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Add $50 expense in Aug 2026 (should not be counted in Sep 2026)
      await txProvider.addTransaction(
        Transaction(
          id: 'tx-3',
          accountId: 'acc-1',
          categoryId: 'cat-food',
          amountCents: 5000,
          type: TransactionType.expense,
          description: 'August Coffee',
          transactionDate: DateTime(2026, 8, 20),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final int totalSepSpent = budgetsProvider.calculateTotalMonthlySpentCents(
        txProvider,
      );
      expect(totalSepSpent, equals(40000)); // $300 + $100 = $400 (40000 cents)

      final int foodSpent = budgetsProvider.calculateCategorySpentCents(
        'cat-food',
        txProvider,
      );
      expect(foodSpent, equals(30000));

      final int shoppingSpent = budgetsProvider.calculateCategorySpentCents(
        'cat-shopping',
        txProvider,
      );
      expect(shoppingSpent, equals(10000));
    });

    test('evaluates threshold status accurately (safe, warning, exceeded)', () {
      // Safe: $200 spent on $500 budget (40%)
      expect(
        budgetsProvider.evaluateThresholdStatus(foodBudget, 20000),
        equals(BudgetThresholdStatus.safe),
      );

      // Warning: $420 spent on $500 budget (84%)
      expect(
        budgetsProvider.evaluateThresholdStatus(foodBudget, 42000),
        equals(BudgetThresholdStatus.warning),
      );

      // Exceeded: $550 spent on $500 budget (110%)
      expect(
        budgetsProvider.evaluateThresholdStatus(foodBudget, 55000),
        equals(BudgetThresholdStatus.exceeded),
      );
    });

    test('advances and regresses calendar period and reloads budgets', () {
      budgetsProvider.nextMonth();
      expect(budgetsProvider.selectedMonth, equals(10));
      expect(budgetsProvider.selectedYear, equals(2026));

      budgetsProvider.previousMonth();
      expect(budgetsProvider.selectedMonth, equals(9));
      expect(budgetsProvider.selectedYear, equals(2026));

      budgetsProvider.setPeriod(12, 2025);
      expect(budgetsProvider.selectedMonth, equals(12));
      expect(budgetsProvider.selectedYear, equals(2025));
    });

    test('deposits funds into savings goal and logs transaction', () async {
      expect(budgetsProvider.activeSavingsGoals.length, equals(1));
      expect(budgetsProvider.completedSavingsGoals.length, equals(1));

      // Deposit $300 (30000 cents) into emergency goal (currently $400 -> $700)
      await budgetsProvider.depositFunds(
        'g-emergency',
        30000,
        fromAccountId: 'acc-1',
        accountsProvider: accountsProvider,
        transactionsProvider: txProvider,
      );

      final updatedGoal = budgetsProvider.savingsGoals.firstWhere(
        (g) => g.id == 'g-emergency',
      );
      expect(updatedGoal.currentAmountCents, equals(70000));
      expect(updatedGoal.isCompleted, isFalse);

      // Verify account balance was deducted: 500000 - 30000 = 470000 cents
      expect(accountsProvider.accounts.first.balanceCents, equals(470000));

      // Now deposit another $300 (30000 cents) -> $1,000 reached -> marked complete
      await budgetsProvider.depositFunds(
        'g-emergency',
        30000,
        fromAccountId: 'acc-1',
        accountsProvider: accountsProvider,
        transactionsProvider: txProvider,
      );

      final completedGoal = budgetsProvider.savingsGoals.firstWhere(
        (g) => g.id == 'g-emergency',
      );
      expect(completedGoal.currentAmountCents, equals(100000));
      expect(completedGoal.isCompleted, isTrue);
      expect(budgetsProvider.completedSavingsGoals.length, equals(2));
      expect(budgetsProvider.activeSavingsGoals.isEmpty, isTrue);
    });
  });
}
