import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/budget_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/savings_goal_repository_impl.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'presentation/screens/accounts/accounts_screen.dart';
import 'presentation/screens/budgets/budgets_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/subscriptions/subscriptions_screen.dart';
import 'presentation/screens/transactions/quick_transaction_screen.dart';
import 'presentation/screens/transactions/transaction_list_screen.dart';
import 'providers/accounts_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/backup_provider.dart';
import 'providers/budgets_provider.dart';
import 'providers/subscriptions_provider.dart';
import 'providers/transactions_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinanceTrackerApp());
}

/// The root application widget for Finance Tracker.
/// Configures dependency injection providers, theming, and bottom navigation shell.
class FinanceTrackerApp extends StatelessWidget {
  final AccountsProvider? accountsProvider;
  final TransactionsProvider? transactionsProvider;
  final SubscriptionsProvider? subscriptionsProvider;
  final BudgetsProvider? budgetsProvider;
  final AnalyticsProvider? analyticsProvider;
  final BackupProvider? backupProvider;

  const FinanceTrackerApp({
    super.key,
    this.accountsProvider,
    this.transactionsProvider,
    this.subscriptionsProvider,
    this.budgetsProvider,
    this.analyticsProvider,
    this.backupProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (accountsProvider != null)
          ChangeNotifierProvider<AccountsProvider>.value(
            value: accountsProvider!,
          )
        else
          ChangeNotifierProvider<AccountsProvider>(
            create: (_) =>
                AccountsProvider(repository: AccountRepositoryImpl())
                  ..loadAccounts(),
          ),
        if (transactionsProvider != null)
          ChangeNotifierProvider<TransactionsProvider>.value(
            value: transactionsProvider!,
          )
        else
          ChangeNotifierProvider<TransactionsProvider>(
            create: (_) => TransactionsProvider(
              transactionRepository: TransactionRepositoryImpl(),
              categoryRepository: CategoryRepositoryImpl(),
            )..initialize(),
          ),
        if (subscriptionsProvider != null)
          ChangeNotifierProvider<SubscriptionsProvider>.value(
            value: subscriptionsProvider!,
          )
        else
          ChangeNotifierProvider<SubscriptionsProvider>(
            create: (_) => SubscriptionsProvider(
              repository: SubscriptionRepositoryImpl(),
            )..loadSubscriptions(),
          ),
        if (budgetsProvider != null)
          ChangeNotifierProvider<BudgetsProvider>.value(
            value: budgetsProvider!,
          )
        else
          ChangeNotifierProvider<BudgetsProvider>(
            create: (_) => BudgetsProvider(
              budgetRepository: BudgetRepositoryImpl(),
              savingsGoalRepository: SavingsGoalRepositoryImpl(),
            )..initialize(),
          ),
        if (analyticsProvider != null)
          ChangeNotifierProvider<AnalyticsProvider>.value(
            value: analyticsProvider!,
          )
        else
          ChangeNotifierProvider<AnalyticsProvider>(
            create: (_) => AnalyticsProvider(),
          ),
        if (backupProvider != null)
          ChangeNotifierProvider<BackupProvider>.value(
            value: backupProvider!,
          )
        else
          ChangeNotifierProvider<BackupProvider>(
            create: (_) => BackupProvider()..checkExistingAuth(),
          ),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5), // Material Blue
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MainNavigationShell(),
      ),
    );
  }
}

/// Shell hosting bottom navigation tabs across modules.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 1; // Default to Transactions tab

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    BudgetsScreen(),
    SubscriptionsScreen(),
    AccountsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Subscriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              tooltip: 'Quick Transaction',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuickTransactionScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
