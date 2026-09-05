import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/presentation/screens/analytics/analytics_screen.dart';
import 'package:finance_tracker/presentation/widgets/charts/cash_flow_bar_chart.dart';
import 'package:finance_tracker/presentation/widgets/charts/category_expense_pie_chart.dart';
import 'package:finance_tracker/providers/analytics_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';

class FakeTransactionRepo implements TransactionRepository {
  final List<Transaction> transactions;
  FakeTransactionRepo(this.transactions);
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
  }) async => transactions;
  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async =>
      transactions;
  @override
  Future<Transaction?> getTransactionById(String id) async => null;
  @override
  Future<void> createTransaction(Transaction transaction) async {}
  @override
  Future<void> updateTransaction(Transaction transaction) async {}
  @override
  Future<void> deleteTransaction(String id) async {}
  @override
  Future<int> getTransactionCount({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async => transactions.length;
}

class FakeCategoryRepo implements CategoryRepository {
  final List<Category> categories;
  FakeCategoryRepo(this.categories);
  @override
  Future<List<Category>> getCategories({CategoryType? type}) async => categories;
  @override
  Future<Category?> getCategoryById(String id) async =>
      categories.where((c) => c.id == id).firstOrNull;
  @override
  Future<void> createCategory(Category category) async {}
  @override
  Future<void> updateCategory(Category category) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

void main() {
  final now = DateTime.now();

  final catFood = Category(
    id: 'cat-food',
    name: 'Food',
    iconName: 'restaurant',
    colorHex: '#FF5722',
    type: CategoryType.expense,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final catSalary = Category(
    id: 'cat-salary',
    name: 'Salary',
    iconName: 'payments',
    colorHex: '#4CAF50',
    type: CategoryType.income,
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );

  final txIncomeAug = Transaction(
    id: 'tx-1',
    accountId: 'acc-1',
    categoryId: 'cat-salary',
    amountCents: 400000, // $4,000.00
    type: TransactionType.income,
    description: 'Salary',
    transactionDate: now.subtract(const Duration(days: 35)),
    createdAt: now,
    updatedAt: now,
  );

  final txExpenseAug = Transaction(
    id: 'tx-2',
    accountId: 'acc-1',
    categoryId: 'cat-food',
    amountCents: 150000, // $1,500.00
    type: TransactionType.expense,
    description: 'Food',
    transactionDate: now.subtract(const Duration(days: 30)),
    createdAt: now,
    updatedAt: now,
  );

  final txIncomeSep = Transaction(
    id: 'tx-3',
    accountId: 'acc-1',
    categoryId: 'cat-salary',
    amountCents: 420000, // $4,200.00
    type: TransactionType.income,
    description: 'Salary',
    transactionDate: now,
    createdAt: now,
    updatedAt: now,
  );

  final txExpenseSep = Transaction(
    id: 'tx-4',
    accountId: 'acc-1',
    categoryId: 'cat-food',
    amountCents: 180000, // $1,800.00
    type: TransactionType.expense,
    description: 'Food',
    transactionDate: now,
    createdAt: now,
    updatedAt: now,
  );

  late TransactionsProvider txProv;
  late AnalyticsProvider analyticsProv;

  setUp(() async {
    txProv = TransactionsProvider(
      transactionRepository: FakeTransactionRepo([
        txIncomeAug,
        txExpenseAug,
        txIncomeSep,
        txExpenseSep,
      ]),
      categoryRepository: FakeCategoryRepo([catFood, catSalary]),
    );
    await txProv.initialize();

    analyticsProv = AnalyticsProvider();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<AnalyticsProvider>.value(value: analyticsProv),
      ],
      child: const MaterialApp(
        home: AnalyticsScreen(),
      ),
    );
  }

  group('AnalyticsScreen Widget Tests', () {
    testWidgets('renders timeframe selector, summary metrics, cashflow chart, and pie chart', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Visual Analytics'), findsOneWidget);

      // Timeframe segments
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('90 Days'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);

      // Summary metrics
      expect(find.text('Total Income'), findsOneWidget);
      expect(find.text('Total Expense'), findsWidgets);
      expect(find.text('Net Flow'), findsOneWidget);

      // Month-over-Month Delta
      expect(find.text('Month-over-Month Spend Delta'), findsOneWidget);

      // Cash flow bar chart
      expect(find.text('6-Month Cash Flow Comparison'), findsOneWidget);
      expect(find.byType(CashFlowBarChart), findsOneWidget);

      // Category expense pie chart
      expect(find.text('Category Expense Proportions'), findsOneWidget);
      expect(find.byType(CategoryExpensePieChart), findsOneWidget);
    });

    testWidgets('switching timeframe updates selected timeframe in provider', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap 90 Days segment
      await tester.tap(find.text('90 Days'));
      await tester.pumpAndSettle();

      expect(analyticsProv.selectedTimeframe, AnalyticsTimeframe.last90Days);
    });
  });
}
