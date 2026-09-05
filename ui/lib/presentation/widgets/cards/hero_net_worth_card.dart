import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// Hero presentation card displaying real-time Net Worth, liquid assets, liabilities, and monthly cash flow.
class HeroNetWorthCard extends StatelessWidget {
  final int netWorthCents;
  final int totalAssetsCents;
  final int totalLiabilitiesCents;
  final int monthlyIncomeCents;
  final int monthlyExpenseCents;
  final VoidCallback? onTap;

  const HeroNetWorthCard({
    super.key,
    required this.netWorthCents,
    required this.totalAssetsCents,
    required this.totalLiabilitiesCents,
    this.monthlyIncomeCents = 0,
    this.monthlyExpenseCents = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final int netSavingsCents = monthlyIncomeCents - monthlyExpenseCents;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL NET WORTH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.account_balance,
                    size: 20,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Main Net Worth Typographic Display
              Text(
                CurrencyFormatter.formatCents(netWorthCents),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),

              // Assets vs Liabilities Row
              Row(
                children: [
                  // Assets Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 13,
                                color: Colors.green.shade800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Assets',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            CurrencyFormatter.formatCents(totalAssetsCents),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Liabilities Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                size: 13,
                                color: Colors.red.shade800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Liabilities',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            CurrencyFormatter.formatCents(
                              totalLiabilitiesCents,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Monthly Cashflow Quick Info (if available)
              if (monthlyIncomeCents > 0 || monthlyExpenseCents > 0) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.white24),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'This Month Cash Flow',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                    Text(
                      'Net: ${CurrencyFormatter.formatCents(netSavingsCents)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            netSavingsCents >= 0
                                ? Colors.green.shade900
                                : Colors.red.shade900,
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
