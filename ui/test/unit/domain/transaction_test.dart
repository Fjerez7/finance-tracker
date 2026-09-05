import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';

void main() {
  group('Transaction Entity', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    test('creates expense transaction correctly', () {
      final Transaction tx = Transaction(
        id: 'tx-1',
        accountId: 'acc-1',
        categoryId: 'cat-1',
        amountCents: 4500, // $45.00
        type: TransactionType.expense,
        description: 'Dinner',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(tx.isExpense, isTrue);
      expect(tx.isIncome, isFalse);
      expect(tx.isTransfer, isFalse);
      expect(tx.amountCents, equals(4500));
    });

    test('creates valid transfer transaction between distinct accounts', () {
      final Transaction transfer = Transaction(
        id: 'tx-2',
        accountId: 'acc-bank',
        toAccountId: 'acc-wallet',
        amountCents: 10000, // $100.00
        type: TransactionType.transfer,
        description: 'ATM withdrawal',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(transfer.isTransfer, isTrue);
      expect(transfer.toAccountId, equals('acc-wallet'));
    });

    test(
      'throws AssertionError if transfer has same source and destination',
      () {
        expect(
          () => Transaction(
            id: 'tx-3',
            accountId: 'acc-same',
            toAccountId: 'acc-same',
            amountCents: 5000,
            type: TransactionType.transfer,
            transactionDate: now,
            createdAt: now,
            updatedAt: now,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('throws AssertionError if transfer has null destination', () {
      expect(
        () => Transaction(
          id: 'tx-4',
          accountId: 'acc-1',
          toAccountId: null,
          amountCents: 5000,
          type: TransactionType.transfer,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError if amount is zero or negative', () {
      expect(
        () => Transaction(
          id: 'tx-5',
          accountId: 'acc-1',
          amountCents: 0,
          type: TransactionType.expense,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Transaction(
          id: 'tx-6',
          accountId: 'acc-1',
          amountCents: -500,
          type: TransactionType.expense,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('TransactionType serialization from and to string', () {
      expect(TransactionType.fromString('expense'), TransactionType.expense);
      expect(TransactionType.fromString('income'), TransactionType.income);
      expect(TransactionType.fromString('transfer'), TransactionType.transfer);

      expect(TransactionType.expense.toDbString(), 'expense');
      expect(TransactionType.income.toDbString(), 'income');
      expect(TransactionType.transfer.toDbString(), 'transfer');
    });
  });
}
