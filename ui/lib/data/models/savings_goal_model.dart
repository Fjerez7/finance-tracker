import '../../core/constants/database_constants.dart';
import '../../domain/entities/savings_goal.dart';

/// Data model for [SavingsGoal] entity handling SQLite map and JSON serialization.
class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    required super.id,
    required super.name,
    required super.targetAmountCents,
    super.currentAmountCents = 0,
    super.targetDate,
    required super.colorHex,
    required super.iconName,
    super.isCompleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [SavingsGoalModel] from a domain [SavingsGoal] entity.
  factory SavingsGoalModel.fromEntity(SavingsGoal entity) {
    return SavingsGoalModel(
      id: entity.id,
      name: entity.name,
      targetAmountCents: entity.targetAmountCents,
      currentAmountCents: entity.currentAmountCents,
      targetDate: entity.targetDate,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes SQLite row map into [SavingsGoalModel].
  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map[DatabaseConstants.colId] as String,
      name: map[DatabaseConstants.colName] as String,
      targetAmountCents: (map[DatabaseConstants.colTargetAmountCents] as num)
          .toInt(),
      currentAmountCents:
          (map[DatabaseConstants.colCurrentAmountCents] as num?)?.toInt() ?? 0,
      targetDate: map[DatabaseConstants.colTargetDate] != null
          ? DateTime.parse(
              map[DatabaseConstants.colTargetDate] as String,
            ).toUtc()
          : null,
      colorHex: map[DatabaseConstants.colColorHex] as String,
      iconName: map[DatabaseConstants.colIconName] as String,
      isCompleted: (map[DatabaseConstants.colIsCompleted] as int? ?? 0) == 1,
      createdAt: DateTime.parse(
        map[DatabaseConstants.colCreatedAt] as String,
      ).toUtc(),
      updatedAt: DateTime.parse(
        map[DatabaseConstants.colUpdatedAt] as String,
      ).toUtc(),
    );
  }

  /// Serializes [SavingsGoalModel] to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colTargetAmountCents: targetAmountCents,
      DatabaseConstants.colCurrentAmountCents: currentAmountCents,
      DatabaseConstants.colTargetDate: targetDate?.toUtc().toIso8601String(),
      DatabaseConstants.colColorHex: colorHex,
      DatabaseConstants.colIconName: iconName,
      DatabaseConstants.colIsCompleted: isCompleted ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toUtc().toIso8601String(),
      DatabaseConstants.colUpdatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts this data model to a pure domain [SavingsGoal] entity.
  SavingsGoal toEntity() {
    return SavingsGoal(
      id: id,
      name: name,
      targetAmountCents: targetAmountCents,
      currentAmountCents: currentAmountCents,
      targetDate: targetDate,
      colorHex: colorHex,
      iconName: iconName,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
