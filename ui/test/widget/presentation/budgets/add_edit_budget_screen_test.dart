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
import 'package:finance_tracker/presentation/screens/budgets/add_edit_budget_screen.dart';
import 'package:finance_tracker/providers/budgets_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeBudgetRepository implements BudgetRepository {
  final List<Budget> budgets;
  FakeBudgetRepository(this.budgets);

  @override
  Future<List<Budget>> getBudgets({int? month, int? year, String? categoryId}) async =>
      List.from(budgets);
  @override
  Future<Budget?> getBudgetById(String id) async =>
      budgets.where((b) => b.id == id).firstOrNull;
  @override
  Future<Budget?> getBudgetForCategory(String categoryId, int month, int year) async => null;
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

  final Category testCategory = Category(
    id: 'cat-dining',
    name: 'Dining',
    iconName: 'restaurant',
    colorHex: '#FF5722',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Budget existingBudget = Budget(
    id: 'b-dining',
    categoryId: 'cat-dining',
    month: 9,
    year: 2026,
    limitCents: 30000, // $300.00
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
    budgetRepo = FakeBudgetRepository([existingBudget]);
    goalRepo = FakeSavingsGoalRepository();
    catRepo = FakeCategoryRepo([testCategory]);
    txRepo = FakeTransactionRepo();

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

  Widget buildTestableWidget({Budget? budget}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<BudgetsProvider>.value(value: budgetsProv),
      ],
      child: MaterialApp(home: AddEditBudgetScreen(budget: budget)),
    );
  }

  group('AddEditBudgetScreen Widget Tests', () {
    testWidgets('creates a new budget successfully', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Set Category Budget'), findsOneWidget);

      // Enter Limit Amount: 450.00
      final limitField = find.widgetWithText(
        TextFormField,
        'Monthly Spending Limit',
      );
      await tester.enterText(limitField, '450.00');

      // Tap Set Budget
      await tester.tap(find.text('Set Budget'));
      await tester.pumpAndSettle();

      expect(budgetRepo.budgets.length, equals(2));
      final created = budgetRepo.budgets.last;
      expect(created.limitCents, equals(45000));
    });

    testWidgets('edits existing budget and deletes with confirmation', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget(budget: existingBudget));
      await tester.pump();

      expect(find.text('Edit Budget'), findsOneWidget);
      expect(find.text('300.00'), findsOneWidget);

      // Tap Delete in AppBar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Budget Limit?'), findsOneWidget);

      // Confirm Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(budgetRepo.budgets.isEmpty, isTrue);
    });
  });
}
