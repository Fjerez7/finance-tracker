import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/database_constants.dart';

/// Exception thrown when a backup snapshot fails integrity or schema verification.
class BackupValidationException implements Exception {
  final String message;
  const BackupValidationException(this.message);

  @override
  String toString() => 'BackupValidationException: $message';
}

/// Service handling JSON backup creation, checksum validation, and atomic database restoration.
class BackupRestoreService {
  static const int currentBackupVersion = 1;

  /// Creates a full JSON snapshot of all database tables with SHA-256 checksum.
  static Future<Map<String, dynamic>> createBackupSnapshot(Database db) async {
    final List<Map<String, dynamic>> accounts = await db.query(
      DatabaseConstants.tableAccounts,
    );
    final List<Map<String, dynamic>> categories = await db.query(
      DatabaseConstants.tableCategories,
    );
    final List<Map<String, dynamic>> transactions = await db.query(
      DatabaseConstants.tableTransactions,
    );
    final List<Map<String, dynamic>> subscriptions = await db.query(
      DatabaseConstants.tableSubscriptions,
    );
    final List<Map<String, dynamic>> budgets = await db.query(
      DatabaseConstants.tableBudgets,
    );
    final List<Map<String, dynamic>> savingsGoals = await db.query(
      DatabaseConstants.tableSavingsGoals,
    );

    final Map<String, dynamic> dataPayload = {
      'accounts': accounts,
      'categories': categories,
      'transactions': transactions,
      'subscriptions': subscriptions,
      'budgets': budgets,
      'savings_goals': savingsGoals,
    };

    final String dataJson = jsonEncode(dataPayload);
    final String checksum = sha256.convert(utf8.encode(dataJson)).toString();

    return {
      'version': currentBackupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'checksum': checksum,
      'data': dataPayload,
    };
  }

  /// Validates snapshot structure, version compatibility, and SHA-256 data integrity.
  static void validateSnapshot(Map<String, dynamic> snapshot) {
    if (!snapshot.containsKey('version') ||
        !snapshot.containsKey('checksum') ||
        !snapshot.containsKey('data')) {
      throw const BackupValidationException(
        'Invalid backup format: Missing root properties.',
      );
    }

    final int version = snapshot['version'] as int? ?? 0;
    if (version != currentBackupVersion) {
      throw BackupValidationException(
        'Unsupported backup version: $version (expected $currentBackupVersion).',
      );
    }

    final data = snapshot['data'];
    if (data is! Map<String, dynamic>) {
      throw const BackupValidationException(
        'Invalid backup format: "data" is not a valid map.',
      );
    }

    final String expectedChecksum = snapshot['checksum'] as String? ?? '';
    final String calculatedChecksum =
        sha256.convert(utf8.encode(jsonEncode(data))).toString();

    if (expectedChecksum != calculatedChecksum) {
      throw const BackupValidationException(
        'Checksum verification failed: Backup file is corrupted or tampered.',
      );
    }
  }

  /// Restores database state from a validated snapshot atomically within a SQLite transaction.
  static Future<void> restoreFromSnapshot(
    Database db,
    Map<String, dynamic> snapshot,
  ) async {
    validateSnapshot(snapshot);

    final Map<String, dynamic> data =
        snapshot['data'] as Map<String, dynamic>;

    final List<dynamic> accounts = data['accounts'] as List<dynamic>? ?? [];
    final List<dynamic> categories =
        data['categories'] as List<dynamic>? ?? [];
    final List<dynamic> transactions =
        data['transactions'] as List<dynamic>? ?? [];
    final List<dynamic> subscriptions =
        data['subscriptions'] as List<dynamic>? ?? [];
    final List<dynamic> budgets = data['budgets'] as List<dynamic>? ?? [];
    final List<dynamic> savingsGoals =
        data['savings_goals'] as List<dynamic>? ?? [];

    await db.transaction((txn) async {
      // 1. Temporarily disable foreign keys for clean table wipe and restore
      await txn.execute('PRAGMA foreign_keys = OFF;');

      // 2. Clear all tables in child-to-parent order
      await txn.delete(DatabaseConstants.tableTransactions);
      await txn.delete(DatabaseConstants.tableSubscriptions);
      await txn.delete(DatabaseConstants.tableBudgets);
      await txn.delete(DatabaseConstants.tableSavingsGoals);
      await txn.delete(DatabaseConstants.tableAccounts);
      await txn.delete(DatabaseConstants.tableCategories);

      // 3. Batch insert restored rows
      final batch = txn.batch();

      for (final raw in accounts) {
        batch.insert(
          DatabaseConstants.tableAccounts,
          Map<String, dynamic>.from(raw as Map),
        );
      }
      for (final raw in categories) {
        batch.insert(
          DatabaseConstants.tableCategories,
          Map<String, dynamic>.from(raw as Map),
        );
      }
      for (final raw in subscriptions) {
        batch.insert(
          DatabaseConstants.tableSubscriptions,
          Map<String, dynamic>.from(raw as Map),
        );
      }
      for (final raw in budgets) {
        batch.insert(
          DatabaseConstants.tableBudgets,
          Map<String, dynamic>.from(raw as Map),
        );
      }
      for (final raw in savingsGoals) {
        batch.insert(
          DatabaseConstants.tableSavingsGoals,
          Map<String, dynamic>.from(raw as Map),
        );
      }
      for (final raw in transactions) {
        batch.insert(
          DatabaseConstants.tableTransactions,
          Map<String, dynamic>.from(raw as Map),
        );
      }

      await batch.commit(noResult: true);

      // 4. Re-enable foreign keys
      await txn.execute('PRAGMA foreign_keys = ON;');
    });
  }
}
