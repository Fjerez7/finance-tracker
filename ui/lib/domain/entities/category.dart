/// Classification of transaction category (expense or income).
enum CategoryType {
  expense,
  income;

  static CategoryType fromString(String value) {
    switch (value) {
      case 'expense':
        return CategoryType.expense;
      case 'income':
        return CategoryType.income;
      default:
        throw ArgumentError('Unknown CategoryType: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case CategoryType.expense:
        return 'expense';
      case CategoryType.income:
        return 'income';
    }
  }
}

/// Domain entity representing a transaction category.
class Category {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final CategoryType type;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpense => type == CategoryType.expense;
  bool get isIncome => type == CategoryType.income;

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    CategoryType? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          iconName == other.iconName &&
          colorHex == other.colorHex &&
          type == other.type &&
          isDefault == other.isDefault &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      iconName.hashCode ^
      colorHex.hashCode ^
      type.hashCode ^
      isDefault.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, iconName: $iconName, isDefault: $isDefault)';
  }
}
