import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';

/// Presentation card / tile rendering a single financial transaction.
class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.toAccount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyCode = account?.currency ?? 'USD';

    // Visual attributes depending on transaction type
    IconData iconData;
    Color itemColor;
    String titleText;
    String signPrefix;
    Color amountColor;

    switch (transaction.type) {
      case TransactionType.expense:
        iconData = category != null
            ? IconHelper.getIconData(category!.iconName)
            : Icons.shopping_bag_outlined;
        itemColor = category != null
            ? ColorHelper.hexToColor(category!.colorHex)
            : colorScheme.error;
        titleText = category?.name ?? 'Expense';
        signPrefix = '-';
        amountColor = Colors.red.shade600;
        break;

      case TransactionType.income:
        iconData = category != null
            ? IconHelper.getIconData(category!.iconName)
            : Icons.payments_outlined;
        itemColor = category != null
            ? ColorHelper.hexToColor(category!.colorHex)
            : Colors.green.shade600;
        titleText = category?.name ?? 'Income';
        signPrefix = '+';
        amountColor = Colors.green.shade600;
        break;

      case TransactionType.transfer:
        iconData = Icons.swap_horiz;
        itemColor = colorScheme.primary;
        final fromName = account?.name ?? 'Account';
        final toName = toAccount?.name ?? 'Account';
        titleText = '$fromName ➔ $toName';
        signPrefix = '';
        amountColor = colorScheme.primary;
        break;
    }

    final formattedAmount = CurrencyFormatter.formatCents(
      transaction.amountCents,
      symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ',
    );
    final formattedDate = DateFormat(
      'MMM d, h:mm a',
    ).format(transaction.transactionDate.toLocal());

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Category / Action Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: itemColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Details (Title, Description, Date, Account Tag)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (transaction.type != TransactionType.transfer &&
                            account != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              account!.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (transaction.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Amount
              Text(
                '$signPrefix$formattedAmount',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
