import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/subscription_model.dart';

/// Concrete SQLite implementation of [SubscriptionRepository].
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final DatabaseHelper _databaseHelper;

  SubscriptionRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Subscription>> getSubscriptions({
    bool? isActive,
    String? accountId,
    String? categoryId,
  }) async {
    final Database db = await _databaseHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (isActive != null) {
      whereClauses.add('${DatabaseConstants.colIsActive} = ?');
      whereArgs.add(isActive ? 1 : 0);
    }

    if (accountId != null) {
      whereClauses.add('${DatabaseConstants.colAccountId} = ?');
      whereArgs.add(accountId);
    }

    if (categoryId != null) {
      whereClauses.add('${DatabaseConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }

    final String? whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableSubscriptions,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy:
          '${DatabaseConstants.colIsActive} DESC, ${DatabaseConstants.colNextDueDate} ASC',
    );

    return rows.map((row) => SubscriptionModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableSubscriptions,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return SubscriptionModel.fromMap(rows.first).toEntity();
  }

  @override
  Future<void> createSubscription(Subscription subscription) async {
    final Database db = await _databaseHelper.database;
    final SubscriptionModel model = SubscriptionModel.fromEntity(subscription);
    await db.insert(
      DatabaseConstants.tableSubscriptions,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final Database db = await _databaseHelper.database;
    final SubscriptionModel model = SubscriptionModel.fromEntity(
      subscription.copyWith(updatedAt: DateTime.now().toUtc()),
    );
    await db.update(
      DatabaseConstants.tableSubscriptions,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [subscription.id],
    );
  }

  @override
  Future<void> deleteSubscription(String id) async {
    final Database db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.tableSubscriptions,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateNextDueDate(String id, DateTime nextDueDate) async {
    final Database db = await _databaseHelper.database;
    final String now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseConstants.tableSubscriptions,
      {
        DatabaseConstants.colNextDueDate: nextDueDate.toUtc().toIso8601String(),
        DatabaseConstants.colUpdatedAt: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleActive(String id, bool isActive) async {
    final Database db = await _databaseHelper.database;
    final String now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseConstants.tableSubscriptions,
      {
        DatabaseConstants.colIsActive: isActive ? 1 : 0,
        DatabaseConstants.colUpdatedAt: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
