import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/subscription.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/subscriptions_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/cards/subscription_card.dart';
import 'add_edit_subscription_screen.dart';

/// Screen listing recurring subscriptions with monthly burn rate metrics and payment actions.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subsProv = context.watch<SubscriptionsProvider>();
    final txProv = context.watch<TransactionsProvider>();
    final accountsProv = context.watch<AccountsProvider>();

    final activeSubs = subsProv.upcomingDueSubscriptions;
    final inactiveSubs = subsProv.inactiveSubscriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions & Bills'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeSubs.length})'),
            Tab(text: 'Paused (${inactiveSubs.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Monthly Burn Rate Hero Banner
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
                Text(
                  'MONTHLY SUBSCRIPTION COMMITMENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${CurrencyFormatter.formatCents(subsProv.totalMonthlyCommitmentCents)}/mo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.trending_flat,
                      size: 16,
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Annual Projection: ${CurrencyFormatter.formatCents(subsProv.totalAnnualProjectionCents)}/year',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subscriptions Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Subscriptions
                activeSubs.isEmpty
                    ? _buildEmptyState(
                      context,
                      title: 'No active subscriptions',
                      message:
                          'Track fixed commitments like Netflix, Spotify, or Rent by tapping "+"',
                    )
                    : _buildSubscriptionList(
                      context,
                      activeSubs,
                      subsProv,
                      txProv,
                      accountsProv,
                    ),

                // Inactive / Paused Subscriptions
                inactiveSubs.isEmpty
                    ? _buildEmptyState(
                      context,
                      title: 'No paused subscriptions',
                      message: 'Paused subscriptions will appear here',
                    )
                    : _buildSubscriptionList(
                      context,
                      inactiveSubs,
                      subsProv,
                      txProv,
                      accountsProv,
                    ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Subscription',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditSubscriptionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubscriptionList(
    BuildContext context,
    List<Subscription> list,
    SubscriptionsProvider subsProv,
    TransactionsProvider txProv,
    AccountsProvider accountsProv,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final sub = list[index];
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
                builder: (_) => AddEditSubscriptionScreen(subscription: sub),
              ),
            );
          },
          onPay:
              sub.isActive
                  ? () => _confirmAndPay(
                    context,
                    sub,
                    subsProv,
                    txProv,
                    accountsProv,
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndPay(
    BuildContext context,
    Subscription sub,
    SubscriptionsProvider subsProv,
    TransactionsProvider txProv,
    AccountsProvider accountsProv,
  ) async {
    final account = accountsProv.accounts
        .where((a) => a.id == sub.accountId)
        .firstOrNull;
    final currencyCode = account?.currency ?? 'USD';

    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Post ${sub.name} Payment?'),
            content: Text(
              'This will create a real expense transaction of ${CurrencyFormatter.formatCents(sub.amountCents, symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ')} from "${account?.name ?? 'Account'}" and advance the next due date.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Confirm Payment'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await subsProv.postSubscriptionPayment(
          sub,
          transactionsProvider: txProv,
          accountsProvider: accountsProv,
        );

        messenger.showSnackBar(
          SnackBar(
            content: Text('Payment recorded for ${sub.name}!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error posting payment: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
