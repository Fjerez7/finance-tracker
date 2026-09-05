import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/budget_model.dart';
import 'package:finance_tracker/domain/entities/budget.dart';

void main() {
  group('BudgetModel Serialization & Entity Mapping', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Budget domainBudget = Budget(
      id: 'b-1',
      categoryId: 'cat-dining',
      month: 9,
      year: 2026,
      limitCents: 35000,
      createdAt: now,
      updatedAt: now,
    );

    test('converts fromEntity and toEntity accurately', () {
      final BudgetModel model = BudgetModel.fromEntity(domainBudget);

      expect(model.id, equals(domainBudget.id));
      expect(model.categoryId, equals(domainBudget.categoryId));
      expect(model.month, equals(domainBudget.month));
      expect(model.year, equals(domainBudget.year));
      expect(model.limitCents, equals(domainBudget.limitCents));

      final Budget converted = model.toEntity();
      expect(converted, equals(domainBudget));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final BudgetModel model = BudgetModel.fromEntity(domainBudget);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('b-1'));
      expect(map['category_id'], equals('cat-dining'));
      expect(map['month'], equals(9));
      expect(map['year'], equals(2026));
      expect(map['limit_cents'], equals(35000));

      final BudgetModel fromMapModel = BudgetModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.categoryId, equals(model.categoryId));
      expect(fromMapModel.month, equals(model.month));
      expect(fromMapModel.year, equals(model.year));
      expect(fromMapModel.limitCents, equals(model.limitCents));
    });
  });
}
