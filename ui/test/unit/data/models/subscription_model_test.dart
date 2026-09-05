import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/subscription_model.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';

void main() {
  group('SubscriptionModel Serialization & Entity Mapping', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Subscription domainSub = Subscription(
      id: 'sub-1',
      name: 'Spotify Family',
      amountCents: 1999,
      frequency: RecurrenceFrequency.monthly,
      accountId: 'acc-1',
      categoryId: 'cat-1',
      billingDay: 20,
      nextDueDate: now,
      autoRegister: true,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    test('converts fromEntity and toEntity accurately', () {
      final SubscriptionModel model = SubscriptionModel.fromEntity(domainSub);

      expect(model.id, equals(domainSub.id));
      expect(model.name, equals(domainSub.name));
      expect(model.amountCents, equals(domainSub.amountCents));
      expect(model.frequency, equals(domainSub.frequency));
      expect(model.autoRegister, isTrue);

      final Subscription converted = model.toEntity();
      expect(converted, equals(domainSub));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final SubscriptionModel model = SubscriptionModel.fromEntity(domainSub);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('sub-1'));
      expect(map['name'], equals('Spotify Family'));
      expect(map['amount_cents'], equals(1999));
      expect(map['frequency'], equals('monthly'));
      expect(map['auto_register'], equals(1));
      expect(map['is_active'], equals(1));

      final SubscriptionModel fromMapModel = SubscriptionModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.name, equals(model.name));
      expect(fromMapModel.amountCents, equals(1999));
      expect(fromMapModel.frequency, equals(RecurrenceFrequency.monthly));
      expect(fromMapModel.autoRegister, isTrue);
      expect(fromMapModel.isActive, isTrue);
    });
  });
}
