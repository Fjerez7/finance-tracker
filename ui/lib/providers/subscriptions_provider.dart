import 'package:flutter/foundation.dart' hide Category;
import '../domain/entities/subscription.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/subscription_repository.dart';
import 'accounts_provider.dart';
import 'transactions_provider.dart';

/// Reactive provider managing subscriptions, recurrence scheduling, and 1-tap ledger posting.
class SubscriptionsProvider extends ChangeNotifier {
  final SubscriptionRepository _repository;

  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  SubscriptionsProvider({required SubscriptionRepository repository})
    : _repository = repository;

  // Getters
  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Subscription> get activeSubscriptions =>
      _subscriptions.where((s) => s.isActive).toList();

  List<Subscription> get inactiveSubscriptions =>
      _subscriptions.where((s) => !s.isActive).toList();

  /// Normalized total monthly cost in minor units (integer cents) across active commitments.
  int get totalMonthlyCommitmentCents =>
      activeSubscriptions.fold(0, (sum, s) => sum + s.monthlyEquivalentCents);

  /// Annual projected burn rate in minor units (integer cents).
  int get totalAnnualProjectionCents => totalMonthlyCommitmentCents * 12;

  /// Active subscriptions sorted chronologically by next upcoming due date.
  List<Subscription> get upcomingDueSubscriptions {
    final list = List<Subscription>.from(activeSubscriptions);
    list.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return list;
  }

  /// Active subscriptions that are overdue (nextDueDate is strictly before today's start).
  List<Subscription> get overdueSubscriptions {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return activeSubscriptions
        .where((s) => s.nextDueDate.isBefore(todayStart))
        .toList();
  }

  /// Active subscriptions due within the next 3 days (inclusive of today).
  List<Subscription> get dueSoonSubscriptions {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final inThreeDays = todayStart.add(const Duration(days: 4));
    return activeSubscriptions
        .where(
          (s) =>
              !s.nextDueDate.isBefore(todayStart) &&
              s.nextDueDate.isBefore(inThreeDays),
        )
        .toList();
  }

  /// Calculates the next chronological payment date given current date, frequency, and optional billing day.
  static DateTime calculateNextDueDate(
    DateTime currentDate,
    RecurrenceFrequency frequency, {
    int? billingDay,
  }) {
    switch (frequency) {
      case RecurrenceFrequency.weekly:
        return currentDate.add(const Duration(days: 7));

      case RecurrenceFrequency.biweekly:
        return currentDate.add(const Duration(days: 14));

      case RecurrenceFrequency.monthly:
        int year = currentDate.year;
        int month = currentDate.month + 1;
        if (month > 12) {
          year += 1;
          month = 1;
        }
        final int targetDay = billingDay ?? currentDate.day;
        final int daysInNextMonth = DateTime(year, month + 1, 0).day;
        final int finalDay = targetDay.clamp(1, daysInNextMonth);
        return DateTime(
          year,
          month,
          finalDay,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );

      case RecurrenceFrequency.annual:
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
    }
  }

  /// Loads all subscriptions from repository.
  Future<void> loadSubscriptions() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _subscriptions = await _repository.getSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to load subscriptions: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new subscription.
  Future<void> addSubscription(Subscription subscription) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.createSubscription(subscription);
      await loadSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to add subscription: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing subscription.
  Future<void> updateSubscription(Subscription subscription) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.updateSubscription(subscription);
      await loadSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to update subscription: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a subscription.
  Future<void> deleteSubscription(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.deleteSubscription(id);
      await loadSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to delete subscription: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles active/paused status of a subscription.
  Future<void> toggleActive(String id, bool isActive) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.toggleActive(id, isActive);
      await loadSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to toggle subscription active state: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 1-Tap post payment: creates a real expense transaction and advances next due date.
  Future<void> postSubscriptionPayment(
    Subscription subscription, {
    required TransactionsProvider transactionsProvider,
    AccountsProvider? accountsProvider,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final now = DateTime.now();
      final tx = Transaction(
        id: 'tx_sub_${subscription.id}_${now.millisecondsSinceEpoch}',
        accountId: subscription.accountId,
        categoryId: subscription.categoryId,
        amountCents: subscription.amountCents,
        type: TransactionType.expense,
        description: '${subscription.name} (Recurring Payment)',
        transactionDate: now,
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
      );

      // Create transaction and update account balance
      await transactionsProvider.addTransaction(
        tx,
        accountsProvider: accountsProvider,
      );

      // Advance next due date
      final DateTime nextDue = calculateNextDueDate(
        subscription.nextDueDate,
        subscription.frequency,
        billingDay: subscription.billingDay,
      );
      await _repository.updateNextDueDate(subscription.id, nextDue);

      await loadSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to post subscription payment: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Checks for due subscriptions configured with `autoRegister` and automatically posts payments.
  Future<int> checkAndProcessAutoRegister({
    required TransactionsProvider transactionsProvider,
    AccountsProvider? accountsProvider,
  }) async {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final dueAutoSubscriptions =
        activeSubscriptions
            .where((s) => s.autoRegister && s.nextDueDate.isBefore(todayEnd))
            .toList();

    int processedCount = 0;
    for (final sub in dueAutoSubscriptions) {
      try {
        await postSubscriptionPayment(
          sub,
          transactionsProvider: transactionsProvider,
          accountsProvider: accountsProvider,
        );
        processedCount++;
      } catch (e) {
        debugPrint('Auto-register failed for ${sub.name}: $e');
      }
    }

    return processedCount;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
