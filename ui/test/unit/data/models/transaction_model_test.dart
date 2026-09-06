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

    test('serializes and deserializes multi-currency fields accurately', () {
      final foreignTx = Transaction(
        id: 'tx-usd-1',
        accountId: 'acc-cop',
        categoryId: 'cat-food',
        amountCents: 62250,
        originalCurrency: 'USD',
        originalAmountCents: 1500,
        exchangeRate: 4150.0,
        type: TransactionType.expense,
        description: 'International lunch',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final model = TransactionModel.fromEntity(foreignTx);
      final map = model.toMap();

      expect(map['original_currency'], 'USD');
      expect(map['original_amount_cents'], 1500);
      expect(map['exchange_rate'], 4150.0);

      final deserialized = TransactionModel.fromMap(map);
      expect(deserialized.originalCurrency, 'USD');
      expect(deserialized.originalAmountCents, 1500);
      expect(deserialized.exchangeRate, 4150.0);
      expect(deserialized.amountCents, 62250);
      expect(deserialized.toEntity(), equals(foreignTx));
    });
  });
}
