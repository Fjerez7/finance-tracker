import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';
import 'package:finance_tracker/domain/repositories/inbox_repository.dart';
import 'package:finance_tracker/domain/usecases/sync_inbox_transactions_usecase.dart';
import 'package:finance_tracker/providers/inbox_sync_provider.dart';
import 'package:finance_tracker/services/gmail_auth_service.dart';

class MockInboxRepository implements InboxRepository {
  int countToReturn = 2;
  bool shouldThrow = false;
  bool directGmailCalled = false;

  @override
  Future<List<InboxTransaction>> getPendingTransactions({String userId = 'user_default'}) async => [];

  @override
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'}) async {}

  @override
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'}) async {}

  @override
  Future<int> syncPendingTransactions({String userId = 'user_default'}) async {
    if (shouldThrow) throw Exception('Network timeout');
    return countToReturn;
  }

  @override
  Future<int> syncDirectFromGmail({
    required Map<String, String> authHeaders,
    required String geminiApiKey,
    List<String>? bankSenders,
  }) async {
    directGmailCalled = true;
    if (shouldThrow) throw Exception('Gmail sync failed');
    return countToReturn;
  }
}

class FakeGmailAuthService implements GmailAuthService {
  final _controller = StreamController<GoogleSignInAccount?>.broadcast();
  bool isSignedIn = false;

  @override
  Stream<GoogleSignInAccount?> get authStateChanges => _controller.stream;

  @override
  GoogleSignInAccount? get currentUser => null;

  @override
  Future<Map<String, String>> getAuthHeaders() async => {'Authorization': 'Bearer test_token'};

  @override
  Future<GoogleSignInAccount?> signIn() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<GoogleSignInAccount?> signInSilently() async => null;

  @override
  Future<bool> isAuthorized() async => isSignedIn;
}

void main() {
  group('InboxSyncProvider Tests', () {
    late MockInboxRepository mockRepo;
    late SyncInboxTransactionsUseCase syncUseCase;
    late InboxSyncProvider provider;

    setUp(() {
      mockRepo = MockInboxRepository();
      syncUseCase = SyncInboxTransactionsUseCase(mockRepo);
      provider = InboxSyncProvider(syncUseCase: syncUseCase);
    });

    test('initial state is idle with 0 synced count', () {
      expect(provider.isSyncing, isFalse);
      expect(provider.lastSyncedCount, equals(0));
      expect(provider.lastSyncTime, isNull);
      expect(provider.hasError, isFalse);
    });

    test('syncNow updates state and records synced count on success (Firestore fallback)', () async {
      final int count = await provider.syncNow();

      expect(count, equals(2));
      expect(provider.isSyncing, isFalse);
      expect(provider.lastSyncedCount, equals(2));
      expect(provider.lastSyncTime, isNotNull);
      expect(provider.hasError, isFalse);
    });

    test('syncNow captures error gracefully', () async {
      mockRepo.shouldThrow = true;

      final int count = await provider.syncNow();

      expect(count, equals(0));
      expect(provider.isSyncing, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Network timeout'));
    });

    test('clearError resets error state', () {
      mockRepo.shouldThrow = true;
      provider.clearError();
      expect(provider.errorMessage, isNull);
      expect(provider.hasError, isFalse);
    });
  });
}
