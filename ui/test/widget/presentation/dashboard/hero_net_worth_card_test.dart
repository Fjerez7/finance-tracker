import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/presentation/widgets/cards/hero_net_worth_card.dart';

void main() {
  group('HeroNetWorthCard Widget Tests', () {
    testWidgets('renders positive net worth, assets, liabilities and cashflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroNetWorthCard(
              netWorthCents: 1545000, // $15,450.00
              totalAssetsCents: 2000000, // $20,000.00
              totalLiabilitiesCents: 455000, // $4,550.00
              monthlyIncomeCents: 500000, // $5,000.00
              monthlyExpenseCents: 235000, // $2,350.00
            ),
          ),
        ),
      );

      expect(find.text('TOTAL NET WORTH'), findsOneWidget);
      expect(find.text(r'$15,450.00'), findsOneWidget);
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text(r'$20,000.00'), findsOneWidget);
      expect(find.text('Liabilities'), findsOneWidget);
      expect(find.text(r'$4,550.00'), findsOneWidget);
      expect(find.text('This Month Cash Flow'), findsOneWidget);
      expect(find.text('Net: \$2,650.00'), findsOneWidget);
    });

    testWidgets('renders negative net worth correctly with minus sign', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroNetWorthCard(
              netWorthCents: -500000, // -$5,000.00
              totalAssetsCents: 100000, // $1,000.00
              totalLiabilitiesCents: 600000, // $6,000.00
              monthlyIncomeCents: 0,
              monthlyExpenseCents: 100000,
            ),
          ),
        ),
      );

      expect(find.text(r'-$5,000.00'), findsOneWidget);
      expect(find.text(r'$1,000.00'), findsOneWidget);
      expect(find.text(r'$6,000.00'), findsOneWidget);
    });
  });
}
