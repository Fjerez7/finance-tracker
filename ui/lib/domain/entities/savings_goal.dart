/// Domain entity representing a targeted savings objective.
class SavingsGoal {
  final String id;
  final String name;
  final int targetAmountCents;
  final int currentAmountCents;
  final DateTime? targetDate;
  final String colorHex;
  final String iconName;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmountCents,
    this.currentAmountCents = 0,
    this.targetDate,
    required this.colorHex,
    required this.iconName,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         targetAmountCents > 0,
         'Target savings amount must be strictly positive (> 0)',
       ),
       assert(
         currentAmountCents >= 0,
         'Current savings amount cannot be negative',
       );

  /// Progress ratio clamped between 0.0 and 1.0 (or >1.0 if overfunded).
  double get progressRatio =>
      targetAmountCents > 0 ? (currentAmountCents / targetAmountCents) : 0.0;

  /// Progress percentage clamped between 0.0 and 1.0.
  double get clampedProgress => progressRatio.clamp(0.0, 1.0);

  /// Remaining amount needed in integer cents.
  int get remainingAmountCents =>
      (targetAmountCents - currentAmountCents).clamp(0, targetAmountCents);

  /// Calculates recommended monthly savings needed to reach target by [targetDate].
  /// Returns null if [targetDate] is not set or has already passed.
  int? calculateRequiredMonthlySavings(DateTime referenceDate) {
    if (targetDate == null) return null;
    if (currentAmountCents >= targetAmountCents) return 0;

    final int monthsRemaining =
        ((targetDate!.year - referenceDate.year) * 12) +
        (targetDate!.month - referenceDate.month);

    if (monthsRemaining <= 0) {
      return remainingAmountCents;
    }

    return (remainingAmountCents / monthsRemaining).ceil();
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    int? targetAmountCents,
    int? currentAmountCents,
    DateTime? targetDate,
    String? colorHex,
    String? iconName,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmountCents: targetAmountCents ?? this.targetAmountCents,
      currentAmountCents: currentAmountCents ?? this.currentAmountCents,
      targetDate: targetDate ?? this.targetDate,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          targetAmountCents == other.targetAmountCents &&
          currentAmountCents == other.currentAmountCents &&
          targetDate == other.targetDate &&
          colorHex == other.colorHex &&
          iconName == other.iconName &&
          isCompleted == other.isCompleted &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      targetAmountCents.hashCode ^
      currentAmountCents.hashCode ^
      targetDate.hashCode ^
      colorHex.hashCode ^
      iconName.hashCode ^
      isCompleted.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'SavingsGoal(id: $id, name: $name, targetAmountCents: $targetAmountCents, currentAmountCents: $currentAmountCents, isCompleted: $isCompleted)';
  }
}
