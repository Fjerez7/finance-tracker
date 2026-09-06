import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/sqlite_exchange_rate_repository.dart';
import 'package:finance_tracker/domain/entities/exchange_rate_result.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late SqliteExchangeRateRepository repo;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.initDatabase();
    repo = SqliteExchangeRateRepository(dbHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SqliteExchangeRateRepository Unit Tests', () {
    test('returns null when no cached rates exist for base currency', () async {
      final result = await repo.getCachedRates('USD');
      expect(result, isNull);
    });

    test('saves and retrieves cached exchange rates for USD', () async {
      final now = DateTime.utc(2026, 9, 6, 15, 0);
      final rates = {
        'USD': 1.0,
        'COP': 4150.50,
        'EUR': 0.86,
      };

      final toSave = ExchangeRateResult(
        baseCode: 'USD',
        rates: rates,
        lastUpdatedUtc: now,
      );

      await repo.saveRates(toSave);

      final cached = await repo.getCachedRates('usd');
      expect(cached, isNotNull);
      expect(cached!.baseCode, 'USD');
      expect(cached.rates['COP'], 4150.50);
      expect(cached.rates['EUR'], 0.86);
      expect(cached.getRate('COP'), 4150.50);
      expect(cached.getRate('USD'), 1.0);
    });

    test('updates existing cached rates cleanly without duplicates', () async {
      final first = ExchangeRateResult(
        baseCode: 'USD',
        rates: {'COP': 4100.0},
        lastUpdatedUtc: DateTime.utc(2026, 9, 5),
      );
      await repo.saveRates(first);

      final second = ExchangeRateResult(
        baseCode: 'USD',
        rates: {'COP': 4200.0, 'EUR': 0.87},
        lastUpdatedUtc: DateTime.utc(2026, 9, 6),
      );
      await repo.saveRates(second);

      final cached = await repo.getCachedRates('USD');
      expect(cached, isNotNull);
      expect(cached!.rates['COP'], 4200.0);
      expect(cached.rates['EUR'], 0.87);
    });
  });
}
