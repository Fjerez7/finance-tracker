import 'package:flutter/foundation.dart';
import '../domain/usecases/sync_inbox_transactions_usecase.dart';
import '../services/gmail_auth_service.dart';
import 'accounts_provider.dart';
import 'transactions_provider.dart';

/// Provider managing bank email transaction synchronization (Direct Gmail API & Firestore staging).
class InboxSyncProvider extends ChangeNotifier {
  final SyncInboxTransactionsUseCase _syncUseCase;
  final GmailAuthService? _gmailAuthService;

  bool _isSyncing = false;
  int _lastSyncedCount = 0;
  DateTime? _lastSyncTime;
  String? _errorMessage;

  InboxSyncProvider({
    required SyncInboxTransactionsUseCase syncUseCase,
    GmailAuthService? gmailAuthService,
  })  : _syncUseCase = syncUseCase,
        _gmailAuthService = gmailAuthService {
    _gmailAuthService?.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  bool get isSyncing => _isSyncing;
  int get lastSyncedCount => _lastSyncedCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool get isGoogleSignedIn => _gmailAuthService?.currentUser != null;
  String? get googleUserEmail => _gmailAuthService?.currentUser?.email;

  /// Connects Google Account requesting Gmail and Drive scopes.
  Future<bool> connectGoogle() async {
    try {
      final account = await _gmailAuthService?.signIn();
      notifyListeners();
      return account != null;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Disconnects Google Account.
  Future<void> disconnectGoogle() async {
    try {
      await _gmailAuthService?.signOut();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Google Sign-Out failed: $e';
      notifyListeners();
    }
  }

  /// Triggers bank email synchronization (Direct Gmail if connected, or Firestore staging fallback).
  Future<int> syncNow({
    String userId = 'user_default',
    String? geminiApiKey,
    List<String>? bankSenders,
    AccountsProvider? accountsProvider,
    TransactionsProvider? transactionsProvider,
  }) async {
    if (_isSyncing) return 0;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int count = 0;

      // 1. If Google is signed in and Gemini API Key is available, do Direct Gmail Sync
      if (isGoogleSignedIn &&
          geminiApiKey != null &&
          geminiApiKey.trim().isNotEmpty &&
          _gmailAuthService != null) {
        try {
          final authHeaders = await _gmailAuthService.getAuthHeaders();
          count = await _syncUseCase.syncFromGmail(
            authHeaders: authHeaders,
            geminiApiKey: geminiApiKey.trim(),
            bankSenders: bankSenders,
          );
        } catch (e) {
          // If direct sync failed, try Firestore staging fallback
          count = await _syncUseCase(userId: userId);
        }
      } else {
        // 2. Default to Firestore staging fallback
        count = await _syncUseCase(userId: userId);
      }

      _lastSyncedCount = count;
      _lastSyncTime = DateTime.now();

      if (count > 0) {
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
