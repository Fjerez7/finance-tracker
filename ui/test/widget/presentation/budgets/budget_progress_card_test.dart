import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/presentation/widgets/cards/budget_progress_card.dart';

void main() {
  final now = DateTime.now();

  final Category testCategory = Category(
    id: 'cat-groceries',
    name: 'Groceries',
    iconName: 'shopping_cart',
    colorHex: '#4CAF50',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Budget budget = Budget(
    id: 'b-1',
    categoryId: 'cat-groceries',
    month: 9,
    year: 2026,
    limitCents: 50000, // $500.00
    createdAt: now,
    updatedAt: now,
  );

  group('BudgetProgressCard Widget Tests', () {
    testWidgets('renders safe budget status (<80%)', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressCard(
              budget: budget,
              category: testCategory,
              spentCents: 20000, // $200.00 (40%)
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('of \$500.00'), findsOneWidget);
      expect(find.text('\$300.00 remaining'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(BudgetProgressCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders warning budget status (80-99%)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressCard(
              budget: budget,
              category: testCategory,
              spentCents: 42000, // $420.00 (84%)
            ),
          ),
        ),
      );

      expect(find.text('Approaching limit (84%)'), findsOneWidget);
      expect(find.text('\$420.00'), findsOneWidget);
    });

    testWidgets('renders exceeded budget status (>=100%)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressCard(
              budget: budget,
              category: testCategory,
              spentCents: 55000, // $550.00 (exceeded by $50.00)
            ),
          ),
        ),
      );

      expect(find.text('Exceeded by \$50.00'), findsOneWidget);
      expect(find.text('\$550.00'), findsOneWidget);
    });
  });
}
