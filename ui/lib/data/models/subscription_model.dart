import '../../core/constants/database_constants.dart';
import '../../domain/entities/subscription.dart';

/// Data model for [Subscription] entity handling SQLite map and JSON serialization.
class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.name,
    required super.amountCents,
    required super.frequency,
    required super.accountId,
    required super.categoryId,
    required super.billingDay,
    required super.nextDueDate,
    super.autoRegister = false,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [SubscriptionModel] from a domain [Subscription] entity.
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      name: entity.name,
      amountCents: entity.amountCents,
      frequency: entity.frequency,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      billingDay: entity.billingDay,
      nextDueDate: entity.nextDueDate,
      autoRegister: entity.autoRegister,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes SQLite row map into [SubscriptionModel].
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map[DatabaseConstants.colId] as String,
      name: map[DatabaseConstants.colName] as String,
      amountCents: (map[DatabaseConstants.colAmountCents] as num).toInt(),
      frequency: RecurrenceFrequency.fromString(
        map[DatabaseConstants.colFrequency] as String,
      ),
      accountId: map[DatabaseConstants.colAccountId] as String,
      categoryId: map[DatabaseConstants.colCategoryId] as String,
      billingDay: (map[DatabaseConstants.colBillingDay] as num).toInt(),
      nextDueDate: DateTime.parse(
        map[DatabaseConstants.colNextDueDate] as String,
      ).toUtc(),
      autoRegister: (map[DatabaseConstants.colAutoRegister] as int? ?? 0) == 1,
      isActive: (map[DatabaseConstants.colIsActive] as int? ?? 1) == 1,
      createdAt: DateTime.parse(
        map[DatabaseConstants.colCreatedAt] as String,
      ).toUtc(),
      updatedAt: DateTime.parse(
        map[DatabaseConstants.colUpdatedAt] as String,
      ).toUtc(),
    );
  }

  /// Serializes [SubscriptionModel] to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colAmountCents: amountCents,
      DatabaseConstants.colFrequency: frequency.toDbString(),
      DatabaseConstants.colAccountId: accountId,
      DatabaseConstants.colCategoryId: categoryId,
      DatabaseConstants.colBillingDay: billingDay,
      DatabaseConstants.colNextDueDate: nextDueDate.toUtc().toIso8601String(),
      DatabaseConstants.colAutoRegister: autoRegister ? 1 : 0,
      DatabaseConstants.colIsActive: isActive ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toUtc().toIso8601String(),
      DatabaseConstants.colUpdatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts this data model to a pure domain [Subscription] entity.
  Subscription toEntity() {
    return Subscription(
      id: id,
      name: name,
      amountCents: amountCents,
      frequency: frequency,
      accountId: accountId,
      categoryId: categoryId,
      billingDay: billingDay,
      nextDueDate: nextDueDate,
      autoRegister: autoRegister,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
