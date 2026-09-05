/// Periodicities supported for fixed commitments.
enum RecurrenceFrequency {
  weekly,
  biweekly,
  monthly,
  annual;

  static RecurrenceFrequency fromString(String value) {
    switch (value) {
      case 'weekly':
        return RecurrenceFrequency.weekly;
      case 'biweekly':
        return RecurrenceFrequency.biweekly;
      case 'monthly':
        return RecurrenceFrequency.monthly;
      case 'annual':
        return RecurrenceFrequency.annual;
      default:
        throw ArgumentError('Unknown RecurrenceFrequency: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case RecurrenceFrequency.weekly:
        return 'weekly';
      case RecurrenceFrequency.biweekly:
        return 'biweekly';
      case RecurrenceFrequency.monthly:
        return 'monthly';
      case RecurrenceFrequency.annual:
        return 'annual';
    }
  }
}

/// Domain entity representing a recurring payment, subscription, or fixed bill.
class Subscription {
  final String id;
  final String name;
  final int amountCents;
  final RecurrenceFrequency frequency;
  final String accountId;
  final String categoryId;
  final int billingDay;
  final DateTime nextDueDate;
  final bool autoRegister;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.frequency,
    required this.accountId,
    required this.categoryId,
    required this.billingDay,
    required this.nextDueDate,
    this.autoRegister = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         amountCents > 0,
         'Subscription amount must be strictly positive (> 0)',
       ),
       assert(
         billingDay >= 1 && billingDay <= 31,
         'Billing day must be between 1 and 31',
       );

  /// Normalized monthly expense in integer cents.
  int get monthlyEquivalentCents {
    switch (frequency) {
      case RecurrenceFrequency.weekly:
        return (amountCents * 52) ~/ 12;
      case RecurrenceFrequency.biweekly:
        return (amountCents * 26) ~/ 12;
      case RecurrenceFrequency.monthly:
        return amountCents;
      case RecurrenceFrequency.annual:
        return amountCents ~/ 12;
    }
  }

  /// Annual projected burn rate in integer cents.
  int get annualProjectionCents => monthlyEquivalentCents * 12;

  Subscription copyWith({
    String? id,
    String? name,
    int? amountCents,
    RecurrenceFrequency? frequency,
    String? accountId,
    String? categoryId,
    int? billingDay,
    DateTime? nextDueDate,
    bool? autoRegister,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      frequency: frequency ?? this.frequency,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      billingDay: billingDay ?? this.billingDay,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      autoRegister: autoRegister ?? this.autoRegister,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          amountCents == other.amountCents &&
          frequency == other.frequency &&
          accountId == other.accountId &&
          categoryId == other.categoryId &&
          billingDay == other.billingDay &&
          nextDueDate == other.nextDueDate &&
          autoRegister == other.autoRegister &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      amountCents.hashCode ^
      frequency.hashCode ^
      accountId.hashCode ^
      categoryId.hashCode ^
      billingDay.hashCode ^
      nextDueDate.hashCode ^
      autoRegister.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, amountCents: $amountCents, frequency: $frequency, billingDay: $billingDay, nextDueDate: $nextDueDate, isActive: $isActive)';
  }
}
