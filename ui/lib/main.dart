import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/datasources/remote/gmail_remote_datasource.dart';
import 'data/datasources/remote/inbox_remote_datasource.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/budget_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/inbox_repository_impl.dart';
import 'data/repositories/savings_goal_repository_impl.dart';
import 'data/repositories/sqlite_exchange_rate_repository.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/usecases/sync_inbox_transactions_usecase.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/screens/accounts/accounts_screen.dart';
import 'presentation/screens/budgets/budgets_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/security/app_lock_screen.dart';
import 'presentation/screens/subscriptions/subscriptions_screen.dart';
import 'presentation/screens/transactions/quick_transaction_screen.dart';
import 'presentation/screens/transactions/transaction_list_screen.dart';
import 'providers/accounts_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/app_lock_provider.dart';
import 'providers/backup_provider.dart';
import 'providers/budgets_provider.dart';
import 'providers/exchange_rate_provider.dart';
import 'providers/inbox_sync_provider.dart';
import 'providers/notification_sync_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/subscriptions_provider.dart';
import 'providers/transactions_provider.dart';
import 'services/gemini_extraction_service.dart';
import 'services/gmail_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // If running in environment without google-services config (e.g. desktop/test), proceed gracefully.
  }
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
  final SettingsProvider? settingsProvider;
  final ExchangeRateProvider? exchangeRateProvider;
  final InboxSyncProvider? inboxSyncProvider;
  final AppLockProvider? appLockProvider;
  final NotificationSyncProvider? notificationSyncProvider;

  const FinanceTrackerApp({
    super.key,
    this.accountsProvider,
    this.transactionsProvider,
    this.subscriptionsProvider,
    this.budgetsProvider,
    this.analyticsProvider,
    this.backupProvider,
    this.settingsProvider,
    this.exchangeRateProvider,
    this.inboxSyncProvider,
    this.appLockProvider,
    this.notificationSyncProvider,
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
        if (settingsProvider != null)
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider!,
          )
        else
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider()..loadSettings(),
          ),
        if (exchangeRateProvider != null)
          ChangeNotifierProvider<ExchangeRateProvider>.value(
            value: exchangeRateProvider!,
          )
        else
          ChangeNotifierProvider<ExchangeRateProvider>(
            create: (_) => ExchangeRateProvider(
              repository: SqliteExchangeRateRepository(),
            )..initialize(),
          ),
        if (inboxSyncProvider != null)
          ChangeNotifierProvider<InboxSyncProvider>.value(
            value: inboxSyncProvider!,
          )
        else
          ChangeNotifierProvider<InboxSyncProvider>(
            create: (ctx) {
              final gmailAuth = GmailAuthServiceImpl();
              final gmailSource = GmailRemoteDataSourceImpl();
              final geminiExtraction = GeminiExtractionServiceImpl();

              return InboxSyncProvider(
                gmailAuthService: gmailAuth,
                syncUseCase: SyncInboxTransactionsUseCase(
                  InboxRepositoryImpl(
                    remoteDataSource: InboxRemoteDataSourceImpl(),
                    transactionRepository: TransactionRepositoryImpl(),
                    accountRepository: AccountRepositoryImpl(),
                    categoryRepository: CategoryRepositoryImpl(),
                    subscriptionRepository: SubscriptionRepositoryImpl(),
                    gmailRemoteDataSource: gmailSource,
                    geminiExtractionService: geminiExtraction,
                  ),
                ),
              )..checkExistingAuth();
            },
          ),
        if (appLockProvider != null)
          ChangeNotifierProvider<AppLockProvider>.value(
            value: appLockProvider!,
          )
        else
          ChangeNotifierProvider<AppLockProvider>(
            create: (_) => AppLockProvider()..initialize(),
          ),
        if (notificationSyncProvider != null)
          ChangeNotifierProvider<NotificationSyncProvider>.value(
            value: notificationSyncProvider!,
          )
        else
          ChangeNotifierProvider<NotificationSyncProvider>(
            create: (_) => NotificationSyncProvider()..initialize(),
          ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Finance Tracker',
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
          );
        },
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

class _MainNavigationShellState extends State<MainNavigationShell> with WidgetsBindingObserver {
  int _currentIndex = 1; // Default to Transactions tab

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    BudgetsScreen(),
    SubscriptionsScreen(),
    AccountsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Trigger automatic background synchronization on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAutoSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      context.read<AppLockProvider?>()?.handleAppLifecycleState(state);
    } catch (_) {}

    if (state == AppLifecycleState.resumed) {
      // Trigger automatic synchronization when app returns from background
      _triggerAutoSync();
    }
  }

  void _triggerAutoSync() {
    if (!mounted) return;
    try {
      final inboxSync = context.read<InboxSyncProvider?>();
      final notifSync = context.read<NotificationSyncProvider?>();
      final settings = context.read<SettingsProvider?>();
      final accounts = context.read<AccountsProvider>();
      final txs = context.read<TransactionsProvider>();

      if (inboxSync != null && (settings == null || settings.isGmailSyncEnabled)) {
        inboxSync.syncNow(
          geminiApiKey: settings?.geminiApiKey,
          bankSenders: settings?.bankSendersList,
          accountsProvider: accounts,
          transactionsProvider: txs,
        );
      }

      if (notifSync != null && notifSync.isPermissionGranted) {
        notifSync.syncPendingNotifications(
          geminiApiKey: settings?.geminiApiKey,
          accountRepository: AccountRepositoryImpl(),
          categoryRepository: CategoryRepositoryImpl(),
          transactionRepository: TransactionRepositoryImpl(),
          subscriptionRepository: SubscriptionRepositoryImpl(),
          accountsProvider: accounts,
          transactionsProvider: txs,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appLock = context.watch<AppLockProvider?>();
    if (appLock != null && appLock.isAppLocked) {
      return const AppLockScreen();
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n?.navDashboard ?? 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n?.navTransactions ?? 'Transactions',
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n?.navBudgets ?? 'Budgets',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n?.navSubscriptions ?? 'Subscriptions',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n?.navAccounts ?? 'Accounts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              tooltip: l10n?.quickTransaction ?? 'Quick Transaction',
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
