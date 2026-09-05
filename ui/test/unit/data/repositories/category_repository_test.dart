import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/category_repository_impl.dart';
import 'package:finance_tracker/domain/entities/category.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late CategoryRepositoryImpl repository;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database; // Initializes schema + default seeds

    repository = CategoryRepositoryImpl(databaseHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('CategoryRepositoryImpl SQLite Operations', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    test('initial database seeding provides default categories', () async {
      final List<Category> allCategories = await repository.getCategories();
      // DatabaseHelper seeds 15 default categories
      expect(allCategories.length, equals(15));

      final List<Category> expenseCategories = await repository.getCategories(
        type: CategoryType.expense,
      );
      final List<Category> incomeCategories = await repository.getCategories(
        type: CategoryType.income,
      );

      expect(expenseCategories.isNotEmpty, isTrue);
      expect(incomeCategories.isNotEmpty, isTrue);
      expect(
        expenseCategories.length + incomeCategories.length,
        equals(allCategories.length),
      );
    });

    test('creates and retrieves custom category', () async {
      final customCategory = Category(
        id: 'cat-custom-1',
        name: 'Books & Learning',
        iconName: 'menu_book',
        colorHex: '#3F51B5',
        type: CategoryType.expense,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createCategory(customCategory);

      final Category? retrieved = await repository.getCategoryById(
        'cat-custom-1',
      );
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Books & Learning'));
      expect(retrieved.type, equals(CategoryType.expense));
      expect(retrieved.isDefault, isFalse);
    });

    test('updates custom category correctly', () async {
      final customCategory = Category(
        id: 'cat-custom-2',
        name: 'Gaming',
        iconName: 'sports_esports',
        colorHex: '#9C27B0',
        type: CategoryType.expense,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createCategory(customCategory);

      final updated = customCategory.copyWith(
        name: 'Video Games & VR',
        colorHex: '#673AB7',
      );
      await repository.updateCategory(updated);

      final Category? retrieved = await repository.getCategoryById(
        'cat-custom-2',
      );
      expect(retrieved!.name, equals('Video Games & VR'));
      expect(retrieved.colorHex, equals('#673AB7'));
    });

    test('deletes custom category', () async {
      final customCategory = Category(
        id: 'cat-custom-3',
        name: 'To Delete',
        iconName: 'delete',
        colorHex: '#F44336',
        type: CategoryType.expense,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createCategory(customCategory);
      await repository.deleteCategory('cat-custom-3');

      final Category? retrieved = await repository.getCategoryById(
        'cat-custom-3',
      );
      expect(retrieved, isNull);
    });
  });
}
