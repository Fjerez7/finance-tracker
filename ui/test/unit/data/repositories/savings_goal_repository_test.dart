import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/repositories/savings_goal_repository_impl.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late SavingsGoalRepositoryImpl repository;

  final DateTime now = DateTime.parse('2026-09-05T12:00:00.000Z');

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    repository = SavingsGoalRepositoryImpl(dbHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('SavingsGoalRepositoryImpl SQLite Operations', () {
    final SavingsGoal emergencyFund = SavingsGoal(
      id: 'goal-emergency',
      name: 'Emergency Fund',
      targetAmountCents: 500000, // $5,000.00
      currentAmountCents: 150000, // $1,500.00
      targetDate: DateTime.parse('2027-01-01T00:00:00Z'),
      colorHex: '#4CAF50',
      iconName: 'savings',
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    final SavingsGoal japanTrip = SavingsGoal(
      id: 'goal-trip',
      name: 'Japan Trip',
      targetAmountCents: 300000, // $3,000.00
      currentAmountCents: 300000, // $3,000.00 (completed)
      targetDate: DateTime.parse('2027-06-01T00:00:00Z'),
      colorHex: '#2196F3',
      iconName: 'flight',
      isCompleted: true,
      createdAt: now,
      updatedAt: now,
    );

    test('creates and retrieves savings goals correctly', () async {
      await repository.createSavingsGoal(emergencyFund);
      await repository.createSavingsGoal(japanTrip);

      final List<SavingsGoal> all = await repository.getSavingsGoals();
      expect(all.length, equals(2));

      final SavingsGoal? retrieved = await repository.getSavingsGoalById(
        'goal-emergency',
      );
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Emergency Fund'));
      expect(retrieved.targetAmountCents, equals(500000));
      expect(retrieved.currentAmountCents, equals(150000));
      expect(retrieved.isCompleted, isFalse);
    });

    test('filters savings goals by completion status', () async {
      await repository.createSavingsGoal(emergencyFund);
      await repository.createSavingsGoal(japanTrip);

      final active = await repository.getSavingsGoals(isCompleted: false);
      expect(active.length, equals(1));
      expect(active.first.id, equals('goal-emergency'));

      final completed = await repository.getSavingsGoals(isCompleted: true);
      expect(completed.length, equals(1));
      expect(completed.first.id, equals('goal-trip'));
    });

    test('updates savings goal properties', () async {
      await repository.createSavingsGoal(emergencyFund);

      final updated = emergencyFund.copyWith(
        name: 'Super Emergency Fund',
        targetAmountCents: 1000000,
      );
      await repository.updateSavingsGoal(updated);

      final SavingsGoal? retrieved = await repository.getSavingsGoalById(
        'goal-emergency',
      );
      expect(retrieved!.name, equals('Super Emergency Fund'));
      expect(retrieved.targetAmountCents, equals(1000000));
    });

    test('adjustCurrentAmount increments balance and marks completed when target reached', () async {
      await repository.createSavingsGoal(emergencyFund);

      // Deposit up to 450000 -> not completed
      await repository.adjustCurrentAmount('goal-emergency', 450000);
      SavingsGoal? retrieved = await repository.getSavingsGoalById('goal-emergency');
      expect(retrieved!.currentAmountCents, equals(450000));
      expect(retrieved.isCompleted, isFalse);

      // Deposit remaining 50000 -> 500000 -> marked completed
      await repository.adjustCurrentAmount('goal-emergency', 500000);
      retrieved = await repository.getSavingsGoalById('goal-emergency');
      expect(retrieved!.currentAmountCents, equals(500000));
      expect(retrieved.isCompleted, isTrue);
    });

    test('deletes savings goal from database', () async {
      await repository.createSavingsGoal(emergencyFund);
      await repository.deleteSavingsGoal('goal-emergency');

      final SavingsGoal? retrieved = await repository.getSavingsGoalById(
        'goal-emergency',
      );
      expect(retrieved, isNull);
    });
  });
}
