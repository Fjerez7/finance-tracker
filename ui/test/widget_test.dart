import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/presentation/screens/accounts/accounts_screen.dart';
import 'package:finance_tracker/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:finance_tracker/presentation/screens/transactions/transaction_list_screen.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeAccountRepo implements AccountRepository {
  final List<Account> accounts;
  FakeAccountRepo(this.accounts);
  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async =>
      accounts;
  @override
  Future<Account?> getAccountById(String id) async =>
      accounts.where((a) => a.id == id).firstOrNull;
  @override
  Future<void> createAccount(Account account) async => accounts.add(account);
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async {}
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeCategoryRepo implements CategoryRepository {
  final List<Category> categories;
  FakeCategoryRepo(this.categories);
  @override
  Future<List<Category>> getCategories({CategoryType? type}) async =>
      categories;
  @override
  Future<Category?> getCategoryById(String id) async =>
      categories.where((c) => c.id == id).firstOrNull;
  @override
  Future<void> createCategory(Category category) async =>
      categories.add(category);
  @override
  Future<void> updateCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

class FakeTransactionRepo implements TransactionRepository {
  final List<Transaction> transactions = [];
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
  Future<Transaction?> getTransactionById(String id) async =>
      transactions.where((t) => t.id == id).firstOrNull;
  @override
  Future<void> createTransaction(Transaction transaction) async =>
      transactions.add(transaction);
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
  testWidgets(
    'FinanceTrackerApp smoke test renders navigation shell and tabs',
    (WidgetTester tester) async {
      final now = DateTime.parse('2026-09-04T12:00:00Z');
      final testAccount = Account(
        id: 'acc-1',
        name: 'Checking Account',
        type: AccountType.bank,
        balanceCents: 150000,
        currency: 'USD',
        colorHex: '#4CAF50',
        iconName: 'account_balance',
        createdAt: now,
        updatedAt: now,
      );

      final accountRepo = FakeAccountRepo([testAccount]);
      final categoryRepo = FakeCategoryRepo([]);
      final txRepo = FakeTransactionRepo();

      final accountsProvider = AccountsProvider(repository: accountRepo);
      await accountsProvider.loadAccounts();

      final txProvider = TransactionsProvider(
        transactionRepository: txRepo,
        categoryRepository: categoryRepo,
      );
      await txProvider.initialize();

      await tester.pumpWidget(
        FinanceTrackerApp(
          accountsProvider: accountsProvider,
          transactionsProvider: txProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigationShell), findsOneWidget);
      expect(find.byType(TransactionListScreen), findsOneWidget);
      expect(find.text('Transactions'), findsWidgets);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Switch tab to Accounts
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      expect(find.byType(AccountsScreen), findsOneWidget);

      // Switch tab to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
    },
  );
}
