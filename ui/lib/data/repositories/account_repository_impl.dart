import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/account_model.dart';

/// Concrete SQLite implementation of [AccountRepository].
class AccountRepositoryImpl implements AccountRepository {
  final DatabaseHelper _databaseHelper;

  AccountRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableAccounts,
      where: includeArchived ? null : '${DatabaseConstants.colIsArchived} = 0',
      orderBy: '${DatabaseConstants.colName} ASC',
    );

    return rows.map((row) => AccountModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableAccounts,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return AccountModel.fromMap(rows.first).toEntity();
  }

  @override
  Future<void> createAccount(Account account) async {
    final Database db = await _databaseHelper.database;
    final AccountModel model = AccountModel.fromEntity(account);
    await db.insert(
      DatabaseConstants.tableAccounts,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateAccount(Account account) async {
    final Database db = await _databaseHelper.database;
    final AccountModel model = AccountModel.fromEntity(
      account.copyWith(updatedAt: DateTime.now().toUtc()),
    );
    await db.update(
      DatabaseConstants.tableAccounts,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [account.id],
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final Database db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.tableAccounts,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {
    final Database db = await _databaseHelper.database;
    final String now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseConstants.tableAccounts,
      {
        DatabaseConstants.colBalanceCents: newBalanceCents,
        DatabaseConstants.colUpdatedAt: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> setArchived(String id, bool isArchived) async {
    final Database db = await _databaseHelper.database;
    final String now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      DatabaseConstants.tableAccounts,
      {
        DatabaseConstants.colIsArchived: isArchived ? 1 : 0,
        DatabaseConstants.colUpdatedAt: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
