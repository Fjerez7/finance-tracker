import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/providers/analytics_provider.dart';

void main() {
  final now = DateTime(2026, 9, 15);

  final Category foodCat = Category(
    id: 'cat-food',
    name: 'Food & Dining',
    iconName: 'restaurant',
    colorHex: '#FF5722',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final Category transportCat = Category(
    id: 'cat-transport',
    name: 'Transportation',
    iconName: 'directions_car',
    colorHex: '#2196F3',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final List<Transaction> testTransactions = [
    // Sep 2026 transactions
    Transaction(
      id: 'tx-1',
      accountId: 'acc-1',
      categoryId: 'cat-food',
      amountCents: 30000, // $300.00
      type: TransactionType.expense,
      description: 'Groceries & Dining',
      transactionDate: DateTime(2026, 9, 2),
      createdAt: now,
      updatedAt: now,
    ),
    Transaction(
      id: 'tx-2',
      accountId: 'acc-1',
      categoryId: 'cat-transport',
      amountCents: 10000, // $100.00
      type: TransactionType.expense,
      description: 'Gasoline',
      transactionDate: DateTime(2026, 9, 5),
      createdAt: now,
      updatedAt: now,
    ),
    Transaction(
      id: 'tx-3',
      accountId: 'acc-1',
      categoryId: null,
      amountCents: 100000, // $1,000.00 salary
      type: TransactionType.income,
      description: 'Monthly Salary',
      transactionDate: DateTime(2026, 9, 1),
      createdAt: now,
      updatedAt: now,
    ),

    // Aug 2026 transactions
    Transaction(
      id: 'tx-4',
      accountId: 'acc-1',
      categoryId: 'cat-food',
      amountCents: 20000, // $200.00
      type: TransactionType.expense,
      description: 'Aug Food',
      transactionDate: DateTime(2026, 8, 15),
      createdAt: now,
      updatedAt: now,
    ),
    Transaction(
      id: 'tx-5',
      accountId: 'acc-1',
      categoryId: null,
      amountCents: 100000, // $1,000.00
      type: TransactionType.income,
      description: 'Aug Salary',
      transactionDate: DateTime(2026, 8, 1),
      createdAt: now,
      updatedAt: now,
    ),
  ];

  late AnalyticsProvider analyticsProvider;

  setUp(() {
    analyticsProvider = AnalyticsProvider();
  });

  group('AnalyticsProvider Financial Aggregations', () {
    test('computes category expenses with descending order and accurate percentages', () {
      final sepTransactions = analyticsProvider.filterTransactionsByTimeframe(
        testTransactions,
        referenceDate: now,
      );

      final summaries = analyticsProvider.computeCategoryExpenses(
        transactions: sepTransactions,
        categories: [foodCat, transportCat],
      );

      // Total expense = $300 + $100 = $400 (40000 cents)
      expect(summaries.length, equals(2));
      // Food: $300 / $400 = 75.0%
      expect(summaries.first.categoryId, equals('cat-food'));
      expect(summaries.first.totalSpentCents, equals(30000));
      expect(summaries.first.percentage, equals(75.0));

      // Transport: $100 / $400 = 25.0%
      expect(summaries.last.categoryId, equals('cat-transport'));
      expect(summaries.last.totalSpentCents, equals(10000));
      expect(summaries.last.percentage, equals(25.0));
    });

    test('computes month-over-month comparison accurately', () {
      // Sep 2026 expense: $400 (40000 cents)
      // Aug 2026 expense: $200 (20000 cents)
      // Delta: ((400 - 200) / 200) * 100 = +100.0% increase
      final comparison = analyticsProvider.computeMonthOverMonthComparison(
        transactions: testTransactions,
        currentMonth: 9,
        currentYear: 2026,
      );

      expect(comparison.currentMonthSpentCents, equals(40000));
      expect(comparison.previousMonthSpentCents, equals(20000));
      expect(comparison.percentageChange, equals(100.0));
      expect(comparison.isIncrease, isTrue);
    });

    test('computes historical monthly cashflows and net savings', () {
      final cashflows = analyticsProvider.computeRecentMonthlyCashFlows(
        transactions: testTransactions,
        count: 3,
        referenceDate: now,
      );

      expect(cashflows.length, equals(3));

      // Last item should be Sep 2026
      final sepCashflow = cashflows.last;
      expect(sepCashflow.month, equals(9));
      expect(sepCashflow.year, equals(2026));
      expect(sepCashflow.totalIncomeCents, equals(100000)); // $1,000.00
      expect(sepCashflow.totalExpenseCents, equals(40000)); // $400.00
      expect(sepCashflow.netSavingsCents, equals(60000)); // $600.00
      expect(sepCashflow.savingsRatePercentage, equals(60.0)); // 60%
    });

    test('updates selected pie index on selection', () {
      expect(analyticsProvider.selectedPieIndex, equals(-1));
      analyticsProvider.selectPieIndex(2);
      expect(analyticsProvider.selectedPieIndex, equals(2));
      // Tapping same index unselects it
      analyticsProvider.selectPieIndex(2);
      expect(analyticsProvider.selectedPieIndex, equals(-1));
    });
  });
}
