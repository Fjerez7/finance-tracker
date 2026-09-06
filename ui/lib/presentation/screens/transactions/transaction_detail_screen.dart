import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/category_localization_helper.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/transaction.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
    final bool isForeign = transaction.originalCurrency != null &&
        transaction.originalAmountCents != null &&
        transaction.originalCurrency != currencyCode;

    Color amountColor;
    String typeLabel;
    String signPrefix;

    switch (transaction.type) {
      case TransactionType.expense:
        amountColor = Colors.red.shade600;
        typeLabel = l10n.expense;
        signPrefix = '-';
        break;
      case TransactionType.income:
        amountColor = Colors.green.shade600;
        typeLabel = l10n.income;
        signPrefix = '+';
        break;
      case TransactionType.transfer:
        amountColor = colorScheme.primary;
        typeLabel = l10n.accountTransfer;
        signPrefix = '';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: colorScheme.error,
            tooltip: l10n.delete,
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
                        isForeign
                            ? '$signPrefix${CurrencyFormatter.formatCents(transaction.originalAmountCents!, symbol: transaction.originalCurrency == 'USD' ? '\$' : '${transaction.originalCurrency} ')}'
                            : '$signPrefix${CurrencyFormatter.formatCents(transaction.amountCents, symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ')}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      if (isForeign) ...[
                        const SizedBox(height: 4),
                        Text(
                          '(~$signPrefix${CurrencyFormatter.formatCents(transaction.amountCents, symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ')})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                        label: l10n.category,
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
                              CategoryLocalizationHelper.getLocalizedName(
                                context,
                                categoryId: category.id,
                                defaultName: category.name,
                              ),
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
                          ? l10n.sourceAccount
                          : l10n.account,
                      child: Text(
                        sourceAccount?.name ?? l10n.unknownAccount,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    if (transaction.type == TransactionType.transfer &&
                        destAccount != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        label: l10n.destinationAccount,
                        child: Text(
                          destAccount.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],

                    if (isForeign) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        label: l10n.originalAmount,
                        child: Text(
                          '${CurrencyFormatter.formatCents(transaction.originalAmountCents!, symbol: transaction.originalCurrency == 'USD' ? '\$' : '${transaction.originalCurrency} ')} ${transaction.originalCurrency}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (transaction.exchangeRate != null) ...[
                        const Divider(),
                        _buildDetailRow(
                          context,
                          label: l10n.exchangeRate,
                          child: Text(
                            '1 ${transaction.originalCurrency} = ${transaction.exchangeRate! < 1 ? transaction.exchangeRate!.toStringAsFixed(6) : transaction.exchangeRate!.toStringAsFixed(2)} $currencyCode',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                      const Divider(),
                      _buildDetailRow(
                        context,
                        label: l10n.debitedAmount,
                        child: Text(
                          '${CurrencyFormatter.formatCents(transaction.amountCents, symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ')} $currencyCode',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],

                    if (transaction.description.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        label: l10n.noteOrDescription,
                        child: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],

                    const Divider(),
                    _buildDetailRow(
                      context,
                      label: l10n.transactionId,
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTransactionQuestion),
        content: Text(
          l10n.confirmDeleteTransactionDetail,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
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
