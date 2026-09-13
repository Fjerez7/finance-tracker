import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';
import 'package:finance_tracker/domain/repositories/inbox_repository.dart';
import 'package:finance_tracker/domain/usecases/sync_inbox_transactions_usecase.dart';
import 'package:finance_tracker/providers/inbox_sync_provider.dart';

class MockInboxRepository implements InboxRepository {
  int countToReturn = 2;
  bool shouldThrow = false;

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

    test('syncNow updates state and records synced count on success', () async {
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
  });
}
