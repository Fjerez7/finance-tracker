import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/budget_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/savings_goal_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/presentation/screens/budgets/savings_goals_screen.dart';
import 'package:finance_tracker/presentation/widgets/cards/savings_goal_card.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/budgets_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeSavingsGoalRepository implements SavingsGoalRepository {
  final List<SavingsGoal> goals;
  FakeSavingsGoalRepository(this.goals);

  @override
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted}) async {
    if (isCompleted != null) {
      return goals.where((g) => g.isCompleted == isCompleted).toList();
    }
    return List.from(goals);
  }

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async =>
      goals.where((g) => g.id == id).firstOrNull;

  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async => goals.add(goal);

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) goals[index] = goal;
  }

  @override
  Future<void> deleteSavingsGoal(String id) async =>
      goals.removeWhere((g) => g.id == id);

  @override
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = goals[index];
      final bool completed = newCurrentAmountCents >= g.targetAmountCents;
      goals[index] = g.copyWith(
        currentAmountCents: newCurrentAmountCents,
        isCompleted: completed,
      );
    }
  }
}

class FakeBudgetRepository implements BudgetRepository {
  @override
  Future<List<Budget>> getBudgets({int? month, int? year, String? categoryId}) async => [];
  @override
  Future<Budget?> getBudgetById(String id) async => null;
  @override
  Future<Budget?> getBudgetForCategory(String categoryId, int month, int year) async => null;
  @override
  Future<void> createBudget(Budget budget) async {}
  @override
  Future<void> updateBudget(Budget budget) async {}
  @override
  Future<void> deleteBudget(String id) async {}
}

class FakeAccountRepo implements AccountRepository {
  final List<Account> accounts;
  FakeAccountRepo(this.accounts);

  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async =>
      accounts;
  @override
  Future<Account?> getAccountById(String id) async => null;
  @override
  Future<void> createAccount(Account account) async => accounts.add(account);
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async {}
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {
    final index = accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final acc = accounts[index];
      accounts[index] = Account(
        id: acc.id,
        name: acc.name,
        type: acc.type,
        balanceCents: newBalanceCents,
        creditLimitCents: acc.creditLimitCents,
        currency: acc.currency,
        colorHex: acc.colorHex,
        iconName: acc.iconName,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      );
    }
  }
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeCategoryRepo implements CategoryRepository {
  @override
  Future<List<Category>> getCategories({CategoryType? type}) async => [];
  @override
  Future<Category?> getCategoryById(String id) async => null;
  @override
  Future<void> createCategory(Category category) async {}
  @override
  Future<void> updateCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

class FakeTransactionRepo implements TransactionRepository {
  final List<Transaction> transactions = [];
  final FakeAccountRepo? accountRepo;
  FakeTransactionRepo([this.accountRepo]);

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
  }) async => List.from(transactions);

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async =>
      List.from(transactions);
  @override
  Future<Transaction?> getTransactionById(String id) async => null;

  @override
  Future<void> createTransaction(Transaction transaction) async {
    transactions.add(transaction);
    if (accountRepo != null) {
      final acc = accountRepo!.accounts
          .where((a) => a.id == transaction.accountId)
          .firstOrNull;
      if (acc != null) {
        final newBal =
            transaction.type == TransactionType.expense
                ? acc.balanceCents - transaction.amountCents
                : acc.balanceCents + transaction.amountCents;
        await accountRepo!.adjustBalance(acc.id, newBal);
      }
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {}
  @override
  Future<void> deleteTransaction(String id) async =>
      transactions.removeWhere((t) => t.id == id);
  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async => transactions.length;
}

void main() {
  final now = DateTime.parse('2026-09-04T12:00:00Z');

  final Account testAccount = Account(
    id: 'acc-1',
    name: 'Savings Vault',
    type: AccountType.bank,
    balanceCents: 500000, // $5,000.00
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    createdAt: now,
    updatedAt: now,
  );

  final SavingsGoal activeGoal = SavingsGoal(
    id: 'g-trip',
    name: 'Trip to Tokyo',
    targetAmountCents: 200000, // $2,000.00
    currentAmountCents: 50000, // $500.00 (25%)
    colorHex: '#2196F3',
    iconName: 'flight',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
  );

  final SavingsGoal completedGoal = SavingsGoal(
    id: 'g-camera',
    name: 'DSLR Camera',
    targetAmountCents: 80000, // $800.00
    currentAmountCents: 80000, // $800.00 (100%)
    colorHex: '#FF9800',
    iconName: 'photo_camera',
    isCompleted: true,
    createdAt: now,
    updatedAt: now,
  );

  late FakeSavingsGoalRepository goalRepo;
  late FakeBudgetRepository budgetRepo;
  late FakeAccountRepo accountRepo;
  late FakeCategoryRepo catRepo;
  late FakeTransactionRepo txRepo;

  late BudgetsProvider budgetsProv;
  late AccountsProvider accountsProv;
  late TransactionsProvider txProv;

  setUp(() async {
    goalRepo = FakeSavingsGoalRepository([activeGoal, completedGoal]);
    budgetRepo = FakeBudgetRepository();
    accountRepo = FakeAccountRepo([testAccount]);
    catRepo = FakeCategoryRepo();
    txRepo = FakeTransactionRepo(accountRepo);

    accountsProv = AccountsProvider(repository: accountRepo);
    await accountsProv.loadAccounts();

    txProv = TransactionsProvider(
      transactionRepository: txRepo,
      categoryRepository: catRepo,
    );
    await txProv.initialize();

    budgetsProv = BudgetsProvider(
      budgetRepository: budgetRepo,
      savingsGoalRepository: goalRepo,
      initialMonth: 9,
      initialYear: 2026,
    );
    await budgetsProv.initialize();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProv),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<BudgetsProvider>.value(value: budgetsProv),
      ],
      child: const MaterialApp(home: SavingsGoalsScreen()),
    );
  }

  group('SavingsGoalsScreen Widget Tests', () {
    testWidgets('renders active tab with savings goal cards and completed tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Savings Goals'), findsOneWidget);
      expect(find.text('Active (1)'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);

      expect(find.text('Trip to Tokyo'), findsOneWidget);
      expect(find.text('\$500.00 saved'), findsOneWidget);
      expect(find.byType(SavingsGoalCard), findsOneWidget);
    });

    testWidgets('depositing funds updates goal balance and deducts from account', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final depositButton = find.text('Deposit');
      expect(depositButton, findsOneWidget);

      await tester.tap(depositButton);
      await tester.pumpAndSettle();

      expect(find.text('Deposit to Trip to Tokyo'), findsOneWidget);

      // Enter amount: 300.00 ($300.00)
      final inputFinder = find.widgetWithText(TextFormField, 'Deposit Amount');
      await tester.enterText(inputFinder, '300.00');

      // Tap Deposit confirmation button
      await tester.tap(find.widgetWithText(FilledButton, 'Deposit'));
      await tester.pumpAndSettle();

      // Verify goal balance updated: 50000 + 30000 = 80000 ($800.00)
      expect(goalRepo.goals.first.currentAmountCents, equals(80000));
      // Verify account balance deducted: 500000 - 30000 = 470000
      expect(accountRepo.accounts.first.balanceCents, equals(470000));

      expect(
        find.text('Deposited \$300.00 into Trip to Tokyo!'),
        findsOneWidget,
      );
    });

    testWidgets('switching to Completed tab renders completed goals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.text('Completed (1)'));
      await tester.pumpAndSettle();

      expect(find.text('DSLR Camera'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });
  });
}
