import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/presentation/widgets/cards/savings_goal_card.dart';

void main() {
  final now = DateTime.now();

  final SavingsGoal activeGoal = SavingsGoal(
    id: 'g-1',
    name: 'New Laptop',
    targetAmountCents: 150000, // $1,500.00
    currentAmountCents: 60000, // $600.00 (40%)
    targetDate: now.add(const Duration(days: 180)),
    colorHex: '#2196F3',
    iconName: 'laptop',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
  );

  final SavingsGoal completedGoal = SavingsGoal(
    id: 'g-2',
    name: 'Emergency Fund',
    targetAmountCents: 200000, // $2,000.00
    currentAmountCents: 200000, // $2,000.00 (100%)
    colorHex: '#4CAF50',
    iconName: 'savings',
    isCompleted: true,
    createdAt: now,
    updatedAt: now,
  );

  group('SavingsGoalCard Widget Tests', () {
    testWidgets('renders active savings goal details and deposit button', (
      WidgetTester tester,
    ) async {
      bool deposited = false;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SavingsGoalCard(
              goal: activeGoal,
              onTap: () => tapped = true,
              onDeposit: () => deposited = true,
            ),
          ),
        ),
      );

      expect(find.text('New Laptop'), findsOneWidget);
      expect(find.text('\$600.00 saved'), findsOneWidget);
      expect(find.text('Target: \$1,500.00'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Deposit'), findsOneWidget);

      await tester.tap(find.text('Deposit'));
      await tester.pump();
      expect(deposited, isTrue);

      await tester.tap(find.text('New Laptop'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders completed savings goal with COMPLETED badge and no deposit button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SavingsGoalCard(
              goal: completedGoal,
            ),
          ),
        ),
      );

      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Deposit'), findsNothing);
    });
  });
}
