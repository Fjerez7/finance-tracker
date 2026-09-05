import '../entities/savings_goal.dart';

/// Contract interface for managing target savings objectives and allocations.
abstract class SavingsGoalRepository {
  /// Fetches savings goals optionally filtered by completion status.
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted});

  /// Fetches a single savings goal by unique [id].
  Future<SavingsGoal?> getSavingsGoalById(String id);

  /// Creates a new savings goal target.
  Future<void> createSavingsGoal(SavingsGoal goal);

  /// Updates an existing savings goal.
  Future<void> updateSavingsGoal(SavingsGoal goal);

  /// Deletes a savings goal by unique [id].
  Future<void> deleteSavingsGoal(String id);

  /// Updates accumulated funds and checks if goal is completed.
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents);
}
