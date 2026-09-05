import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';

void main() {
  group('Account Entity', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    test('creates non-credit account correctly', () {
      final Account bankAccount = Account(
        id: 'acc-1',
        name: 'Checking Account',
        type: AccountType.bank,
        balanceCents: 500000,
        currency: 'USD',
        colorHex: '#4CAF50',
        iconName: 'account_balance',
        createdAt: now,
        updatedAt: now,
      );

      expect(bankAccount.isCreditCard, isFalse);
      expect(bankAccount.availableCreditCents, equals(0));
      expect(bankAccount.creditUtilizationRate, equals(0.0));
      expect(bankAccount.balanceCents, equals(500000));
    });

    test(
      'calculates available credit and utilization rate for credit card',
      () {
        final Account creditCard = Account(
          id: 'cc-1',
          name: 'Sapphire Preferred',
          type: AccountType.creditCard,
          balanceCents: 150000, // $1,500 debt
          creditLimitCents: 500000, // $5,000 limit
          currency: 'USD',
          colorHex: '#2196F3',
          iconName: 'credit_card',
          createdAt: now,
          updatedAt: now,
        );

        expect(creditCard.isCreditCard, isTrue);
        expect(
          creditCard.availableCreditCents,
          equals(350000),
        ); // $3,500 available
        expect(creditCard.creditUtilizationRate, closeTo(0.30, 0.001)); // 30%
      },
    );

    test('AccountType serialization from and to string', () {
      expect(AccountType.fromString('bank'), AccountType.bank);
      expect(
        AccountType.fromString('digital_wallet'),
        AccountType.digitalWallet,
      );
      expect(AccountType.fromString('cash'), AccountType.cash);
      expect(AccountType.fromString('credit_card'), AccountType.creditCard);

      expect(AccountType.bank.toDbString(), 'bank');
      expect(AccountType.digitalWallet.toDbString(), 'digital_wallet');
      expect(AccountType.cash.toDbString(), 'cash');
      expect(AccountType.creditCard.toDbString(), 'credit_card');
    });

    test('copyWith updates specified fields', () {
      final Account account = Account(
        id: 'acc-1',
        name: 'Wallet',
        type: AccountType.cash,
        balanceCents: 10000,
        currency: 'USD',
        colorHex: '#000000',
        iconName: 'wallet',
        createdAt: now,
        updatedAt: now,
      );

      final Account updated = account.copyWith(
        balanceCents: 25000,
        name: 'Pocket Cash',
      );

      expect(updated.balanceCents, equals(25000));
      expect(updated.name, equals('Pocket Cash'));
      expect(updated.id, equals('acc-1'));
      expect(updated.type, equals(AccountType.cash));
    });
  });
}
