import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/widgets/cards/transaction_list_tile.dart';

void main() {
  final now = DateTime.parse('2026-09-06T12:00:00Z');

  final Account testAccountUSD = Account(
    id: 'acc-usd',
    name: 'US Checking',
    type: AccountType.bank,
    balanceCents: 500000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Category testCategory = Category(
    id: 'cat-groceries',
    name: 'Groceries',
    iconName: 'shopping_cart',
    colorHex: '#4CAF50',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  group('TransactionListTile Widget Tests', () {
    testWidgets('renders standard single-currency transaction', (
      WidgetTester tester,
    ) async {
      final tx = Transaction(
        id: 'tx-1',
        accountId: 'acc-usd',
        categoryId: 'cat-groceries',
        amountCents: 2500, // $25.00
        type: TransactionType.expense,
        description: 'Supermarket shopping',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TransactionListTile(
              transaction: tx,
              category: testCategory,
              account: testAccountUSD,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Supermarket shopping'), findsOneWidget);
      expect(find.text('US Checking'), findsOneWidget);
      expect(find.text('-\$25.00'), findsOneWidget);

      await tester.tap(find.byType(TransactionListTile));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets(
      'renders foreign multi-currency transaction with converted subtitle',
      (WidgetTester tester) async {
        // Foreign COP transaction on USD account
        final tx = Transaction(
          id: 'tx-foreign-1',
          accountId: 'acc-usd',
          categoryId: 'cat-groceries',
          amountCents: 1500, // Debited: $15.00 USD (1500 cents)
          originalCurrency: 'COP',
          originalAmountCents: 6225000, // Original: 62,250.00 COP (6225000 cents)
          exchangeRate: 1 / 4150.0,
          type: TransactionType.expense,
          description: 'Bogota Market',
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TransactionListTile(
                transaction: tx,
                category: testCategory,
                account: testAccountUSD,
              ),
            ),
          ),
        );

        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Bogota Market'), findsOneWidget);
        expect(find.text('US Checking'), findsOneWidget);

        // Primary amount displays foreign COP amount
        expect(find.text('-COP 62,250.00'), findsOneWidget);
        // Subtitle displays converted debited USD amount
        expect(find.text('(~-\$15.00)'), findsOneWidget);
      },
    );
  });
}
