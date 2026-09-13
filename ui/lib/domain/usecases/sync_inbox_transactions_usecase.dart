import '../repositories/inbox_repository.dart';

/// Use case to synchronize all pending bank email transactions from Firestore to SQLite.
class SyncInboxTransactionsUseCase {
  final InboxRepository _inboxRepository;

  SyncInboxTransactionsUseCase(this._inboxRepository);

  /// Executes the synchronization pipeline from Firestore staging.
  /// Returns the number of new transactions persisted.
  Future<int> call({String userId = 'user_default'}) async {
    return await _inboxRepository.syncPendingTransactions(userId: userId);
  }

  /// Executes direct Gmail API synchronization.
  Future<int> syncFromGmail({
    required Map<String, String> authHeaders,
    required String geminiApiKey,
    List<String>? bankSenders,
  }) async {
    return await _inboxRepository.syncDirectFromGmail(
      authHeaders: authHeaders,
      geminiApiKey: geminiApiKey,
      bankSenders: bankSenders,
    );
  }
}
