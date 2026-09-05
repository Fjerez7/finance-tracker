import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';

void main() {
  group('SavingsGoal Entity', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    test('calculates progress and remaining amounts accurately', () {
      final SavingsGoal goal = SavingsGoal(
        id: 'goal-1',
        name: 'Emergency Fund',
        targetAmountCents: 1000000, // $10,000.00
        currentAmountCents: 400000, // $4,000.00
        colorHex: '#4CAF50',
        iconName: 'savings',
        createdAt: now,
        updatedAt: now,
      );

      expect(goal.progressRatio, equals(0.4));
      expect(goal.clampedProgress, equals(0.4));
      expect(goal.remainingAmountCents, equals(600000));
    });

    test('calculates required monthly savings to meet target date', () {
      final DateTime target = DateTime(
        2027,
        3,
        1,
      ); // 6 months away from 2026-09
      final SavingsGoal goal = SavingsGoal(
        id: 'goal-2',
        name: 'New Laptop',
        targetAmountCents: 120000, // $1,200.00
        currentAmountCents: 0,
        targetDate: target,
        colorHex: '#2196F3',
        iconName: 'laptop',
        createdAt: now,
        updatedAt: now,
      );

      final DateTime reference = DateTime(2026, 9, 1);
      // 6 months remaining, $1,200 total -> $200.00 / month (20000 cents)
      expect(goal.calculateRequiredMonthlySavings(reference), equals(20000));
    });

    test('validates non-negative amounts', () {
      expect(
        () => SavingsGoal(
          id: 'goal-err-1',
          name: 'Invalid Target',
          targetAmountCents: 0,
          colorHex: '#000000',
          iconName: 'flag',
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => SavingsGoal(
          id: 'goal-err-2',
          name: 'Invalid Current',
          targetAmountCents: 1000,
          currentAmountCents: -50,
          colorHex: '#000000',
          iconName: 'flag',
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
