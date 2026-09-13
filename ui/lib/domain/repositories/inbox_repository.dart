import '../entities/inbox_transaction.dart';

/// Repository contract for staged inbox transactions and local synchronization.
abstract class InboxRepository {
  /// Retrieves pending transactions from remote staging.
  Future<List<InboxTransaction>> getPendingTransactions({String userId = 'user_default'});

  /// Ingests all pending transactions, matches accounts/categories, writes to SQLite, and ACKs Firestore.
  /// Returns the count of successfully synchronized transactions.
  Future<int> syncPendingTransactions({String userId = 'user_default'});

  /// Marks a specific staged transaction as synced in remote staging.
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'});

  /// Marks a specific staged transaction as discarded.
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'});
}
