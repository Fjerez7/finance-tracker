import '../entities/budget.dart';

/// Contract interface for managing monthly category budget ceilings.
abstract class BudgetRepository {
  /// Fetches budgets matching the optional criteria (month, year, categoryId).
  Future<List<Budget>> getBudgets({
    int? month,
    int? year,
    String? categoryId,
  });

  /// Fetches a single budget by its unique [id].
  Future<Budget?> getBudgetById(String id);

  /// Fetches a budget specifically set for a [categoryId] in a particular [month] and [year].
  Future<Budget?> getBudgetForCategory(String categoryId, int month, int year);

  /// Creates a new category budget limit.
  Future<void> createBudget(Budget budget);

  /// Updates an existing category budget limit.
  Future<void> updateBudget(Budget budget);

  /// Deletes a budget entry by unique [id].
  Future<void> deleteBudget(String id);
}
