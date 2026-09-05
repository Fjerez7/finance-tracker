import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';
import 'package:finance_tracker/presentation/widgets/cards/subscription_card.dart';

void main() {
  final now = DateTime.now();

  final Account testAccount = Account(
    id: 'acc-1',
    name: 'Main Checking',
    type: AccountType.bank,
    balanceCents: 500000,
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final Category testCategory = Category(
    id: 'cat-subs',
    name: 'Entertainment',
    iconName: 'movie',
    colorHex: '#E91E63',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Subscription activeSub = Subscription(
    id: 'sub-netflix',
    name: 'Netflix Premium',
    amountCents: 1999, // $19.99
    frequency: RecurrenceFrequency.monthly,
    accountId: 'acc-1',
    categoryId: 'cat-subs',
    billingDay: 15,
    nextDueDate: now.add(const Duration(days: 3)),
    autoRegister: false,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  final Subscription annualSub = Subscription(
    id: 'sub-aws',
    name: 'Amazon Prime Annual',
    amountCents: 12000, // $120.00 / yr -> $10.00 / mo
    frequency: RecurrenceFrequency.annual,
    accountId: 'acc-1',
    categoryId: 'cat-subs',
    billingDay: 1,
    nextDueDate: now.add(const Duration(days: 45)),
    autoRegister: true,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  final Subscription pausedSub = Subscription(
    id: 'sub-gym',
    name: 'Fitness Gym',
    amountCents: 4500, // $45.00
    frequency: RecurrenceFrequency.monthly,
    accountId: 'acc-1',
    categoryId: 'cat-subs',
    billingDay: 5,
    nextDueDate: now.subtract(const Duration(days: 2)),
    autoRegister: false,
    isActive: false,
    createdAt: now,
    updatedAt: now,
  );

  group('SubscriptionCard Widget Tests', () {
    testWidgets('renders active subscription details and pay button', (
      WidgetTester tester,
    ) async {
      bool paid = false;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionCard(
              subscription: activeSub,
              category: testCategory,
              account: testAccount,
              onTap: () => tapped = true,
              onPay: () => paid = true,
            ),
          ),
        ),
      );

      expect(find.text('Netflix Premium'), findsOneWidget);
      expect(find.text('Main Checking'), findsOneWidget);
      expect(find.text('MONTHLY'), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
      expect(find.byType(SubscriptionCard), findsOneWidget);
      expect(find.text('Pay & Advance'), findsOneWidget);

      await tester.tap(find.text('Pay & Advance'));
      await tester.pump();
      expect(paid, isTrue);

      await tester.tap(find.text('Netflix Premium'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders annual subscription with monthly burn rate equivalent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionCard(
              subscription: annualSub,
              category: testCategory,
              account: testAccount,
            ),
          ),
        ),
      );

      expect(find.text('Amazon Prime Annual'), findsOneWidget);
      expect(find.text('\$120.00'), findsOneWidget);
      expect(find.text('~\$10.00/mo'), findsOneWidget);
      expect(find.text('ANNUAL'), findsOneWidget);
      expect(find.text('Auto-registers on due date'), findsOneWidget);
    });

    testWidgets('renders paused subscription with PAUSED badge and strikethrough', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionCard(
              subscription: pausedSub,
              category: testCategory,
              account: testAccount,
            ),
          ),
        ),
      );

      expect(find.text('Fitness Gym'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('Pay & Advance'), findsNothing);
    });
  });
}
