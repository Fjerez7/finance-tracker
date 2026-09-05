/// Data transfer object representing total expense aggregation for a category.
class CategoryExpenseSummary {
  final String categoryId;
  final String categoryName;
  final String colorHex;
  final String iconName;
  final int totalSpentCents;
  final double percentage; // e.g. 24.5

  const CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.colorHex,
    required this.iconName,
    required this.totalSpentCents,
    required this.percentage,
  });
}

/// Data transfer object comparing spending between current and previous calendar months.
class MonthOverMonthComparison {
  final int currentMonthSpentCents;
  final int previousMonthSpentCents;
  final double percentageChange; // e.g. +12.5 or -8.0
  final bool isIncrease;

  const MonthOverMonthComparison({
    required this.currentMonthSpentCents,
    required this.previousMonthSpentCents,
    required this.percentageChange,
    required this.isIncrease,
  });
}

/// Data transfer object representing monthly income, expense, and net savings.
class MonthlyCashFlowSummary {
  final int month;
  final int year;
  final int totalIncomeCents;
  final int totalExpenseCents;

  const MonthlyCashFlowSummary({
    required this.month,
    required this.year,
    required this.totalIncomeCents,
    required this.totalExpenseCents,
  });

  /// Net savings in integer cents (Income - Expense).
  int get netSavingsCents => totalIncomeCents - totalExpenseCents;

  /// Savings rate percentage from 0.0% to 100.0%.
  double get savingsRatePercentage =>
      totalIncomeCents > 0
          ? ((netSavingsCents / totalIncomeCents) * 100).clamp(0.0, 100.0)
          : 0.0;
}
