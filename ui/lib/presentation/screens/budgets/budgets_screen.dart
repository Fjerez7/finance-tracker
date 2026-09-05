import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/cards/budget_progress_card.dart';
import 'add_edit_budget_screen.dart';
import 'savings_goals_screen.dart';

/// Screen managing monthly category budget ceilings with period selection and spend gauges.
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetsProv = context.watch<BudgetsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    final selectedMonth = budgetsProv.selectedMonth;
    final selectedYear = budgetsProv.selectedYear;
    final date = DateTime(selectedYear, selectedMonth);
    final monthName = DateFormat('MMMM yyyy').format(date);

    final int totalLimit = budgetsProv.totalMonthlyBudgetLimitCents;
    final int totalSpent = budgetsProv.calculateTotalMonthlySpentCents(txProv);
    final double overallRatio =
        totalLimit > 0 ? (totalSpent / totalLimit) : 0.0;
    final double clampedProgress = overallRatio.clamp(0.0, 1.0);
    final int percentage = (overallRatio * 100).round();
    final bool isOverBudget = totalSpent > totalLimit && totalLimit > 0;
    final bool isWarning = overallRatio >= 0.8 && !isOverBudget;

    final Color statusColor =
        isOverBudget
            ? Colors.red.shade600
            : isWarning
            ? Colors.amber.shade800
            : Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Savings Goals',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous Month',
                  onPressed: budgetsProv.previousMonth,
                ),
                Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next Month',
                  onPressed: budgetsProv.nextMonth,
                ),
              ],
            ),
          ),

          // Total Monthly Budget Hero Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL MONTHLY BUDGET',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage% spent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.formatCents(totalSpent),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'of ${CurrencyFormatter.formatCents(totalLimit)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget ? Colors.red.shade700 : statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isOverBudget
                      ? 'Total budget exceeded by ${CurrencyFormatter.formatCents(totalSpent - totalLimit)}'
                      : '${CurrencyFormatter.formatCents(totalLimit - totalSpent)} left for the month',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Category Budgets Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category Budgets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${budgetsProv.budgets.length} configured',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Budgets List
          Expanded(
            child:
                budgetsProv.budgets.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: budgetsProv.budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgetsProv.budgets[index];
                        final category = txProv.getCategoryById(
                          budget.categoryId,
                        );
                        final spentCents = budgetsProv
                            .calculateCategorySpentCents(
                              budget.categoryId,
                              txProv,
                            );

                        return BudgetProgressCard(
                          budget: budget,
                          category: category,
                          spentCents: spentCents,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        AddEditBudgetScreen(budget: budget),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Budget',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => AddEditBudgetScreen(
                    initialMonth: selectedMonth,
                    initialYear: selectedYear,
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No budgets set for this month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set monthly category limits to keep your spending on track by tapping "+"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
