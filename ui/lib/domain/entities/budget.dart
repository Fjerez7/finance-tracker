/// Domain entity representing a monthly spending limit for a specific category.
class Budget {
  final String id;
  final String categoryId;
  final int month;
  final int year;
  final int limitCents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.limitCents,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(month >= 1 && month <= 12, 'Month must be between 1 and 12'),
       assert(year >= 2000, 'Year must be a valid Gregorian year >= 2000'),
       assert(limitCents > 0, 'Budget limit must be strictly positive (> 0)');

  /// Calculates the progress ratio against spent amount (e.g. 0.75 for 75%).
  double progressRatio(int spentCents) {
    if (limitCents <= 0) return 0.0;
    return (spentCents / limitCents).clamp(0.0, double.infinity);
  }

  /// Calculates remaining budget in integer cents (can be negative if over budget).
  int remainingCents(int spentCents) {
    return limitCents - spentCents;
  }

  /// Returns true if spent amount exceeds budget limit.
  bool isOverBudget(int spentCents) {
    return spentCents > limitCents;
  }

  /// Returns true if spent amount has reached or exceeded the warning threshold (default 80%) without exceeding 100%.
  bool isApproachingLimit(int spentCents, {double threshold = 0.8}) {
    final double ratio = progressRatio(spentCents);
    return ratio >= threshold && ratio <= 1.0;
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    int? month,
    int? year,
    int? limitCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      year: year ?? this.year,
      limitCents: limitCents ?? this.limitCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryId == other.categoryId &&
          month == other.month &&
          year == other.year &&
          limitCents == other.limitCents &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryId.hashCode ^
      month.hashCode ^
      year.hashCode ^
      limitCents.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, period: $year-$month, limitCents: $limitCents)';
  }
}
