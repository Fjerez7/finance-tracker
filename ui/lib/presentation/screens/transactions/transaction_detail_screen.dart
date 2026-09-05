import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/transaction.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';

/// Screen displaying complete details for a single financial transaction.
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final txProv = context.watch<TransactionsProvider>();
    final accountsProv = context.watch<AccountsProvider>();

    final category = txProv.getCategoryById(transaction.categoryId);
    final sourceAccount = accountsProv.accounts
        .where((a) => a.id == transaction.accountId)
        .firstOrNull;
    final destAccount = transaction.toAccountId != null
        ? accountsProv.accounts
              .where((a) => a.id == transaction.toAccountId)
              .firstOrNull
        : null;

    final currencyCode = sourceAccount?.currency ?? 'USD';

    Color amountColor;
    String typeLabel;
    String signPrefix;

    switch (transaction.type) {
      case TransactionType.expense:
        amountColor = Colors.red.shade600;
        typeLabel = 'Expense';
        signPrefix = '-';
        break;
      case TransactionType.income:
        amountColor = Colors.green.shade600;
        typeLabel = 'Income';
        signPrefix = '+';
        break;
      case TransactionType.transfer:
        amountColor = colorScheme.primary;
        typeLabel = 'Account Transfer';
        signPrefix = '';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: colorScheme.error,
            tooltip: 'Delete Transaction',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount Hero Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: amountColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          typeLabel.toUpperCase(),
                          style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$signPrefix${CurrencyFormatter.formatCents(transaction.amountCents, symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ')}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat(
                          'EEEE, MMMM d, yyyy • h:mm a',
                        ).format(transaction.transactionDate.toLocal()),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metadata Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (category != null) ...[
                      _buildDetailRow(
                        context,
                        label: 'Category',
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: ColorHelper.hexToColor(
                                category.colorHex,
                              ),
                              child: Icon(
                                IconHelper.getIconData(category.iconName),
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],

                    _buildDetailRow(
                      context,
                      label: transaction.type == TransactionType.transfer
                          ? 'Source Account'
                          : 'Account',
                      child: Text(
                        sourceAccount?.name ?? 'Unknown Account',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    if (transaction.type == TransactionType.transfer &&
                        destAccount != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        label: 'Destination Account',
                        child: Text(
                          destAccount.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],

                    if (transaction.description.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        label: 'Description / Note',
                        child: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],

                    const Divider(),
                    _buildDetailRow(
                      context,
                      label: 'Transaction ID',
                      child: Text(
                        transaction.id,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          child,
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
          'This will permanently delete this transaction and automatically reverse its effect on your account balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final txProv = context.read<TransactionsProvider>();
      final accountsProv = context.read<AccountsProvider>();
      await txProv.deleteTransaction(
        transaction.id,
        accountsProvider: accountsProv,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
