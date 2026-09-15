import '../../core/constants/database_constants.dart';
import '../../domain/entities/monitored_bank_app.dart';

/// Data model for [MonitoredBankApp] handling SQLite serialization and deserialization.
class MonitoredBankAppModel extends MonitoredBankApp {
  const MonitoredBankAppModel({
    required super.id,
    required super.packageName,
    required super.displayName,
    super.isEnabled,
    required super.createdAt,
  });

  /// Factory converting SQLite map row to model instance.
  factory MonitoredBankAppModel.fromMap(Map<String, dynamic> map) {
    return MonitoredBankAppModel(
      id: map[DatabaseConstants.colId] as String,
      packageName: map[DatabaseConstants.colPackageName] as String,
      displayName: map[DatabaseConstants.colDisplayName] as String,
      isEnabled: (map[DatabaseConstants.colIsEnabled] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map[DatabaseConstants.colCreatedAt] as String),
    );
  }

  /// Factory converting domain entity to model.
  factory MonitoredBankAppModel.fromEntity(MonitoredBankApp entity) {
    return MonitoredBankAppModel(
      id: entity.id,
      packageName: entity.packageName,
      displayName: entity.displayName,
      isEnabled: entity.isEnabled,
      createdAt: entity.createdAt,
    );
  }

  /// Converts model to SQLite-compatible map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colPackageName: packageName,
      DatabaseConstants.colDisplayName: displayName,
      DatabaseConstants.colIsEnabled: isEnabled ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toIso8601String(),
    };
  }

  /// Converts model back to domain entity.
  MonitoredBankApp toEntity() {
    return MonitoredBankApp(
      id: id,
      packageName: packageName,
      displayName: displayName,
      isEnabled: isEnabled,
      createdAt: createdAt,
    );
  }
}
