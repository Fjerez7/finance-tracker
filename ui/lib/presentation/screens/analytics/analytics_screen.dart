import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/charts/cash_flow_bar_chart.dart';
import '../../widgets/charts/category_expense_pie_chart.dart';

/// Deep-dive visual analytics screen displaying timeframes, trends, and comparisons.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final analyticsProv = context.watch<AnalyticsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    final now = DateTime.now();
    final filteredTxs = analyticsProv.filterTransactionsByTimeframe(
      txProv.transactions,
      referenceDate: now,
    );

    final int totalIncomeCents = filteredTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amountCents);

    final int totalExpenseCents = filteredTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amountCents);

    final int netSavingsCents = totalIncomeCents - totalExpenseCents;

    final categorySummaries = analyticsProv.computeCategoryExpenses(
      transactions: filteredTxs,
      categories: txProv.categories,
    );

    final momComparison = analyticsProv.computeMonthOverMonthComparison(
      transactions: txProv.transactions,
      currentMonth: now.month,
      currentYear: now.year,
    );

    final recentCashflows = analyticsProv.computeRecentMonthlyCashFlows(
      transactions: txProv.transactions,
      count: 6,
      referenceDate: now,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visual Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // 1. Timeframe Filter Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<AnalyticsTimeframe>(
                segments: const [
                  ButtonSegment(
                    value: AnalyticsTimeframe.thisMonth,
                    label: Text('This Month'),
                  ),
                  ButtonSegment(
                    value: AnalyticsTimeframe.lastMonth,
                    label: Text('Last Month'),
                  ),
                  ButtonSegment(
                    value: AnalyticsTimeframe.last90Days,
                    label: Text('90 Days'),
                  ),
                  ButtonSegment(
                    value: AnalyticsTimeframe.thisYear,
                    label: Text('This Year'),
                  ),
                  ButtonSegment(
                    value: AnalyticsTimeframe.allTime,
                    label: Text('All Time'),
                  ),
                ],
                selected: {analyticsProv.selectedTimeframe},
                onSelectionChanged: (set) {
                  analyticsProv.setTimeframe(set.first);
                },
              ),
            ),
          ),

          // 2. Summary Metrics Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Income',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCents(totalIncomeCents),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Expense',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCents(totalExpenseCents),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Flow',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCents(netSavingsCents),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color:
                              netSavingsCents >= 0
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Month-over-Month Comparison Card
          Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          momComparison.isIncrease
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      momComparison.isIncrease
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color:
                          momComparison.isIncrease
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Month-over-Month Spend Delta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          momComparison.isIncrease
                              ? '${momComparison.percentageChange}% more than last month (${CurrencyFormatter.formatCents(momComparison.previousMonthSpentCents)})'
                              : '${momComparison.percentageChange}% less than last month (${CurrencyFormatter.formatCents(momComparison.previousMonthSpentCents)})',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. 6-Month Cash Flow Bar Chart Card
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '6-Month Cash Flow Comparison',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CashFlowBarChart(cashFlows: recentCashflows),
                ],
              ),
            ),
          ),

          // 5. Category Expense Distribution Pie Chart Card
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category Expense Proportions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CategoryExpensePieChart(
                    summaries: categorySummaries,
                    selectedIndex: analyticsProv.selectedPieIndex,
                    onSectionSelected: (idx) {
                      analyticsProv.selectPieIndex(idx);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
