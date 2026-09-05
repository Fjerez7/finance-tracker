import '../entities/subscription.dart';

/// Contract interface for managing recurring commitments and subscriptions.
abstract class SubscriptionRepository {
  /// Fetches subscriptions matching the specified optional filter criteria.
  Future<List<Subscription>> getSubscriptions({
    bool? isActive,
    String? accountId,
    String? categoryId,
  });

  /// Fetches a single subscription by unique [id].
  Future<Subscription?> getSubscriptionById(String id);

  /// Creates a new recurring subscription.
  Future<void> createSubscription(Subscription subscription);

  /// Updates an existing subscription.
  Future<void> updateSubscription(Subscription subscription);

  /// Deletes a subscription by unique [id].
  Future<void> deleteSubscription(String id);

  /// Updates only the next due date of a subscription (e.g. after a payment is registered).
  Future<void> updateNextDueDate(String id, DateTime nextDueDate);

  /// Toggles the active status of a subscription.
  Future<void> toggleActive(String id, bool isActive);
}
