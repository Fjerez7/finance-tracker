import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/models/analytics_models.dart';
import 'package:finance_tracker/presentation/widgets/charts/category_expense_pie_chart.dart';
import 'package:finance_tracker/presentation/widgets/charts/cash_flow_bar_chart.dart';

void main() {
  group('Chart Widgets Tests', () {
    testWidgets('CategoryExpensePieChart renders empty state when no expenses', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryExpensePieChart(
              summaries: const [],
              selectedIndex: -1,
              onSectionSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('No expenses recorded in this period'), findsOneWidget);
    });

    testWidgets('CategoryExpensePieChart renders pie sections and category legends', (
      WidgetTester tester,
    ) async {
      final summaries = [
        const CategoryExpenseSummary(
          categoryId: 'c1',
          categoryName: 'Food & Dining',
          iconName: 'restaurant',
          colorHex: '#FF5722',
          totalSpentCents: 15000,
          percentage: 60.0,
        ),
        const CategoryExpenseSummary(
          categoryId: 'c2',
          categoryName: 'Transport',
          iconName: 'directions_car',
          colorHex: '#2196F3',
          totalSpentCents: 10000,
          percentage: 40.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategoryExpensePieChart(
                summaries: summaries,
                selectedIndex: 0,
                onSectionSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Food & Dining'), findsWidgets);
      expect(find.text('Transport'), findsWidgets);
      expect(find.text(r'$150.00'), findsWidgets);
      expect(find.text(r'$100.00'), findsWidgets);
      expect(find.text('60.0%'), findsWidgets);
      expect(find.text('40.0%'), findsWidgets);
    });

    testWidgets('CashFlowBarChart renders empty state when no summaries', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CashFlowBarChart(
              cashFlows: [],
            ),
          ),
        ),
      );

      expect(find.text('No cashflow data available'), findsOneWidget);
    });

    testWidgets('CashFlowBarChart renders bars and legends when summaries present', (
      WidgetTester tester,
    ) async {
      final summaries = [
        const MonthlyCashFlowSummary(
          month: 8,
          year: 2026,
          totalIncomeCents: 400000, // $4,000.00
          totalExpenseCents: 250000, // $2,500.00
        ),
        const MonthlyCashFlowSummary(
          month: 9,
          year: 2026,
          totalIncomeCents: 450000, // $4,500.00
          totalExpenseCents: 220000, // $2,200.00
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CashFlowBarChart(
                cashFlows: summaries,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.byType(CashFlowBarChart), findsOneWidget);
    });
  });
}
