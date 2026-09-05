import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/presentation/screens/accounts/add_edit_account_screen.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';

class MockAccountRepo implements AccountRepository {
  Account? lastCreated;

  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async => [];
  @override
  Future<Account?> getAccountById(String id) async => null;
  @override
  Future<void> createAccount(Account account) async {
    lastCreated = account;
  }

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
  testWidgets('AddEditAccountScreen fills form and creates account', (
    WidgetTester tester,
  ) async {
    final MockAccountRepo repo = MockAccountRepo();
    final AccountsProvider provider = AccountsProvider(repository: repo);

    await tester.pumpWidget(
      ChangeNotifierProvider<AccountsProvider>.value(
        value: provider,
        child: const MaterialApp(home: AddEditAccountScreen()),
      ),
    );

    expect(find.text('New Account'), findsOneWidget);
    expect(find.text('Account Name'), findsOneWidget);

    // Enter account name
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Account Name'),
      'Nequi Digital Wallet',
    );

    // Select Digital Wallet type
    await tester.tap(find.text('Digital Wallet'));
    await tester.pump();

    // Enter balance
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Initial Balance (\$)'),
      '350.00',
    );

    // Submit form via AppBar save IconButton
    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await tester.pumpAndSettle();

    expect(repo.lastCreated, isNotNull);
    expect(repo.lastCreated!.name, equals('Nequi Digital Wallet'));
    expect(repo.lastCreated!.type, equals(AccountType.digitalWallet));
    expect(repo.lastCreated!.balanceCents, equals(35000));
  });
}
