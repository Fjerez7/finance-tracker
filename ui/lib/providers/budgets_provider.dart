import 'package:flutter/foundation.dart';
import '../domain/entities/budget.dart';
import '../domain/entities/savings_goal.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/savings_goal_repository.dart';
import 'accounts_provider.dart';
import 'transactions_provider.dart';

/// Enum representing the threshold status of a category budget.
enum BudgetThresholdStatus {
  /// Spent < 80% of budget limit (Normal / Safe).
  safe,

  /// Spent between 80% and 99.9% of budget limit (Warning threshold).
  warning,

  /// Spent >= 100% of budget limit (Exceeded).
  exceeded,
}

/// Reactive provider managing category budgets, monthly spend reconciliation, and savings goals.
class BudgetsProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepository;
  final SavingsGoalRepository _savingsGoalRepository;

  int _selectedMonth;
  int _selectedYear;

  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String? _errorMessage;

  BudgetsProvider({
    required BudgetRepository budgetRepository,
    required SavingsGoalRepository savingsGoalRepository,
    int? initialMonth,
    int? initialYear,
  }) : _budgetRepository = budgetRepository,
       _savingsGoalRepository = savingsGoalRepository,
       _selectedMonth = initialMonth ?? DateTime.now().month,
       _selectedYear = initialYear ?? DateTime.now().year;

  // Getters
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SavingsGoal> get activeSavingsGoals =>
      _savingsGoals.where((g) => !g.isCompleted).toList();

  List<SavingsGoal> get completedSavingsGoals =>
      _savingsGoals.where((g) => g.isCompleted).toList();

  /// Total sum of all budget limits for the currently selected month and year.
  int get totalMonthlyBudgetLimitCents =>
      _budgets.fold(0, (sum, b) => sum + b.limitCents);

  /// Initializes provider by loading budgets for current period and all savings goals.
  Future<void> initialize() async {
    await Future.wait([
      loadBudgetsForSelectedPeriod(),
      loadSavingsGoals(),
    ]);
  }

  /// Changes the active calendar period and reloads corresponding budgets.
  void setPeriod(int month, int year) {
    if (month < 1 || month > 12) return;
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
    loadBudgetsForSelectedPeriod();
  }

  /// Advances period to next chronological month.
  void nextMonth() {
    int nextM = _selectedMonth + 1;
    int nextY = _selectedYear;
    if (nextM > 12) {
      nextM = 1;
      nextY += 1;
    }
    setPeriod(nextM, nextY);
  }

  /// Moves period to previous chronological month.
  void previousMonth() {
    int prevM = _selectedMonth - 1;
    int prevY = _selectedYear;
    if (prevM < 1) {
      prevM = 12;
      prevY -= 1;
    }
    setPeriod(prevM, prevY);
  }

  /// Computes total spent cents in the selected month across all expense categories.
  int calculateTotalMonthlySpentCents(TransactionsProvider txProv) {
    return txProv.transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.transactionDate.month == _selectedMonth &&
          t.transactionDate.year == _selectedYear;
    }).fold(0, (sum, t) => sum + t.amountCents);
  }

  /// Computes spent cents for a specific category in the selected month.
  int calculateCategorySpentCents(
    String categoryId,
    TransactionsProvider txProv,
  ) {
    return txProv.transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.categoryId == categoryId &&
          t.transactionDate.month == _selectedMonth &&
          t.transactionDate.year == _selectedYear;
    }).fold(0, (sum, t) => sum + t.amountCents);
  }

  /// Evaluates threshold status (safe, warning, exceeded) for a budget.
  BudgetThresholdStatus evaluateThresholdStatus(
    Budget budget,
    int spentCents,
  ) {
    final double ratio = budget.progressRatio(spentCents);
    if (ratio >= 1.0) {
      return BudgetThresholdStatus.exceeded;
    } else if (ratio >= 0.8) {
      return BudgetThresholdStatus.warning;
    } else {
      return BudgetThresholdStatus.safe;
    }
  }

  /// Loads all budgets matching selected month and year.
  Future<void> loadBudgetsForSelectedPeriod() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _budgets = await _budgetRepository.getBudgets(
        month: _selectedMonth,
        year: _selectedYear,
      );
    } catch (e) {
      _errorMessage = 'Failed to load budgets: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new budget entry.
  Future<void> addBudget(Budget budget) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _budgetRepository.createBudget(budget);
      await loadBudgetsForSelectedPeriod();
    } catch (e) {
      _errorMessage = 'Failed to add budget: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing budget entry.
  Future<void> updateBudget(Budget budget) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _budgetRepository.updateBudget(budget);
      await loadBudgetsForSelectedPeriod();
    } catch (e) {
      _errorMessage = 'Failed to update budget: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a budget entry.
  Future<void> deleteBudget(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _budgetRepository.deleteBudget(id);
      await loadBudgetsForSelectedPeriod();
    } catch (e) {
      _errorMessage = 'Failed to delete budget: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Loads all savings goals from repository.
  Future<void> loadSavingsGoals() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _savingsGoals = await _savingsGoalRepository.getSavingsGoals();
    } catch (e) {
      _errorMessage = 'Failed to load savings goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new savings goal target.
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _savingsGoalRepository.createSavingsGoal(goal);
      await loadSavingsGoals();
    } catch (e) {
      _errorMessage = 'Failed to create savings goal: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing savings goal.
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _savingsGoalRepository.updateSavingsGoal(goal);
      await loadSavingsGoals();
    } catch (e) {
      _errorMessage = 'Failed to update savings goal: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a savings goal.
  Future<void> deleteSavingsGoal(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _savingsGoalRepository.deleteSavingsGoal(id);
      await loadSavingsGoals();
    } catch (e) {
      _errorMessage = 'Failed to delete savings goal: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deposits funds into a savings goal, advancing current balance and optionally recording a transaction.
  Future<void> depositFunds(
    String goalId,
    int amountCents, {
    String? fromAccountId,
    AccountsProvider? accountsProvider,
    TransactionsProvider? transactionsProvider,
  }) async {
    if (amountCents <= 0) {
      throw ArgumentError('Deposit amount must be strictly positive');
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final goal = await _savingsGoalRepository.getSavingsGoalById(goalId);
      if (goal == null) {
        throw ArgumentError('Savings goal with id $goalId not found');
      }

      final newTotal = goal.currentAmountCents + amountCents;
      await _savingsGoalRepository.adjustCurrentAmount(goalId, newTotal);

      // If source account provided, log an expense/transfer transaction
      if (fromAccountId != null &&
          transactionsProvider != null &&
          accountsProvider != null) {
        final now = DateTime.now();
        final tx = Transaction(
          id: 'tx_goal_${goalId}_${now.millisecondsSinceEpoch}',
          accountId: fromAccountId,
          categoryId: null,
          amountCents: amountCents,
          type: TransactionType.expense,
          description: 'Savings Deposit: ${goal.name}',
          transactionDate: now,
          createdAt: now.toUtc(),
          updatedAt: now.toUtc(),
        );
        await transactionsProvider.addTransaction(
          tx,
          accountsProvider: accountsProvider,
        );
      }

      await loadSavingsGoals();
    } catch (e) {
      _errorMessage = 'Failed to deposit funds: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
