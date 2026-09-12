import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_currency.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/account.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import 'add_edit_account_screen.dart';

/// Detail screen displaying account metrics, credit utilization, and account actions.
class AccountDetailScreen extends StatelessWidget {
  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  void _showAdjustBalanceDialog(BuildContext context, Account account) {
    final l10n = AppLocalizations.of(context)!;
    final accountCurrency = AppCurrency.fromCode(account.currency);
    final TextEditingController controller = TextEditingController(
      text: CurrencyFormatter.centsToDouble(
        account.balanceCents,
      ).toStringAsFixed(accountCurrency.decimalDigits),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.adjustBalanceFor(account.name),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterNewReconciledBalance,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                labelText: l10n.newBalance,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final int newCents = CurrencyFormatter.parseToCents(
                  controller.text,
                  currency: AppCurrency.fromCode(account.currency),
                );
                await Provider.of<AccountsProvider>(
                  context,
                  listen: false,
                ).adjustBalance(account.id, newCents);
                if (context.mounted) {
                  Navigator.pop(bottomSheetContext);
                }
              },
              child: Text(l10n.updateBalance),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Account account) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountQuestion),
        content: Text(
          l10n.confirmDeleteAccountNamed(account.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              await Provider.of<AccountsProvider>(
                context,
                listen: false,
              ).deleteAccount(account.id);
              if (context.mounted) {
                Navigator.pop(context); // Close detail screen
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AccountsProvider>(
      builder: (context, provider, _) {
        final Account? account = provider.getAccountById(accountId);

        if (account == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.accountNotFound)),
          );
        }

        final Color color = ColorHelper.hexToColor(account.colorHex);
        final IconData icon = IconHelper.getIconData(account.iconName);

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editAccount,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditAccountScreen(account: account),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'archive') {
                    await provider.toggleArchive(
                      account.id,
                      !account.isArchived,
                    );
                  } else if (action == 'delete') {
                    _confirmDelete(context, account);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(
                      account.isArchived
                          ? l10n.unarchiveAccount
                          : l10n.archiveAccount,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      l10n.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Hero Balance Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.85), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            account.currency,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      account.isCreditCard ? l10n.currentDebt : l10n.currentBalance.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCents(
                        account.balanceCents,
                        currency: AppCurrency.fromCode(account.currency),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Credit Card Metrics
              if (account.isCreditCard) ...[
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.creditLimitAndUtilization,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: account.creditUtilizationRate,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              account.creditUtilizationRate > 0.6
                                  ? Colors.red
                                  : (account.creditUtilizationRate > 0.3
                                        ? Colors.amber.shade700
                                        : Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.availableCredit,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatCents(
                                    account.availableCreditCents,
                                    currency: AppCurrency.fromCode(
                                      account.currency,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.totalLimit,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatCents(
                                    account.creditLimitCents,
                                    currency: AppCurrency.fromCode(
                                      account.currency,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showAdjustBalanceDialog(context, account),
                      icon: const Icon(Icons.tune),
                      label: Text(l10n.adjustBalance),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
