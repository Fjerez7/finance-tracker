import '../../core/constants/database_constants.dart';
import '../../domain/entities/category.dart';

/// Data model for [Category] entity handling SQLite map and JSON serialization.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconName,
    required super.colorHex,
    required super.type,
    super.isDefault = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [CategoryModel] from a domain [Category] entity.
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconName: entity.iconName,
      colorHex: entity.colorHex,
      type: entity.type,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes SQLite row map into [CategoryModel].
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseConstants.colId] as String,
      name: map[DatabaseConstants.colName] as String,
      iconName: map[DatabaseConstants.colIconName] as String,
      colorHex: map[DatabaseConstants.colColorHex] as String,
      type: CategoryType.fromString(
        map[DatabaseConstants.colCategoryType] as String,
      ),
      isDefault: (map[DatabaseConstants.colIsDefault] as int? ?? 0) == 1,
      createdAt: DateTime.parse(
        map[DatabaseConstants.colCreatedAt] as String,
      ).toUtc(),
      updatedAt: DateTime.parse(
        map[DatabaseConstants.colUpdatedAt] as String,
      ).toUtc(),
    );
  }

  /// Serializes [CategoryModel] to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colIconName: iconName,
      DatabaseConstants.colColorHex: colorHex,
      DatabaseConstants.colCategoryType: type.toDbString(),
      DatabaseConstants.colIsDefault: isDefault ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toUtc().toIso8601String(),
      DatabaseConstants.colUpdatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts this data model to a pure domain [Category] entity.
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      type: type,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
