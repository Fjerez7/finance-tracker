import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/savings_goal_model.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';

void main() {
  group('SavingsGoalModel Serialization & Entity Mapping', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final SavingsGoal domainGoal = SavingsGoal(
      id: 'goal-1',
      name: 'Vacation Trip',
      targetAmountCents: 200000,
      currentAmountCents: 50000,
      targetDate: DateTime.parse('2027-06-01T00:00:00.000Z'),
      colorHex: '#00BCD4',
      iconName: 'flight',
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    test('converts fromEntity and toEntity accurately', () {
      final SavingsGoalModel model = SavingsGoalModel.fromEntity(domainGoal);

      expect(model.id, equals(domainGoal.id));
      expect(model.name, equals(domainGoal.name));
      expect(model.targetAmountCents, equals(domainGoal.targetAmountCents));
      expect(model.currentAmountCents, equals(domainGoal.currentAmountCents));
      expect(model.targetDate, equals(domainGoal.targetDate));
      expect(model.isCompleted, isFalse);

      final SavingsGoal converted = model.toEntity();
      expect(converted, equals(domainGoal));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final SavingsGoalModel model = SavingsGoalModel.fromEntity(domainGoal);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('goal-1'));
      expect(map['name'], equals('Vacation Trip'));
      expect(map['target_amount_cents'], equals(200000));
      expect(map['current_amount_cents'], equals(50000));
      expect(map['is_completed'], equals(0));

      final SavingsGoalModel fromMapModel = SavingsGoalModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.name, equals(model.name));
      expect(fromMapModel.targetAmountCents, equals(model.targetAmountCents));
      expect(fromMapModel.currentAmountCents, equals(model.currentAmountCents));
      expect(fromMapModel.targetDate, equals(model.targetDate));
      expect(fromMapModel.isCompleted, isFalse);
    });
  });
}
