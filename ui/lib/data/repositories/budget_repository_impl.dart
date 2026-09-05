import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/budget_model.dart';

/// SQLite implementation of [BudgetRepository] utilizing [DatabaseHelper].
class BudgetRepositoryImpl implements BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepositoryImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Budget>> getBudgets({
    int? month,
    int? year,
    String? categoryId,
  }) async {
    final Database db = await _dbHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (month != null) {
      whereClauses.add('${DatabaseConstants.colMonth} = ?');
      whereArgs.add(month);
    }

    if (year != null) {
      whereClauses.add('${DatabaseConstants.colYear} = ?');
      whereArgs.add(year);
    }

    if (categoryId != null) {
      whereClauses.add('${DatabaseConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }

    final String? where =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableBudgets,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${DatabaseConstants.colCreatedAt} ASC',
    );

    return maps.map((m) => BudgetModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableBudgets,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<Budget?> getBudgetForCategory(
    String categoryId,
    int month,
    int year,
  ) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableBudgets,
      where:
          '${DatabaseConstants.colCategoryId} = ? AND ${DatabaseConstants.colMonth} = ? AND ${DatabaseConstants.colYear} = ?',
      whereArgs: [categoryId, month, year],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<void> createBudget(Budget budget) async {
    final Database db = await _dbHelper.database;
    final BudgetModel model = BudgetModel.fromEntity(budget);
    await db.insert(
      DatabaseConstants.tableBudgets,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final Database db = await _dbHelper.database;
    final BudgetModel model = BudgetModel.fromEntity(budget);
    await db.update(
      DatabaseConstants.tableBudgets,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [budget.id],
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      DatabaseConstants.tableBudgets,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
