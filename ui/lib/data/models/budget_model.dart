import '../../core/constants/database_constants.dart';
import '../../domain/entities/budget.dart';

/// Data model for [Budget] entity handling SQLite map and JSON serialization.
class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.month,
    required super.year,
    required super.limitCents,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [BudgetModel] from a domain [Budget] entity.
  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      month: entity.month,
      year: entity.year,
      limitCents: entity.limitCents,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes SQLite row map into [BudgetModel].
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map[DatabaseConstants.colId] as String,
      categoryId: map[DatabaseConstants.colCategoryId] as String,
      month: (map[DatabaseConstants.colMonth] as num).toInt(),
      year: (map[DatabaseConstants.colYear] as num).toInt(),
      limitCents: (map[DatabaseConstants.colLimitCents] as num).toInt(),
      createdAt: DateTime.parse(
        map[DatabaseConstants.colCreatedAt] as String,
      ).toUtc(),
      updatedAt: DateTime.parse(
        map[DatabaseConstants.colUpdatedAt] as String,
      ).toUtc(),
    );
  }

  /// Serializes [BudgetModel] to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colCategoryId: categoryId,
      DatabaseConstants.colMonth: month,
      DatabaseConstants.colYear: year,
      DatabaseConstants.colLimitCents: limitCents,
      DatabaseConstants.colCreatedAt: createdAt.toUtc().toIso8601String(),
      DatabaseConstants.colUpdatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts this data model to a pure domain [Budget] entity.
  Budget toEntity() {
    return Budget(
      id: id,
      categoryId: categoryId,
      month: month,
      year: year,
      limitCents: limitCents,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
