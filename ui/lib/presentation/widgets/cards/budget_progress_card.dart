import 'package:flutter/material.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';

/// Card widget rendering a monthly category budget progress bar and alert thresholds.
class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final Category? category;
  final int spentCents;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.category,
    required this.spentCents,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categoryColor =
        category != null
            ? ColorHelper.hexToColor(category!.colorHex)
            : colorScheme.primary;
    final iconData =
        category != null
            ? IconHelper.getIconData(category!.iconName)
            : Icons.category;

    final double ratio = budget.progressRatio(spentCents);
    final double clampedProgress = ratio.clamp(0.0, 1.0);
    final int percentage = (ratio * 100).round();
    final bool isOver = budget.isOverBudget(spentCents);
    final bool isWarning = budget.isApproachingLimit(spentCents);

    final Color statusColor;
    final String statusLabel;
    if (isOver) {
      statusColor = Colors.red.shade600;
      final int overCents = spentCents - budget.limitCents;
      statusLabel = 'Exceeded by ${CurrencyFormatter.formatCents(overCents)}';
    } else if (isWarning) {
      statusColor = Colors.amber.shade800;
      statusLabel = 'Approaching limit ($percentage%)';
    } else {
      statusColor = Colors.green.shade600;
      final int remCents = budget.remainingCents(spentCents);
      statusLabel = '${CurrencyFormatter.formatCents(remCents)} remaining';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isOver
                  ? Colors.red.shade300
                  : isWarning
                  ? Colors.amber.shade300
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
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
                  // Category Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: categoryColor, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Category Name & Status Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? 'Category Budget',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amounts and Percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatCents(spentCents),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isOver ? statusColor : null,
                        ),
                      ),
                      Text(
                        'of ${CurrencyFormatter.formatCents(budget.limitCents)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: clampedProgress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
