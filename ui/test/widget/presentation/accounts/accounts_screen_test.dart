import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/presentation/screens/accounts/accounts_screen.dart';
import 'package:finance_tracker/presentation/widgets/cards/account_balance_card.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';

class FakeAccountRepo implements AccountRepository {
  final List<Account> accounts;
  FakeAccountRepo(this.accounts);

  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async =>
      accounts;
  @override
  Future<Account?> getAccountById(String id) async => null;
  @override
  Future<void> createAccount(Account account) async {}
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async {}
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

void main() {
  final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

  final Account checking = Account(
    id: 'acc-1',
    name: 'Bancolombia Savings',
    type: AccountType.bank,
    balanceCents: 400000, // $4,000.00 asset
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Account creditCard = Account(
    id: 'acc-2',
    name: 'Visa Card',
    type: AccountType.creditCard,
    balanceCents: 50000, // $500.00 debt
    creditLimitCents: 150000,
    currency: 'USD',
    colorHex: '#2196F3',
    iconName: 'credit_card',
    createdAt: now,
    updatedAt: now,
  );

  testWidgets('AccountsScreen renders Net Worth header and grouped accounts', (
    WidgetTester tester,
  ) async {
    final FakeAccountRepo repo = FakeAccountRepo([checking, creditCard]);
    final AccountsProvider provider = AccountsProvider(repository: repo);
    await provider.loadAccounts();

    await tester.pumpWidget(
      ChangeNotifierProvider<AccountsProvider>.value(
        value: provider,
        child: const MaterialApp(home: AccountsScreen()),
      ),
    );

    expect(find.text('Accounts & Net Worth'), findsOneWidget);
    expect(find.text('TOTAL NET WORTH'), findsOneWidget);

    // Net worth = 400000 - 50000 = 350000 cents ($3,500.00)
    expect(find.text('\$3,500.00'), findsOneWidget);

    // Assets breakdown in header and balance card
    expect(find.text('\$4,000.00'), findsNWidgets(2));
    // Liabilities breakdown in header and credit card
    expect(find.text('\$500.00'), findsNWidgets(2));

    // Account cards
    expect(find.byType(AccountBalanceCard), findsNWidgets(2));
    expect(find.text('Bancolombia Savings'), findsOneWidget);
    expect(find.text('Visa Card'), findsOneWidget);

    // FAB
    expect(find.text('New Account'), findsOneWidget);
  });
}
