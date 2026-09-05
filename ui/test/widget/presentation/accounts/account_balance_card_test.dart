import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/presentation/widgets/cards/account_balance_card.dart';

void main() {
  final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

  testWidgets('AccountBalanceCard renders bank account balance correctly', (
    WidgetTester tester,
  ) async {
    final Account account = Account(
      id: 'acc-1',
      name: 'Checking Account',
      type: AccountType.bank,
      balanceCents: 125000, // $1,250.00
      currency: 'USD',
      colorHex: '#4CAF50',
      iconName: 'account_balance',
      createdAt: now,
      updatedAt: now,
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountBalanceCard(
            account: account,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Checking Account'), findsOneWidget);
    expect(find.text('Bank Account'), findsOneWidget);
    expect(find.text('\$1,250.00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.byType(AccountBalanceCard));
    expect(tapped, isTrue);
  });

  testWidgets('AccountBalanceCard renders credit card with utilization bar', (
    WidgetTester tester,
  ) async {
    final Account creditCard = Account(
      id: 'cc-1',
      name: 'Sapphire Preferred',
      type: AccountType.creditCard,
      balanceCents: 50000, // $500.00 debt
      creditLimitCents: 200000, // $2,000.00 limit
      currency: 'USD',
      colorHex: '#2196F3',
      iconName: 'credit_card',
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AccountBalanceCard(account: creditCard)),
      ),
    );

    expect(find.text('Sapphire Preferred'), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);
    expect(find.text('\$500.00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Available: \$1,500.00'), findsOneWidget);
  });
}
