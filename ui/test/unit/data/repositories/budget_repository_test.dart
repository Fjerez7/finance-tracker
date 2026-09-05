import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/budget_repository_impl.dart';
import 'package:finance_tracker/domain/entities/budget.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late BudgetRepositoryImpl repository;

  final DateTime now = DateTime.parse('2026-09-05T12:00:00.000Z');

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    repository = BudgetRepositoryImpl(dbHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('BudgetRepositoryImpl SQLite Operations', () {
    final Budget foodBudget = Budget(
      id: 'budget-food-sep',
      categoryId: 'cat_default_food',
      month: 9,
      year: 2026,
      limitCents: 60000, // $600.00
      createdAt: now,
      updatedAt: now,
    );

    final Budget groceriesBudget = Budget(
      id: 'budget-groceries-sep',
      categoryId: 'cat_default_groceries',
      month: 9,
      year: 2026,
      limitCents: 40000, // $400.00
      createdAt: now,
      updatedAt: now,
    );

    final Budget foodBudgetOct = Budget(
      id: 'budget-food-oct',
      categoryId: 'cat_default_food',
      month: 10,
      year: 2026,
      limitCents: 65000, // $650.00
      createdAt: now,
      updatedAt: now,
    );

    test('creates and retrieves budgets correctly', () async {
      await repository.createBudget(foodBudget);
      await repository.createBudget(groceriesBudget);

      final List<Budget> all = await repository.getBudgets();
      expect(all.length, equals(2));

      final Budget? retrieved = await repository.getBudgetById('budget-food-sep');
      expect(retrieved, isNotNull);
      expect(retrieved!.categoryId, equals('cat_default_food'));
      expect(retrieved.month, equals(9));
      expect(retrieved.year, equals(2026));
      expect(retrieved.limitCents, equals(60000));
    });

    test('retrieves budget for specific category, month, and year', () async {
      await repository.createBudget(foodBudget);
      await repository.createBudget(foodBudgetOct);

      final Budget? sepBudget = await repository.getBudgetForCategory(
        'cat_default_food',
        9,
        2026,
      );
      expect(sepBudget, isNotNull);
      expect(sepBudget!.id, equals('budget-food-sep'));
      expect(sepBudget.limitCents, equals(60000));

      final Budget? nonExistent = await repository.getBudgetForCategory(
        'cat_default_entertainment',
        9,
        2026,
      );
      expect(nonExistent, isNull);
    });

    test('filters budgets by month and year', () async {
      await repository.createBudget(foodBudget);
      await repository.createBudget(groceriesBudget);
      await repository.createBudget(foodBudgetOct);

      final sepBudgets = await repository.getBudgets(month: 9, year: 2026);
      expect(sepBudgets.length, equals(2));

      final octBudgets = await repository.getBudgets(month: 10, year: 2026);
      expect(octBudgets.length, equals(1));
      expect(octBudgets.first.id, equals('budget-food-oct'));
    });

    test('updates budget limit', () async {
      await repository.createBudget(foodBudget);

      final updated = foodBudget.copyWith(limitCents: 75000);
      await repository.updateBudget(updated);

      final Budget? retrieved = await repository.getBudgetById('budget-food-sep');
      expect(retrieved!.limitCents, equals(75000));
    });

    test('deletes budget from database', () async {
      await repository.createBudget(foodBudget);
      await repository.deleteBudget('budget-food-sep');

      final Budget? retrieved = await repository.getBudgetById('budget-food-sep');
      expect(retrieved, isNull);
    });
  });
}
