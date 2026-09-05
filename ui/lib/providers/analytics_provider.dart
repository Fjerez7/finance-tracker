import 'package:flutter/foundation.dart' hide Category;
import '../domain/entities/category.dart';
import '../domain/entities/transaction.dart';
import '../domain/models/analytics_models.dart';

/// Supported filter timeframes for analytical aggregations.
enum AnalyticsTimeframe {
  thisMonth,
  lastMonth,
  last90Days,
  thisYear,
  allTime,
}

/// Reactive provider generating financial aggregations, chart distributions, and trend analytics.
class AnalyticsProvider extends ChangeNotifier {
  AnalyticsTimeframe _selectedTimeframe = AnalyticsTimeframe.thisMonth;
  int _selectedPieIndex = -1;

  AnalyticsTimeframe get selectedTimeframe => _selectedTimeframe;
  int get selectedPieIndex => _selectedPieIndex;

  void setTimeframe(AnalyticsTimeframe timeframe) {
    _selectedTimeframe = timeframe;
    _selectedPieIndex = -1;
    notifyListeners();
  }

  void selectPieIndex(int index) {
    if (_selectedPieIndex == index) {
      _selectedPieIndex = -1;
    } else {
      _selectedPieIndex = index;
    }
    notifyListeners();
  }

  /// Filters transactions based on active timeframe.
  List<Transaction> filterTransactionsByTimeframe(
    List<Transaction> transactions, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    switch (_selectedTimeframe) {
      case AnalyticsTimeframe.thisMonth:
        return transactions.where((t) {
          return t.transactionDate.month == now.month &&
              t.transactionDate.year == now.year;
        }).toList();

      case AnalyticsTimeframe.lastMonth:
        int prevMonth = now.month - 1;
        int prevYear = now.year;
        if (prevMonth < 1) {
          prevMonth = 12;
          prevYear -= 1;
        }
        return transactions.where((t) {
          return t.transactionDate.month == prevMonth &&
              t.transactionDate.year == prevYear;
        }).toList();

      case AnalyticsTimeframe.last90Days:
        final cutoff = now.subtract(const Duration(days: 90));
        return transactions.where((t) {
          return t.transactionDate.isAfter(cutoff) ||
              t.transactionDate.isAtSameMomentAs(cutoff);
        }).toList();

      case AnalyticsTimeframe.thisYear:
        return transactions.where((t) {
          return t.transactionDate.year == now.year;
        }).toList();

      case AnalyticsTimeframe.allTime:
        return List.from(transactions);
    }
  }

  /// Computes category expense summaries with percentages, sorted descending by spend.
  List<CategoryExpenseSummary> computeCategoryExpenses({
    required List<Transaction> transactions,
    required List<Category> categories,
  }) {
    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList();

    final int totalExpenseCents = expenseTransactions.fold(
      0,
      (sum, t) => sum + t.amountCents,
    );

    if (totalExpenseCents == 0) return [];

    final Map<String, int> spendByCategoryId = {};
    for (final tx in expenseTransactions) {
      final catId = tx.categoryId ?? 'cat_uncategorized';
      spendByCategoryId[catId] = (spendByCategoryId[catId] ?? 0) + tx.amountCents;
    }

    final List<CategoryExpenseSummary> summaries = [];
    final categoryMap = {for (final c in categories) c.id: c};

    spendByCategoryId.forEach((catId, spentCents) {
      final category = categoryMap[catId];
      final double percentage = (spentCents / totalExpenseCents) * 100.0;

      summaries.add(
        CategoryExpenseSummary(
          categoryId: catId,
          categoryName: category?.name ?? 'Other / Uncategorized',
          colorHex: category?.colorHex ?? '#9E9E9E',
          iconName: category?.iconName ?? 'more_horiz',
          totalSpentCents: spentCents,
          percentage: double.parse(percentage.toStringAsFixed(1)),
        ),
      );
    });

    // Sort descending by highest spend
    summaries.sort((a, b) => b.totalSpentCents.compareTo(a.totalSpentCents));
    return summaries;
  }

  /// Computes month-over-month comparison metrics for a given calendar month and year.
  MonthOverMonthComparison computeMonthOverMonthComparison({
    required List<Transaction> transactions,
    required int currentMonth,
    required int currentYear,
  }) {
    int prevMonth = currentMonth - 1;
    int prevYear = currentYear;
    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear -= 1;
    }

    final currentMonthExpenses = transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.transactionDate.month == currentMonth &&
          t.transactionDate.year == currentYear;
    }).fold(0, (sum, t) => sum + t.amountCents);

    final prevMonthExpenses = transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.transactionDate.month == prevMonth &&
          t.transactionDate.year == prevYear;
    }).fold(0, (sum, t) => sum + t.amountCents);

    double deltaPercent = 0.0;
    if (prevMonthExpenses > 0) {
      deltaPercent =
          ((currentMonthExpenses - prevMonthExpenses) / prevMonthExpenses) *
          100.0;
    } else if (currentMonthExpenses > 0) {
      deltaPercent = 100.0;
    }

    return MonthOverMonthComparison(
      currentMonthSpentCents: currentMonthExpenses,
      previousMonthSpentCents: prevMonthExpenses,
      percentageChange: double.parse(deltaPercent.abs().toStringAsFixed(1)),
      isIncrease: currentMonthExpenses > prevMonthExpenses,
    );
  }

  /// Computes historical monthly cash flows (Income vs Expense) for the past N months.
  List<MonthlyCashFlowSummary> computeRecentMonthlyCashFlows({
    required List<Transaction> transactions,
    int count = 6,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final List<MonthlyCashFlowSummary> results = [];

    for (int i = count - 1; i >= 0; i--) {
      int targetMonth = now.month - i;
      int targetYear = now.year;
      while (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      final monthTxs = transactions.where((t) {
        return t.transactionDate.month == targetMonth &&
            t.transactionDate.year == targetYear;
      });

      final int incomeCents = monthTxs
          .where((t) => t.type == TransactionType.income)
          .fold(0, (sum, t) => sum + t.amountCents);

      final int expenseCents = monthTxs
          .where((t) => t.type == TransactionType.expense)
          .fold(0, (sum, t) => sum + t.amountCents);

      results.add(
        MonthlyCashFlowSummary(
          month: targetMonth,
          year: targetYear,
          totalIncomeCents: incomeCents,
          totalExpenseCents: expenseCents,
        ),
      );
    }

    return results;
  }
}
