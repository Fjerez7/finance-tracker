import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../domain/entities/exchange_rate_result.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/local/database_helper.dart';

/// SQLite implementation of [ExchangeRateRepository] storing rates in the `exchange_rates` table.
class SqliteExchangeRateRepository implements ExchangeRateRepository {
  final DatabaseHelper _dbHelper;

  SqliteExchangeRateRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<ExchangeRateResult?> getCachedRates(String baseCurrency) async {
    final db = await _dbHelper.database;
    final currency = baseCurrency.toUpperCase().trim();

    final List<Map<String, dynamic>> rows = await db.query(
      DatabaseConstants.tableExchangeRates,
      where: '${DatabaseConstants.colBaseCurrency} = ?',
      whereArgs: [currency],
    );

    if (rows.isEmpty) {
      return null;
    }

    final Map<String, double> rates = {};
    DateTime lastUpdated = DateTime.now().toUtc();

    for (final row in rows) {
      final target = row[DatabaseConstants.colTargetCurrency] as String;
      final rate = (row[DatabaseConstants.colRate] as num).toDouble();
      rates[target.toUpperCase()] = rate;

      final updatedStr = row[DatabaseConstants.colLastUpdated] as String?;
      if (updatedStr != null) {
        try {
          final dt = DateTime.parse(updatedStr).toUtc();
          if (dt.isAfter(lastUpdated) || lastUpdated == DateTime.now().toUtc()) {
            lastUpdated = dt;
          }
        } catch (_) {}
      }
    }

    return ExchangeRateResult(
      baseCode: currency,
      rates: rates,
      lastUpdatedUtc: lastUpdated,
    );
  }

  @override
  Future<void> saveRates(ExchangeRateResult result) async {
    final db = await _dbHelper.database;
    final base = result.baseCode.toUpperCase().trim();
    final updatedStr = result.lastUpdatedUtc.toIso8601String();

    final batch = db.batch();

    for (final entry in result.rates.entries) {
      batch.insert(
        DatabaseConstants.tableExchangeRates,
        {
          DatabaseConstants.colBaseCurrency: base,
          DatabaseConstants.colTargetCurrency: entry.key.toUpperCase().trim(),
          DatabaseConstants.colRate: entry.value,
          DatabaseConstants.colLastUpdated: updatedStr,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
}
