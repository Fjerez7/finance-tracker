import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/savings_goal_model.dart';

/// SQLite implementation of [SavingsGoalRepository] utilizing [DatabaseHelper].
class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  final DatabaseHelper _dbHelper;

  SavingsGoalRepositoryImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted}) async {
    final Database db = await _dbHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (isCompleted != null) {
      whereClauses.add('${DatabaseConstants.colIsCompleted} = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }

    final String? where =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableSavingsGoals,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${DatabaseConstants.colCreatedAt} ASC',
    );

    return maps.map((m) => SavingsGoalModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableSavingsGoals,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SavingsGoalModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async {
    final Database db = await _dbHelper.database;
    final SavingsGoalModel model = SavingsGoalModel.fromEntity(goal);
    await db.insert(
      DatabaseConstants.tableSavingsGoals,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final Database db = await _dbHelper.database;
    final SavingsGoalModel model = SavingsGoalModel.fromEntity(goal);
    await db.update(
      DatabaseConstants.tableSavingsGoals,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      DatabaseConstants.tableSavingsGoals,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> adjustCurrentAmount(
    String id,
    int newCurrentAmountCents,
  ) async {
    final Database db = await _dbHelper.database;
    final goal = await getSavingsGoalById(id);
    if (goal == null) {
      throw ArgumentError('Savings goal with id $id not found');
    }

    final bool isCompleted = newCurrentAmountCents >= goal.targetAmountCents;
    final now = DateTime.now().toUtc().toIso8601String();

    await db.update(
      DatabaseConstants.tableSavingsGoals,
      {
        DatabaseConstants.colCurrentAmountCents: newCurrentAmountCents,
        DatabaseConstants.colIsCompleted: isCompleted ? 1 : 0,
        DatabaseConstants.colUpdatedAt: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
