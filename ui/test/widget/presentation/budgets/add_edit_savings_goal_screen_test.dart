import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/domain/repositories/budget_repository.dart';
import 'package:finance_tracker/domain/repositories/savings_goal_repository.dart';
import 'package:finance_tracker/presentation/screens/budgets/add_edit_savings_goal_screen.dart';
import 'package:finance_tracker/providers/budgets_provider.dart';

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
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) goals[index] = goal;
  }
  @override
  Future<void> deleteSavingsGoal(String id) async =>
      goals.removeWhere((g) => g.id == id);
  @override
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents) async {}
}

class FakeBudgetRepository implements BudgetRepository {
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

void main() {
  final now = DateTime.parse('2026-09-04T12:00:00Z');

  final SavingsGoal existingGoal = SavingsGoal(
    id: 'g-trip',
    name: 'Trip to Tokyo',
    targetAmountCents: 200000, // $2,000.00
    currentAmountCents: 50000, // $500.00
    colorHex: '#2196F3',
    iconName: 'flight',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
  );

  late FakeSavingsGoalRepository goalRepo;
  late FakeBudgetRepository budgetRepo;
  late BudgetsProvider budgetsProv;

  setUp(() async {
    goalRepo = FakeSavingsGoalRepository([existingGoal]);
    budgetRepo = FakeBudgetRepository();

    budgetsProv = BudgetsProvider(
      budgetRepository: budgetRepo,
      savingsGoalRepository: goalRepo,
      initialMonth: 9,
      initialYear: 2026,
    );
    await budgetsProv.initialize();
  });

  Widget buildTestableWidget({SavingsGoal? goal}) {
    return ChangeNotifierProvider<BudgetsProvider>.value(
      value: budgetsProv,
      child: MaterialApp(home: AddEditSavingsGoalScreen(goal: goal)),
    );
  }

  group('AddEditSavingsGoalScreen Widget Tests', () {
    testWidgets('creates a new savings goal successfully', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('New Savings Goal'), findsOneWidget);

      // Enter Goal Title
      final titleField = find.widgetWithText(TextFormField, 'Goal Title');
      await tester.enterText(titleField, 'Emergency Fund');

      // Enter Target Amount: 5000.00
      final targetField = find.widgetWithText(
        TextFormField,
        'Target Savings Amount',
      );
      await tester.enterText(targetField, '5000.00');

      // Tap Create Savings Goal
      await tester.tap(find.text('Create Savings Goal'));
      await tester.pumpAndSettle();

      expect(goalRepo.goals.length, equals(2));
      final created = goalRepo.goals.last;
      expect(created.name, equals('Emergency Fund'));
      expect(created.targetAmountCents, equals(500000));
    });

    testWidgets('edits existing goal and deletes with confirmation dialog', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildTestableWidget(goal: existingGoal));
      await tester.pump();

      expect(find.text('Edit Savings Goal'), findsOneWidget);
      expect(find.text('Trip to Tokyo'), findsOneWidget);

      // Tap Delete in AppBar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Savings Goal?'), findsOneWidget);

      // Confirm Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(goalRepo.goals.isEmpty, isTrue);
    });
  });
}
