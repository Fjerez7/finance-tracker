import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/budget.dart';

void main() {
  group('Budget Entity', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Budget budget = Budget(
      id: 'b-1',
      categoryId: 'cat-groceries',
      month: 9,
      year: 2026,
      limitCents: 50000, // $500.00 limit
      createdAt: now,
      updatedAt: now,
    );

    test('calculates progress ratio and remaining cents', () {
      // 50% spent ($250.00)
      expect(budget.progressRatio(25000), equals(0.5));
      expect(budget.remainingCents(25000), equals(25000));
      expect(budget.isOverBudget(25000), isFalse);
      expect(budget.isApproachingLimit(25000), isFalse);

      // 85% spent ($425.00)
      expect(budget.progressRatio(42500), equals(0.85));
      expect(budget.remainingCents(42500), equals(7500));
      expect(budget.isOverBudget(42500), isFalse);
      expect(budget.isApproachingLimit(42500), isTrue);

      // 110% spent ($550.00)
      expect(budget.progressRatio(55000), equals(1.1));
      expect(budget.remainingCents(55000), equals(-5000));
      expect(budget.isOverBudget(55000), isTrue);
      expect(budget.isApproachingLimit(55000), isFalse);
    });

    test('validates month, year, and limit invariants', () {
      expect(
        () => Budget(
          id: 'b-err-1',
          categoryId: 'cat-1',
          month: 13,
          year: 2026,
          limitCents: 1000,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Budget(
          id: 'b-err-2',
          categoryId: 'cat-1',
          month: 5,
          year: 2026,
          limitCents: 0,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
