import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';

void main() {
  group('TransactionModel Serialization & Entity Mapping', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Transaction domainTx = Transaction(
      id: 'tx-1',
      accountId: 'acc-1',
      toAccountId: 'acc-2',
      categoryId: 'cat-1',
      amountCents: 5000,
      type: TransactionType.transfer,
      description: 'Transfer to savings',
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
    );

    test('converts fromEntity and toEntity accurately', () {
      final TransactionModel model = TransactionModel.fromEntity(domainTx);

      expect(model.id, equals(domainTx.id));
      expect(model.accountId, equals(domainTx.accountId));
      expect(model.toAccountId, equals(domainTx.toAccountId));
      expect(model.amountCents, equals(domainTx.amountCents));
      expect(model.type, equals(domainTx.type));

      final Transaction converted = model.toEntity();
      expect(converted, equals(domainTx));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final TransactionModel model = TransactionModel.fromEntity(domainTx);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('tx-1'));
      expect(map['account_id'], equals('acc-1'));
      expect(map['to_account_id'], equals('acc-2'));
      expect(map['amount_cents'], equals(5000));
      expect(map['type'], equals('transfer'));

      final TransactionModel fromMapModel = TransactionModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.toAccountId, equals('acc-2'));
      expect(fromMapModel.amountCents, equals(5000));
      expect(fromMapModel.type, equals(TransactionType.transfer));
    });
  });
}
