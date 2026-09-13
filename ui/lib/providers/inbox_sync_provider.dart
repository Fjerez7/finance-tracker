import 'package:flutter/foundation.dart';
import '../domain/usecases/sync_inbox_transactions_usecase.dart';
import 'accounts_provider.dart';
import 'transactions_provider.dart';

/// Provider managing the bank email transaction synchronization lifecycle.
class InboxSyncProvider extends ChangeNotifier {
  final SyncInboxTransactionsUseCase _syncUseCase;

  bool _isSyncing = false;
  int _lastSyncedCount = 0;
  DateTime? _lastSyncTime;
  String? _errorMessage;

  InboxSyncProvider({required SyncInboxTransactionsUseCase syncUseCase})
      : _syncUseCase = syncUseCase;

  bool get isSyncing => _isSyncing;
  int get lastSyncedCount => _lastSyncedCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Triggers immediate synchronization of pending transactions from Firestore into SQLite.
  Future<int> syncNow({
    String userId = 'user_default',
    AccountsProvider? accountsProvider,
    TransactionsProvider? transactionsProvider,
  }) async {
    if (_isSyncing) return 0;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int count = await _syncUseCase(userId: userId);
      _lastSyncedCount = count;
      _lastSyncTime = DateTime.now();

      if (count > 0) {
        // Refresh local data feeds
        if (accountsProvider != null) {
          await accountsProvider.loadAccounts();
        }
        if (transactionsProvider != null) {
          await transactionsProvider.fetchTransactions();
          await transactionsProvider.fetchRecentTransactions();
        }
      }

      _isSyncing = false;
      notifyListeners();
      return count;
    } catch (e) {
      _errorMessage = e.toString();
      _isSyncing = false;
      notifyListeners();
      return 0;
    }
  }

  /// Clears the last error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
