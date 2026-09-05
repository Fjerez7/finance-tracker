import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/subscription.dart';

/// Card widget rendering a subscription with due date indicators and 1-tap pay action.
class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final Category? category;
  final Account? account;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.category,
    this.account,
    this.onTap,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyCode = account?.currency ?? 'USD';

    final categoryColor =
        category != null
            ? ColorHelper.hexToColor(category!.colorHex)
            : colorScheme.primary;
    final iconData =
        category != null
            ? IconHelper.getIconData(category!.iconName)
            : Icons.subscriptions;

    final dueDateInfo = _calculateDueStatus(subscription.nextDueDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              dueDateInfo.isOverdue
                  ? colorScheme.error.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service / Category Icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: categoryColor, size: 24),
                  ),
                  const SizedBox(width: 14),

                  // Service Name, Account Tag, and Due Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscription.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  decoration:
                                      subscription.isActive
                                          ? null
                                          : TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!subscription.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PAUSED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (account != null) ...[
                              Text(
                                account!.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              subscription.frequency.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Due status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: dueDateInfo.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dueDateInfo.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: dueDateInfo.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Amount & Monthly Burn Rate
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatCents(
                          subscription.amountCents,
                          symbol:
                              currencyCode == 'USD' ? '\$' : '$currencyCode ',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subscription.frequency !=
                          RecurrenceFrequency.monthly) ...[
                        const SizedBox(height: 2),
                        Text(
                          '~${CurrencyFormatter.formatCents(subscription.monthlyEquivalentCents, symbol: currencyCode == 'USD' ? '\$' : '$currencyCode ')}/mo',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Bottom 1-Tap Pay Action Row (if active)
              if (subscription.isActive) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          subscription.autoRegister
                              ? Icons.auto_mode
                              : Icons.touch_app_outlined,
                          size: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscription.autoRegister
                              ? 'Auto-registers on due date'
                              : 'Manual confirmation',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (onPay != null)
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Pay & Advance', style: TextStyle(fontSize: 12)),
                        onPressed: onPay,
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

  _DueStatusInfo _calculateDueStatus(DateTime nextDueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );
    final diffDays = due.difference(today).inDays;

    if (diffDays < 0) {
      return _DueStatusInfo(
        label: 'Overdue (${diffDays.abs()} days)',
        backgroundColor: Colors.red.shade100,
        textColor: Colors.red.shade800,
        isOverdue: true,
      );
    } else if (diffDays == 0) {
      return _DueStatusInfo(
        label: 'Due Today',
        backgroundColor: Colors.orange.shade100,
        textColor: Colors.orange.shade900,
        isOverdue: false,
      );
    } else if (diffDays == 1) {
      return _DueStatusInfo(
        label: 'Due Tomorrow',
        backgroundColor: Colors.amber.shade100,
        textColor: Colors.amber.shade900,
        isOverdue: false,
      );
    } else {
      return _DueStatusInfo(
        label: 'Due in $diffDays days (${DateFormat('MMM d').format(nextDueDate)})',
        backgroundColor: Colors.blue.shade50,
        textColor: Colors.blue.shade800,
        isOverdue: false,
      );
    }
  }
}

class _DueStatusInfo {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isOverdue;

  const _DueStatusInfo({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isOverdue,
  });
}
