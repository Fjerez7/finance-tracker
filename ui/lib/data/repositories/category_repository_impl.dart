import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/category_model.dart';

/// Concrete SQLite implementation of [CategoryRepository].
class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Category>> getCategories({CategoryType? type}) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableCategories,
      where: type != null ? '${DatabaseConstants.colCategoryType} = ?' : null,
      whereArgs: type != null ? [type.toDbString()] : null,
      orderBy:
          '${DatabaseConstants.colIsDefault} DESC, ${DatabaseConstants.colName} ASC',
    );

    return rows.map((row) => CategoryModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return CategoryModel.fromMap(rows.first).toEntity();
  }

  @override
  Future<void> createCategory(Category category) async {
    final Database db = await _databaseHelper.database;
    final CategoryModel model = CategoryModel.fromEntity(category);
    await db.insert(
      DatabaseConstants.tableCategories,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateCategory(Category category) async {
    final Database db = await _databaseHelper.database;
    final CategoryModel model = CategoryModel.fromEntity(
      category.copyWith(updatedAt: DateTime.now().toUtc()),
    );
    await db.update(
      DatabaseConstants.tableCategories,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final Database db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
