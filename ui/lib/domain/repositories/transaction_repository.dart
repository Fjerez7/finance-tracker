import '../entities/transaction.dart';

/// Contract interface for managing financial transactions.
abstract class TransactionRepository {
  /// Fetches transactions matching the specified optional filter criteria.
  Future<List<Transaction>> getTransactions({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    int? limit,
    int? offset,
  });

  /// Fetches the most recent transactions.
  Future<List<Transaction>> getRecentTransactions({int limit = 20});

  /// Fetches a single transaction by [id].
  Future<Transaction?> getTransactionById(String id);

  /// Creates a transaction and atomically updates the associated account balance(s).
  Future<void> createTransaction(Transaction transaction);

  /// Updates an existing transaction and atomically synchronizes account balance(s).
  Future<void> updateTransaction(Transaction transaction);

  /// Deletes a transaction and atomically reverses its effect on account balance(s).
  Future<void> deleteTransaction(String id);

  /// Returns the count of transactions matching filter parameters.
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  });
}
