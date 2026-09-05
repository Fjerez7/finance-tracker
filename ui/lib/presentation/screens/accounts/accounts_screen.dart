import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/account.dart';
import '../../../providers/accounts_provider.dart';
import '../../widgets/cards/account_balance_card.dart';
import 'account_detail_screen.dart';
import 'add_edit_account_screen.dart';

/// Main screen listing all accounts categorized by assets and credit liabilities with real-time Net Worth.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  Widget _buildNetWorthHeader(BuildContext context, AccountsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL NET WORTH',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatCents(provider.netWorthCents),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: provider.netWorthCents >= 0
                  ? Colors.green.shade800
                  : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Assets',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatCents(provider.totalAssetsCents),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: Colors.grey.shade300),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Liabilities',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatCents(
                        provider.totalLiabilitiesCents,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts & Net Worth')),
      body: Consumer<AccountsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Account> assets = provider.assetAccounts;
          final List<Account> creditCards = provider.creditCardAccounts;

          return RefreshIndicator(
            onRefresh: () => provider.loadAccounts(),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              children: [
                // Net Worth Hero
                _buildNetWorthHeader(context, provider),
                const SizedBox(height: 24),

                // Section 1: Liquid Assets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ASSETS (${assets.length})',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (assets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No asset accounts yet. Tap "+" to add one.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ...assets.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AccountBalanceCard(
                        account: account,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AccountDetailScreen(accountId: account.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Section 2: Credit Cards & Liabilities
                if (creditCards.isNotEmpty) ...[
                  Text(
                    'CREDIT CARDS (${creditCards.length})',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...creditCards.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AccountBalanceCard(
                        account: account,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AccountDetailScreen(accountId: account.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 80), // Fab padding
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditAccountScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Account'),
      ),
    );
  }
}
