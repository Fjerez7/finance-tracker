import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/analytics_models.dart';

/// Comparative bar chart rendering monthly income vs expense history using fl_chart.
class CashFlowBarChart extends StatelessWidget {
  final List<MonthlyCashFlowSummary> cashFlows;

  const CashFlowBarChart({super.key, required this.cashFlows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (cashFlows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No cashflow data available',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    // Find max value in cents to scale Y-axis
    int maxCents = 0;
    for (final cf in cashFlows) {
      if (cf.totalIncomeCents > maxCents) maxCents = cf.totalIncomeCents;
      if (cf.totalExpenseCents > maxCents) maxCents = cf.totalExpenseCents;
    }
    final double maxY = maxCents > 0 ? (maxCents / 100.0) * 1.2 : 100.0;

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Income', Colors.green.shade600),
            const SizedBox(width: 20),
            _buildLegendItem('Expense', Colors.red.shade600),
          ],
        ),
        const SizedBox(height: 16),

        // Bar Chart
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final isIncome = rodIndex == 0;
                    final String label = isIncome ? 'Income' : 'Expense';
                    final int cents = (rod.toY * 100).round();
                    return BarTooltipItem(
                      '$label\n${CurrencyFormatter.formatCents(cents)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= cashFlows.length) {
                        return const SizedBox.shrink();
                      }
                      final cf = cashFlows[index];
                      final date = DateTime(cf.year, cf.month);
                      final label = DateFormat('MMM').format(date);

                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(cashFlows.length, (i) {
                final cf = cashFlows[i];
                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    // Income Bar
                    BarChartRodData(
                      toY: cf.totalIncomeCents / 100.0,
                      color: Colors.green.shade600,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    // Expense Bar
                    BarChartRodData(
                      toY: cf.totalExpenseCents / 100.0,
                      color: Colors.red.shade600,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
