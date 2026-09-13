import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/datasources/remote/inbox_remote_datasource.dart';
import 'package:finance_tracker/data/models/inbox_transaction_model.dart';
import 'package:finance_tracker/data/repositories/inbox_repository_impl.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/inbox_transaction.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/subscription_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

// Fake implementations for unit testing
class FakeInboxRemoteDataSource implements InboxRemoteDataSource {
  List<InboxTransactionModel> pending = [];
  final List<String> syncedIds = [];
  final List<String> discardedIds = [];

  @override
  Future<List<InboxTransactionModel>> getPendingTransactions({String userId = 'user_default'}) async {
    return List.of(pending);
  }

  @override
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'}) async {
    syncedIds.add(transactionId);
    pending.removeWhere((item) => item.id == transactionId);
  }

  @override
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'}) async {
    discardedIds.add(transactionId);
    pending.removeWhere((item) => item.id == transactionId);
  }
}

class FakeTransactionRepository implements TransactionRepository {
  final Map<String, Transaction> db = {};

  @override
  Future<void> createTransaction(Transaction transaction) async {
    db[transaction.id] = transaction;
  }

  @override
  Future<Transaction?> getTransactionById(String id) async => db[id];

  @override
  Future<void> deleteTransaction(String id) async => db.remove(id);

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async =>
      db.values.take(limit).toList();

  @override
  Future<List<Transaction>> getTransactions({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    int? limit,
    int? offset,
  }) async => db.values.toList();

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    db[transaction.id] = transaction;
  }

  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async => db.length;
}

class FakeAccountRepository implements AccountRepository {
  List<Account> accounts = [];

  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async => accounts;

  @override
  Future<void> createAccount(Account account) async => accounts.add(account);

  @override
  Future<void> deleteAccount(String id) async => accounts.removeWhere((a) => a.id == id);

  @override
  Future<Account?> getAccountById(String id) async {
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateAccount(Account account) async {}

  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}

  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeCategoryRepository implements CategoryRepository {
  List<Category> categories = [];

  @override
  Future<List<Category>> getCategories({CategoryType? type}) async => categories;

  @override
  Future<void> createCategory(Category category) async => categories.add(category);

  @override
  Future<void> deleteCategory(String id) async => categories.removeWhere((c) => c.id == id);

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {}
}

class FakeSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> subscriptions = [];
  final Map<String, DateTime> updatedDueDates = {};

  @override
  Future<List<Subscription>> getSubscriptions({
    bool? isActive,
    String? accountId,
    String? categoryId,
  }) async {
    if (isActive != null) {
      return subscriptions.where((s) => s.isActive == isActive).toList();
    }
    return subscriptions;
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    try {
      return subscriptions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createSubscription(Subscription subscription) async => subscriptions.add(subscription);

  @override
  Future<void> updateSubscription(Subscription subscription) async {}

  @override
  Future<void> deleteSubscription(String id) async => subscriptions.removeWhere((s) => s.id == id);

  @override
  Future<void> updateNextDueDate(String id, DateTime nextDueDate) async {
    updatedDueDates[id] = nextDueDate;
  }

  @override
  Future<void> toggleActive(String id, bool isActive) async {}
}

void main() {
  group('InboxRepositoryImpl Tests', () {
    late FakeInboxRemoteDataSource fakeRemote;
    late FakeTransactionRepository fakeTxRepo;
    late FakeAccountRepository fakeAccountRepo;
    late FakeCategoryRepository fakeCategoryRepo;
    late FakeSubscriptionRepository fakeSubRepo;
    late InboxRepositoryImpl repository;

    final now = DateTime.parse('2026-09-12T14:30:00.000Z');

    final sampleAccount = Account(
      id: 'acc-bancolombia-cc',
      name: 'Bancolombia Visa *4892',
      type: AccountType.creditCard,
      balanceCents: 5000000,
      currency: 'COP',
      colorHex: '#000000',
      iconName: 'credit_card',
      createdAt: now,
      updatedAt: now,
    );

    final sampleCategory = Category(
      id: 'cat-groceries',
      name: 'Groceries',
      iconName: 'shopping_cart',
      colorHex: '#4CAF50',
      type: CategoryType.expense,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );

    final subCategory = Category(
      id: 'cat-subscriptions',
      name: 'Subscriptions',
      iconName: 'subscriptions',
      colorHex: '#2196F3',
      type: CategoryType.expense,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      fakeRemote = FakeInboxRemoteDataSource();
      fakeTxRepo = FakeTransactionRepository();
      fakeAccountRepo = FakeAccountRepository()..accounts = [sampleAccount];
      fakeCategoryRepo = FakeCategoryRepository()..categories = [sampleCategory, subCategory];
      fakeSubRepo = FakeSubscriptionRepository();

      repository = InboxRepositoryImpl(
        remoteDataSource: fakeRemote,
        transactionRepository: fakeTxRepo,
        accountRepository: fakeAccountRepo,
        categoryRepository: fakeCategoryRepo,
        subscriptionRepository: fakeSubRepo,
      );
    });

    test('syncPendingTransactions matches account by mask and category, persists to SQLite and ACKs remote', () async {
      final inboxTx = InboxTransactionModel(
        id: 'msg-123',
        bankName: 'Bancolombia',
        accountType: 'credit_card',
        accountMask: '*4892',
        merchant: 'Supermercados Exito',
        amountCents: 7000000,
        amount: 70000.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Groceries',
        transactionDate: now,
        referenceNumber: 'AUT-123',
        status: InboxStatus.pending,
        createdAt: now,
      );

      fakeRemote.pending = [inboxTx];

      final int syncedCount = await repository.syncPendingTransactions();

      expect(syncedCount, equals(1));
      expect(fakeRemote.syncedIds, contains('msg-123'));
      expect(fakeTxRepo.db.containsKey('tx_gmail_msg-123'), isTrue);

      final Transaction savedTx = fakeTxRepo.db['tx_gmail_msg-123']!;
      expect(savedTx.accountId, equals('acc-bancolombia-cc'));
      expect(savedTx.categoryId, equals('cat-groceries'));
      expect(savedTx.amountCents, equals(7000000));
      expect(savedTx.description, equals('Supermercados Exito'));
      expect(savedTx.isExpense, isTrue);
    });

    test('syncPendingTransactions is idempotent on duplicate calls', () async {
      final inboxTx = InboxTransactionModel(
        id: 'msg-456',
        bankName: 'Bancolombia',
        accountType: 'credit_card',
        accountMask: '*4892',
        merchant: 'Uber',
        amountCents: 2500000,
        amount: 25000.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Transportation',
        transactionDate: now,
        referenceNumber: 'AUT-456',
        status: InboxStatus.pending,
        createdAt: now,
      );

      fakeRemote.pending = [inboxTx];

      final int firstRun = await repository.syncPendingTransactions();
      expect(firstRun, equals(1));

      // Re-populate pending as if script re-added before ACK
      fakeRemote.pending = [inboxTx];
      final int secondRun = await repository.syncPendingTransactions();
      expect(secondRun, equals(1));
      // Only 1 transaction in DB
      expect(fakeTxRepo.db.length, equals(1));
    });

    test('syncPendingTransactions matches subscription within 15% amount and ±4 days date window', () async {
      final googleSub = Subscription(
        id: 'sub-google-one',
        name: 'Google One',
        amountCents: 1500000, // 15,000 COP
        currency: 'COP',
        frequency: RecurrenceFrequency.monthly,
        accountId: 'acc-bancolombia-cc',
        categoryId: 'cat-subscriptions',
        billingDay: 12,
        nextDueDate: DateTime.parse('2026-09-12T00:00:00.000Z'),
        createdAt: now,
        updatedAt: now,
      );
      fakeSubRepo.subscriptions = [googleSub];

      final inboxTx = InboxTransactionModel(
        id: 'msg-sub-1',
        bankName: 'Bancolombia',
        accountType: 'credit_card',
        accountMask: '*4892',
        merchant: 'Google*Google One',
        amountCents: 1550000, // +3.3% within 15% margin
        amount: 15500.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Software',
        transactionDate: DateTime.parse('2026-09-13T10:00:00.000Z'), // 1 day difference
        referenceNumber: 'AUT-SUB-1',
        status: InboxStatus.pending,
        createdAt: now,
      );

      fakeRemote.pending = [inboxTx];
      final int synced = await repository.syncPendingTransactions();

      expect(synced, equals(1));
      final savedTx = fakeTxRepo.db['tx_gmail_msg-sub-1']!;
      expect(savedTx.description, equals('Google One (Subscription Payment)'));
      expect(savedTx.categoryId, equals('cat-subscriptions'));
      expect(fakeSubRepo.updatedDueDates.containsKey('sub-google-one'), isTrue);
    });

    test('syncPendingTransactions rejects subscription if amount differs > 15%', () async {
      final googleSub = Subscription(
        id: 'sub-google-one',
        name: 'Google One',
        amountCents: 1500000, // 15,000 COP
        currency: 'COP',
        frequency: RecurrenceFrequency.monthly,
        accountId: 'acc-bancolombia-cc',
        categoryId: 'cat-subscriptions',
        billingDay: 12,
        nextDueDate: DateTime.parse('2026-09-12T00:00:00.000Z'),
        createdAt: now,
        updatedAt: now,
      );
      fakeSubRepo.subscriptions = [googleSub];

      // A $150.000 COP purchase in Google Play
      final inboxTx = InboxTransactionModel(
        id: 'msg-sub-rejected-amount',
        bankName: 'Bancolombia',
        accountType: 'credit_card',
        accountMask: '*4892',
        merchant: 'Google One Services',
        amountCents: 15000000, // 150,000 COP (10x difference)
        amount: 150000.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Groceries',
        transactionDate: DateTime.parse('2026-09-12T10:00:00.000Z'),
        referenceNumber: 'AUT-REJ-1',
        status: InboxStatus.pending,
        createdAt: now,
      );

      fakeRemote.pending = [inboxTx];
      final int synced = await repository.syncPendingTransactions();

      expect(synced, equals(1));
      final savedTx = fakeTxRepo.db['tx_gmail_msg-sub-rejected-amount']!;
      // Should NOT be marked as subscription
      expect(savedTx.description, equals('Google One Services'));
      expect(fakeSubRepo.updatedDueDates.containsKey('sub-google-one'), isFalse);
    });

    test('syncPendingTransactions rejects subscription if date is outside billing window', () async {
      final googleSub = Subscription(
        id: 'sub-google-one',
        name: 'Google One',
        amountCents: 1500000, // 15,000 COP
        currency: 'COP',
        frequency: RecurrenceFrequency.monthly,
        accountId: 'acc-bancolombia-cc',
        categoryId: 'cat-subscriptions',
        billingDay: 12,
        nextDueDate: DateTime.parse('2026-09-12T00:00:00.000Z'),
        createdAt: now,
        updatedAt: now,
      );
      fakeSubRepo.subscriptions = [googleSub];

      // Purchase made on day 27 (15 days away from due date day 12)
      final inboxTx = InboxTransactionModel(
        id: 'msg-sub-rejected-date',
        bankName: 'Bancolombia',
        accountType: 'credit_card',
        accountMask: '*4892',
        merchant: 'Google One',
        amountCents: 1500000,
        amount: 15000.0,
        currency: 'COP',
        type: 'expense',
        categorySuggestion: 'Groceries',
        transactionDate: DateTime.parse('2026-09-27T10:00:00.000Z'),
        referenceNumber: 'AUT-REJ-2',
        status: InboxStatus.pending,
        createdAt: now,
      );

      fakeRemote.pending = [inboxTx];
      final int synced = await repository.syncPendingTransactions();

      expect(synced, equals(1));
      final savedTx = fakeTxRepo.db['tx_gmail_msg-sub-rejected-date']!;
      // Should NOT be marked as subscription
      expect(savedTx.description, equals('Google One'));
      expect(fakeSubRepo.updatedDueDates.containsKey('sub-google-one'), isFalse);
    });

    test('syncPendingTransactions detects received transfer as income', () async {
      final inboxTx = InboxTransactionModel(
        id: 'msg-transfer-in',
        bankName: 'Bancolombia',
        accountType: 'savings',
        accountMask: '*3304',
        merchant: 'Transferencia de ALBA MANRIQUE',
        amountCents: 100, // 1 COP
        amount: 1.0,
        currency: 'COP',
        type: 'expense', // Raw type might say expense or other, but text has 'Transferencia de'
        categorySuggestion: 'Other Income',
        transactionDate: now,
        referenceNumber: 'AUT-999',
        status: InboxStatus.pending,
        createdAt: now,
      );

      fakeRemote.pending = [inboxTx];
      final int synced = await repository.syncPendingTransactions();

      expect(synced, equals(1));
      final savedTx = fakeTxRepo.db['tx_gmail_msg-transfer-in']!;
      expect(savedTx.isIncome, isTrue);
      expect(savedTx.type, equals(TransactionType.income));
    });
  });
}
