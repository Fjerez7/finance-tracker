import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/budget_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/savings_goal_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/presentation/screens/budgets/budgets_screen.dart';
import 'package:finance_tracker/presentation/widgets/cards/budget_progress_card.dart';
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
  ) async =>
      budgets
          .where(
            (b) =>
                b.categoryId == categoryId &&
                b.month == month &&
                b.year == year,
          )
          .firstOrNull;

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
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted}) async =>
      List.from(goals);
  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async =>
      goals.where((g) => g.id == id).firstOrNull;
  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async => goals.add(goal);
  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {}
  @override
  Future<void> deleteSavingsGoal(String id) async {}
  @override
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents) async {}
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
  }) async => List.from(transactions);

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async =>
      List.from(transactions);
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

void main() {
  final now = DateTime.parse('2026-09-04T12:00:00Z');

  final Category foodCat = Category(
    id: 'cat-food',
    name: 'Food & Dining',
    iconName: 'restaurant',
    colorHex: '#FF5722',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Budget sepBudget = Budget(
    id: 'b-food',
    categoryId: 'cat-food',
    month: 9,
    year: 2026,
    limitCents: 50000, // $500.00
    createdAt: now,
    updatedAt: now,
  );

  final Transaction foodTx = Transaction(
    id: 'tx-1',
    accountId: 'acc-1',
    categoryId: 'cat-food',
    amountCents: 20000, // $200.00
    type: TransactionType.expense,
    description: 'Groceries store',
    transactionDate: DateTime(2026, 9, 2),
    createdAt: now,
    updatedAt: now,
  );

  late FakeBudgetRepository budgetRepo;
  late FakeSavingsGoalRepository goalRepo;
  late FakeCategoryRepo catRepo;
  late FakeTransactionRepo txRepo;

  late BudgetsProvider budgetsProv;
  late TransactionsProvider txProv;

  setUp(() async {
    budgetRepo = FakeBudgetRepository([sepBudget]);
    goalRepo = FakeSavingsGoalRepository([]);
    catRepo = FakeCategoryRepo([foodCat]);
    txRepo = FakeTransactionRepo([foodTx]);

    txProv = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: catRepo,
    );
    await txProv.initialize();

    budgetsProv = BudgetsProvider(
      budgetRepository: budgetRepo,
      savingsGoalRepository: goalRepo,
      initialMonth: 9,
      initialYear: 2026,
    );
    await budgetsProv.initialize();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<BudgetsProvider>.value(value: budgetsProv),
      ],
      child: const MaterialApp(home: BudgetsScreen()),
    );
  }

  group('BudgetsScreen Widget Tests', () {
    testWidgets('renders month selector, overview banner, and budget cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Budgets & Goals'), findsOneWidget);
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('TOTAL MONTHLY BUDGET'), findsOneWidget);
      expect(find.text('\$200.00'), findsWidgets);
      expect(find.text('of \$500.00'), findsWidgets);
      expect(find.text('40% spent'), findsOneWidget);

      // Card rendered
      expect(find.byType(BudgetProgressCard), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
    });

    testWidgets('navigating months updates month selector and reloads data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Tap Next Month
      await tester.tap(find.byTooltip('Next Month'));
      await tester.pumpAndSettle();

      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('No budgets set for this month'), findsOneWidget);

      // Tap Previous Month
      await tester.tap(find.byTooltip('Previous Month'));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);
      expect(find.byType(BudgetProgressCard), findsOneWidget);
    });
  });
}
