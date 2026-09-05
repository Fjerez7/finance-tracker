import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/category_model.dart';
import 'package:finance_tracker/domain/entities/category.dart';

void main() {
  group('CategoryModel Serialization & Entity Mapping', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    final Category domainCategory = Category(
      id: 'cat-1',
      name: 'Coffee & Snacks',
      iconName: 'coffee',
      colorHex: '#795548',
      type: CategoryType.expense,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );

    test('converts fromEntity and toEntity accurately', () {
      final CategoryModel model = CategoryModel.fromEntity(domainCategory);

      expect(model.id, equals(domainCategory.id));
      expect(model.name, equals(domainCategory.name));
      expect(model.type, equals(domainCategory.type));
      expect(model.isDefault, isTrue);

      final Category converted = model.toEntity();
      expect(converted, equals(domainCategory));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final CategoryModel model = CategoryModel.fromEntity(domainCategory);
      final Map<String, dynamic> map = model.toMap();

      expect(map['id'], equals('cat-1'));
      expect(map['name'], equals('Coffee & Snacks'));
      expect(map['type'], equals('expense'));
      expect(map['is_default'], equals(1));

      final CategoryModel fromMapModel = CategoryModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.name, equals(model.name));
      expect(fromMapModel.isDefault, isTrue);
    });
  });
}
