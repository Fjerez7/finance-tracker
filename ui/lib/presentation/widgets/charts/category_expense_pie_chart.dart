import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/models/analytics_models.dart';

/// Interactive pie/donut chart rendering category expense distributions with fl_chart.
class CategoryExpensePieChart extends StatefulWidget {
  final List<CategoryExpenseSummary> summaries;
  final int selectedIndex;
  final ValueChanged<int>? onSectionSelected;

  const CategoryExpensePieChart({
    super.key,
    required this.summaries,
    this.selectedIndex = -1,
    this.onSectionSelected,
  });

  @override
  State<CategoryExpensePieChart> createState() =>
      _CategoryExpensePieChartState();
}

class _CategoryExpensePieChartState extends State<CategoryExpensePieChart> {
  late int _touchedIndex;

  @override
  void initState() {
    super.initState();
    _touchedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant CategoryExpensePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _touchedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.summaries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.donut_large_outlined,
                size: 48,
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No expenses recorded in this period',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int totalExpenseCents = widget.summaries.fold(
      0,
      (sum, s) => sum + s.totalSpentCents,
    );

    return Column(
      children: [
        // Pie Chart with center hole
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          widget.onSectionSelected?.call(-1);
                          return;
                        }
                        _touchedIndex =
                            pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                        widget.onSectionSelected?.call(_touchedIndex);
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _buildSections(colorScheme),
                ),
              ),
              // Center Text Display
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _touchedIndex >= 0 &&
                            _touchedIndex < widget.summaries.length
                        ? widget.summaries[_touchedIndex].categoryName
                        : 'Total Expense',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatCents(
                      _touchedIndex >= 0 &&
                              _touchedIndex < widget.summaries.length
                          ? widget.summaries[_touchedIndex].totalSpentCents
                          : totalExpenseCents,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_touchedIndex >= 0 &&
                      _touchedIndex < widget.summaries.length)
                    Text(
                      '${widget.summaries[_touchedIndex].percentage}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Category Legend List
        ...List.generate(widget.summaries.length, (index) {
          final summary = widget.summaries[index];
          final color = ColorHelper.hexToColor(summary.colorHex);
          final iconData = IconHelper.getIconData(summary.iconName);
          final isSelected = _touchedIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _touchedIndex = isSelected ? -1 : index;
                widget.onSectionSelected?.call(_touchedIndex);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? color.withValues(alpha: 0.12)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border:
                    isSelected
                        ? Border.all(color: color.withValues(alpha: 0.5))
                        : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      summary.categoryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatCents(summary.totalSpentCents),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${summary.percentage}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(ColorScheme colorScheme) {
    return List.generate(widget.summaries.length, (i) {
      final summary = widget.summaries[i];
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 34.0 : 26.0;
      final color = ColorHelper.hexToColor(summary.colorHex);

      return PieChartSectionData(
        color: color,
        value: summary.totalSpentCents.toDouble(),
        title: '',
        radius: radius,
        badgeWidget: null,
      );
    });
  }
}
