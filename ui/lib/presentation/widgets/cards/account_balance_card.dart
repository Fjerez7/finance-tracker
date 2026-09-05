import 'package:flutter/material.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/account.dart';

/// Card widget displaying account summary with balance and credit utilization.
class AccountBalanceCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountBalanceCard({super.key, required this.account, this.onTap});

  String _getAccountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.digitalWallet:
        return 'Digital Wallet';
      case AccountType.cash:
        return 'Cash';
      case AccountType.creditCard:
        return 'Credit Card';
    }
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization < 0.30) return Colors.green;
    if (utilization < 0.70) return Colors.amber.shade700;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = ColorHelper.hexToColor(account.colorHex);
    final IconData iconData = IconHelper.getIconData(account.iconName);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: themeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getAccountTypeLabel(account.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCents(account.balanceCents),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: account.isCreditCard
                          ? (account.balanceCents > 0
                                ? Colors.red.shade700
                                : Colors.grey.shade800)
                          : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              if (account.isCreditCard && account.creditLimitCents > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: account.creditUtilizationRate,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getUtilizationColor(account.creditUtilizationRate),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available: ${CurrencyFormatter.formatCents(account.availableCreditCents)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.formatPercentage(account.creditUtilizationRate)} used of ${CurrencyFormatter.formatCents(account.creditLimitCents)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getUtilizationColor(
                          account.creditUtilizationRate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
