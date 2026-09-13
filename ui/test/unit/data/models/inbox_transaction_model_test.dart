import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/inbox_transaction_model.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';

void main() {
  group('InboxTransactionModel Serialization & Parsing', () {
    final Map<String, dynamic> rawFirestoreMap = {
      'id': '1a090a02c0745e12',
      'bank_name': 'Bancolombia',
      'account_type': 'credit_card',
      'account_mask': '*4892',
      'merchant': 'Supermercados Exito',
      'amount': 70000.0,
      'amount_cents': 7000000,
      'currency': 'COP',
      'type': 'expense',
      'category_suggestion': 'Groceries',
      'transaction_date': '2026-09-12T14:30:00.000Z',
      'reference_number': 'AUT-984712',
      'status': 'PENDING',
      'created_at': '2026-09-12T14:35:10.000Z',
      'synced_at': null,
    };

    test('deserializes from Map correctly', () {
      final InboxTransactionModel model =
          InboxTransactionModel.fromMap('1a090a02c0745e12', rawFirestoreMap);

      expect(model.id, equals('1a090a02c0745e12'));
      expect(model.bankName, equals('Bancolombia'));
      expect(model.accountType, equals('credit_card'));
      expect(model.accountMask, equals('*4892'));
      expect(model.merchant, equals('Supermercados Exito'));
      expect(model.amountCents, equals(7000000));
      expect(model.amount, equals(70000.0));
      expect(model.currency, equals('COP'));
      expect(model.type, equals('expense'));
      expect(model.categorySuggestion, equals('Groceries'));
      expect(model.status, equals(InboxStatus.pending));
      expect(model.isExpense, isTrue);
      expect(model.isIncome, isFalse);
    });

    test('serializes toMap roundtrip accurately', () {
      final InboxTransactionModel model =
          InboxTransactionModel.fromMap('1a090a02c0745e12', rawFirestoreMap);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('1a090a02c0745e12'));
      expect(map['bank_name'], equals('Bancolombia'));
      expect(map['amount_cents'], equals(7000000));
      expect(map['status'], equals('PENDING'));
    });
  });
}
