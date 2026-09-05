import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/account_model.dart';
import 'package:finance_tracker/domain/entities/account.dart';

void main() {
  group('AccountModel Serialization & Entity Mapping', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Account domainAccount = Account(
      id: 'acc-1',
      name: 'Chase Checking',
      type: AccountType.bank,
      balanceCents: 450000,
      creditLimitCents: 0,
      currency: 'USD',
      colorHex: '#2196F3',
      iconName: 'account_balance',
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );

    test('converts fromEntity and toEntity accurately', () {
      final AccountModel model = AccountModel.fromEntity(domainAccount);

      expect(model.id, equals(domainAccount.id));
      expect(model.name, equals(domainAccount.name));
      expect(model.type, equals(domainAccount.type));
      expect(model.balanceCents, equals(domainAccount.balanceCents));

      final Account converted = model.toEntity();
      expect(converted, equals(domainAccount));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final AccountModel model = AccountModel.fromEntity(domainAccount);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('acc-1'));
      expect(map['name'], equals('Chase Checking'));
      expect(map['type'], equals('bank'));
      expect(map['balance_cents'], equals(450000));
      expect(map['is_archived'], equals(0));

      final AccountModel fromMapModel = AccountModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.name, equals(model.name));
      expect(fromMapModel.type, equals(model.type));
      expect(fromMapModel.balanceCents, equals(model.balanceCents));
      expect(fromMapModel.isArchived, isFalse);
    });
  });
}
