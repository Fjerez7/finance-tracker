import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../core/constants/database_constants.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/transaction_model.dart';

/// Concrete SQLite implementation of [TransactionRepository] with atomic account balance synchronization.
class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Transaction>> getTransactions({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    int? limit,
    int? offset,
  }) async {
    final Database db = await _databaseHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (accountId != null) {
      whereClauses.add(
        '(${DatabaseConstants.colAccountId} = ? OR ${DatabaseConstants.colToAccountId} = ?)',
      );
      whereArgs.addAll([accountId, accountId]);
    }

    if (categoryId != null) {
      whereClauses.add('${DatabaseConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }

    if (type != null) {
      whereClauses.add('${DatabaseConstants.colTransactionType} = ?');
      whereArgs.add(type.toDbString());
    }

    if (startDate != null) {
      whereClauses.add('${DatabaseConstants.colTransactionDate} >= ?');
      whereArgs.add(startDate.toUtc().toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('${DatabaseConstants.colTransactionDate} <= ?');
      whereArgs.add(endDate.toUtc().toIso8601String());
    }

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('${DatabaseConstants.colDescription} LIKE ?');
      whereArgs.add('%${query.trim()}%');
    }

    final String? whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableTransactions,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy:
          '${DatabaseConstants.colTransactionDate} DESC, ${DatabaseConstants.colCreatedAt} DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map((row) => TransactionModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async {
    return getTransactions(limit: limit);
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return TransactionModel.fromMap(rows.first).toEntity();
  }

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final Database db = await _databaseHelper.database;
    await db.transaction((txn) async {
      final TransactionModel model = TransactionModel.fromEntity(transaction);
      await txn.insert(
        DatabaseConstants.tableTransactions,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await _applyBalanceDelta(txn, transaction, isReversal: false);
    });
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final Database db = await _databaseHelper.database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> existingRows = await txn.query(
        DatabaseConstants.tableTransactions,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [transaction.id],
        limit: 1,
      );

      if (existingRows.isEmpty) {
        throw StateError(
          'Cannot update transaction: ID ${transaction.id} not found',
        );
      }

      final Transaction oldTx = TransactionModel.fromMap(
        existingRows.first,
      ).toEntity();

      // Reverse previous transaction effects
      await _applyBalanceDelta(txn, oldTx, isReversal: true);

      // Apply updated transaction effects
      await _applyBalanceDelta(txn, transaction, isReversal: false);

      final TransactionModel model = TransactionModel.fromEntity(
        transaction.copyWith(updatedAt: DateTime.now().toUtc()),
      );
      await txn.update(
        DatabaseConstants.tableTransactions,
        model.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [transaction.id],
      );
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final Database db = await _databaseHelper.database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> existingRows = await txn.query(
        DatabaseConstants.tableTransactions,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (existingRows.isEmpty) return;

      final Transaction tx = TransactionModel.fromMap(
        existingRows.first,
      ).toEntity();

      // Reverse transaction balance effects
      await _applyBalanceDelta(txn, tx, isReversal: true);

      await txn.delete(
        DatabaseConstants.tableTransactions,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Database db = await _databaseHelper.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (accountId != null) {
      whereClauses.add(
        '(${DatabaseConstants.colAccountId} = ? OR ${DatabaseConstants.colToAccountId} = ?)',
      );
      whereArgs.addAll([accountId, accountId]);
    }

    if (categoryId != null) {
      whereClauses.add('${DatabaseConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }

    if (type != null) {
      whereClauses.add('${DatabaseConstants.colTransactionType} = ?');
      whereArgs.add(type.toDbString());
    }

    if (startDate != null) {
      whereClauses.add('${DatabaseConstants.colTransactionDate} >= ?');
      whereArgs.add(startDate.toUtc().toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('${DatabaseConstants.colTransactionDate} <= ?');
      whereArgs.add(endDate.toUtc().toIso8601String());
    }

    final String? whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableTransactions}${whereString != null ? ' WHERE $whereString' : ''}',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Helper to calculate and apply balance modifications to accounts within a SQLite transaction.
  Future<void> _applyBalanceDelta(
    DatabaseExecutor txn,
    Transaction transaction, {
    required bool isReversal,
  }) async {
    final int multiplier = isReversal ? -1 : 1;

    // Fetch source account
    final List<Map<String, dynamic>> srcRows = await txn.query(
      DatabaseConstants.tableAccounts,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [transaction.accountId],
      limit: 1,
    );

    if (srcRows.isEmpty) {
      throw StateError(
        'Source account ${transaction.accountId} does not exist',
      );
    }

    final int srcCurrentBalance =
        (srcRows.first[DatabaseConstants.colBalanceCents] as num).toInt();
    final AccountType srcType = AccountType.fromString(
      srcRows.first[DatabaseConstants.colAccountType] as String,
    );
    final bool srcIsCreditCard = srcType == AccountType.creditCard;

    int srcDeltaCents = 0;

    switch (transaction.type) {
      case TransactionType.expense:
        // Expense on asset decreases balance; on credit card increases debt
        srcDeltaCents = srcIsCreditCard
            ? transaction.amountCents
            : -transaction.amountCents;
        break;

      case TransactionType.income:
        // Income on asset increases balance; on credit card decreases debt
        srcDeltaCents = srcIsCreditCard
            ? -transaction.amountCents
            : transaction.amountCents;
        break;

      case TransactionType.transfer:
        // Transfer out of source account: asset decreases, credit card debt increases
        srcDeltaCents = srcIsCreditCard
            ? transaction.amountCents
            : -transaction.amountCents;

        // Apply transfer to destination account
        if (transaction.toAccountId != null) {
          final List<Map<String, dynamic>> dstRows = await txn.query(
            DatabaseConstants.tableAccounts,
            where: '${DatabaseConstants.colId} = ?',
            whereArgs: [transaction.toAccountId],
            limit: 1,
          );

          if (dstRows.isEmpty) {
            throw StateError(
              'Destination account ${transaction.toAccountId} does not exist',
            );
          }

          final int dstCurrentBalance =
              (dstRows.first[DatabaseConstants.colBalanceCents] as num).toInt();
          final AccountType dstType = AccountType.fromString(
            dstRows.first[DatabaseConstants.colAccountType] as String,
          );
          final bool dstIsCreditCard = dstType == AccountType.creditCard;

          // Transfer in to destination: asset increases, credit card debt decreases
          final int dstDeltaCents = dstIsCreditCard
              ? -transaction.amountCents
              : transaction.amountCents;

          final int dstFinalBalance =
              dstCurrentBalance + (dstDeltaCents * multiplier);
          final String now = DateTime.now().toUtc().toIso8601String();

          await txn.update(
            DatabaseConstants.tableAccounts,
            {
              DatabaseConstants.colBalanceCents: dstFinalBalance,
              DatabaseConstants.colUpdatedAt: now,
            },
            where: '${DatabaseConstants.colId} = ?',
            whereArgs: [transaction.toAccountId],
          );
        }
        break;
    }

    final int srcFinalBalance =
        srcCurrentBalance + (srcDeltaCents * multiplier);
    final String now = DateTime.now().toUtc().toIso8601String();

    await txn.update(
      DatabaseConstants.tableAccounts,
      {
        DatabaseConstants.colBalanceCents: srcFinalBalance,
        DatabaseConstants.colUpdatedAt: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [transaction.accountId],
    );
  }
}
