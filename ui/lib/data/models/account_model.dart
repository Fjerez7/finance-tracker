import '../../core/constants/database_constants.dart';
import '../../domain/entities/account.dart';

/// Data model for [Account] entity handling SQLite map and JSON serialization.
class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.balanceCents,
    super.creditLimitCents = 0,
    required super.currency,
    required super.colorHex,
    required super.iconName,
    super.isArchived = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates an [AccountModel] from a domain [Account] entity.
  factory AccountModel.fromEntity(Account entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      balanceCents: entity.balanceCents,
      creditLimitCents: entity.creditLimitCents,
      currency: entity.currency,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes SQLite row map into [AccountModel].
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map[DatabaseConstants.colId] as String,
      name: map[DatabaseConstants.colName] as String,
      type: AccountType.fromString(
        map[DatabaseConstants.colAccountType] as String,
      ),
      balanceCents: (map[DatabaseConstants.colBalanceCents] as num).toInt(),
      creditLimitCents:
          (map[DatabaseConstants.colCreditLimitCents] as num?)?.toInt() ?? 0,
      currency: map[DatabaseConstants.colCurrency] as String? ?? 'USD',
      colorHex: map[DatabaseConstants.colColorHex] as String,
      iconName: map[DatabaseConstants.colIconName] as String,
      isArchived: (map[DatabaseConstants.colIsArchived] as int? ?? 0) == 1,
      createdAt: DateTime.parse(
        map[DatabaseConstants.colCreatedAt] as String,
      ).toUtc(),
      updatedAt: DateTime.parse(
        map[DatabaseConstants.colUpdatedAt] as String,
      ).toUtc(),
    );
  }

  /// Serializes [AccountModel] to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colAccountType: type.toDbString(),
      DatabaseConstants.colBalanceCents: balanceCents,
      DatabaseConstants.colCreditLimitCents: creditLimitCents,
      DatabaseConstants.colCurrency: currency,
      DatabaseConstants.colColorHex: colorHex,
      DatabaseConstants.colIconName: iconName,
      DatabaseConstants.colIsArchived: isArchived ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toUtc().toIso8601String(),
      DatabaseConstants.colUpdatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts this data model to a pure domain [Account] entity.
  Account toEntity() {
    return Account(
      id: id,
      name: name,
      type: type,
      balanceCents: balanceCents,
      creditLimitCents: creditLimitCents,
      currency: currency,
      colorHex: colorHex,
      iconName: iconName,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
