import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/category.dart';

void main() {
  group('Category Entity', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    test('creates expense and income categories correctly', () {
      final Category expenseCat = Category(
        id: 'cat-1',
        name: 'Groceries',
        iconName: 'shopping_cart',
        colorHex: '#FF5722',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      final Category incomeCat = Category(
        id: 'cat-2',
        name: 'Salary',
        iconName: 'attach_money',
        colorHex: '#4CAF50',
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(expenseCat.isExpense, isTrue);
      expect(expenseCat.isIncome, isFalse);

      expect(incomeCat.isIncome, isTrue);
      expect(incomeCat.isExpense, isFalse);
    });

    test('CategoryType serialization from and to string', () {
      expect(CategoryType.fromString('expense'), CategoryType.expense);
      expect(CategoryType.fromString('income'), CategoryType.income);
      expect(CategoryType.expense.toDbString(), 'expense');
      expect(CategoryType.income.toDbString(), 'income');
    });
  });
}
