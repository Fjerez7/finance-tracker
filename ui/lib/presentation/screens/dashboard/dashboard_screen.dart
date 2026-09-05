import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/transaction.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/subscriptions_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/cards/hero_net_worth_card.dart';
import '../../widgets/cards/subscription_card.dart';
import '../../widgets/cards/transaction_list_tile.dart';
import '../../widgets/charts/category_expense_pie_chart.dart';
import '../analytics/analytics_screen.dart';
import '../budgets/add_edit_budget_screen.dart';
import '../settings/backup_settings_screen.dart';
import '../subscriptions/add_edit_subscription_screen.dart';
import '../transactions/quick_transaction_screen.dart';
import '../transactions/transaction_detail_screen.dart';

/// Executive dashboard screen combining Net Worth indicators, charts, alerts, and feeds.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accountsProv = context.watch<AccountsProvider>();
    final txProv = context.watch<TransactionsProvider>();
    final subsProv = context.watch<SubscriptionsProvider>();
    final budgetsProv = context.watch<BudgetsProvider>();
    final analyticsProv = context.watch<AnalyticsProvider>();

    final now = DateTime.now();
    final thisMonthTransactions = txProv.transactions.where((t) {
      return t.transactionDate.month == now.month &&
          t.transactionDate.year == now.year;
    }).toList();

    final int monthlyIncomeCents = thisMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amountCents);

    final int monthlyExpenseCents = thisMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amountCents);

    final categorySummaries = analyticsProv.computeCategoryExpenses(
      transactions: thisMonthTransactions,
      categories: txProv.categories,
    );

    final overdueOrDueSoonSubs = [
      ...subsProv.overdueSubscriptions,
      ...subsProv.dueSoonSubscriptions,
    ];

    final recentTransactions = txProv.recentTransactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finance Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Cloud Backup & Export',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupSettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Visual Analytics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            accountsProv.loadAccounts(),
            txProv.fetchTransactions(),
            subsProv.loadSubscriptions(),
            budgetsProv.loadBudgetsForSelectedPeriod(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            // 1. Hero Net Worth Card
            HeroNetWorthCard(
              netWorthCents: accountsProv.netWorthCents,
              totalAssetsCents: accountsProv.totalAssetsCents,
              totalLiabilitiesCents: accountsProv.totalLiabilitiesCents,
              monthlyIncomeCents: monthlyIncomeCents,
              monthlyExpenseCents: monthlyExpenseCents,
            ),

            // 2. Quick Action Shortcuts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.add_circle_outline,
                      label: 'Expense',
                      color: Colors.red.shade700,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuickTransactionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.pie_chart_outline,
                      label: 'Budget',
                      color: Colors.blue.shade700,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditBudgetScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.calendar_month_outlined,
                      label: 'Bill/Sub',
                      color: Colors.purple.shade700,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditSubscriptionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 3. Upcoming / Overdue Bills Alert Section (if any)
            if (overdueOrDueSoonSubs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Upcoming Bills & Renewals',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...overdueOrDueSoonSubs.take(2).map((sub) {
                final category = txProv.getCategoryById(sub.categoryId);
                final account = accountsProv.accounts
                    .where((a) => a.id == sub.accountId)
                    .firstOrNull;
                return SubscriptionCard(
                  subscription: sub,
                  category: category,
                  account: account,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => AddEditSubscriptionScreen(subscription: sub),
                      ),
                    );
                  },
                );
              }),
            ],

            // 4. Monthly Expense Distribution Pie Chart
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Expense Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AnalyticsScreen(),
                              ),
                            );
                          },
                          child: const Text('Analytics'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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

            // 5. Recent Transactions Feed
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (recentTransactions.isNotEmpty)
                    Text(
                      'Last ${recentTransactions.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No transactions recorded yet',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ...recentTransactions.map((tx) {
                final category = txProv.getCategoryById(tx.categoryId);
                final account = accountsProv.accounts
                    .where((a) => a.id == tx.accountId)
                    .firstOrNull;

                return TransactionListTile(
                  transaction: tx,
                  category: category,
                  account: account,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => TransactionDetailScreen(transaction: tx),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      onPressed: onTap,
    );
  }
}
