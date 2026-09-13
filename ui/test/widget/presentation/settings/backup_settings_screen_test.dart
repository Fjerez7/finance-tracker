import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/budget.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/cloud_backup_info.dart';
import 'package:finance_tracker/domain/entities/savings_goal.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/domain/repositories/budget_repository.dart';
import 'package:finance_tracker/domain/repositories/category_repository.dart';
import 'package:finance_tracker/domain/repositories/savings_goal_repository.dart';
import 'package:finance_tracker/domain/repositories/subscription_repository.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/settings/backup_settings_screen.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';
import 'package:finance_tracker/providers/backup_provider.dart';
import 'package:finance_tracker/providers/budgets_provider.dart';
import 'package:finance_tracker/providers/subscriptions_provider.dart';
import 'package:finance_tracker/providers/transactions_provider.dart';
import 'package:finance_tracker/services/cloud_backup_service.dart';
import 'package:finance_tracker/services/file_export_service.dart';
import 'package:finance_tracker/services/google_drive_service.dart';

class FakeDriveService extends GoogleDriveService {
  GoogleSignInAccount? fakeUser;

  @override
  GoogleSignInAccount? get currentUser => fakeUser;

  @override
  Future<GoogleSignInAccount?> signIn() async => fakeUser;

  @override
  Future<GoogleSignInAccount?> signInSilently() async => fakeUser;

  @override
  Future<void> signOut() async {
    fakeUser = null;
  }
}

class FakeCloudBackupService implements CloudBackupService {
  final List<CloudBackupInfo> backups = [
    CloudBackupInfo(
      id: 'b-1',
      name: 'finance_tracker_backup_20260905_120000.json',
      destination: CloudBackupDestination.all,
      modifiedTime: DateTime(2026, 9, 5, 12, 0),
      sizeBytes: 1024,
      checksum: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ),
  ];

  @override
  Future<List<CloudBackupInfo>> listBackups({
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  }) async => List.from(backups);

  @override
  Future<String> downloadBackup({
    required String backupId,
    required CloudBackupDestination destination,
    String? userId,
  }) async => '{"version": 1}';

  @override
  Future<List<CloudBackupInfo>> uploadBackup({
    required String backupJson,
    required String filename,
    required String checksum,
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  }) async => List.from(backups);

  @override
  Future<void> deleteBackup({
    required String backupId,
    required CloudBackupDestination destination,
    String? userId,
  }) async {
    backups.removeWhere((b) => b.id == backupId);
  }
}

class FakeFileExportService extends FileExportService {
  bool shareCsvCalled = false;
  bool shareJsonCalled = false;
  String? pickedContent;

  @override
  Future<void> shareCsv({
    required String csvContent,
    required String filename,
    String? subject,
  }) async {
    shareCsvCalled = true;
  }

  @override
  Future<void> shareJson({
    required String jsonContent,
    required String filename,
    String? subject,
  }) async {
    shareJsonCalled = true;
  }

  @override
  Future<String?> pickLocalJsonBackup() async => pickedContent;
}

class FakeAccountRepo implements AccountRepository {
  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async => [];
  @override
  Future<Account?> getAccountById(String id) async => null;
  @override
  Future<void> createAccount(Account account) async {}
  @override
  Future<void> updateAccount(Account account) async {}
  @override
  Future<void> deleteAccount(String id) async {}
  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {}
  @override
  Future<void> setArchived(String id, bool isArchived) async {}
}

class FakeTxRepo implements TransactionRepository {
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
  }) async => [];
  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 20}) async => [];
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
  }) async => 0;
}

class FakeCatRepo implements CategoryRepository {
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

class FakeSubRepo implements SubscriptionRepository {
  @override
  Future<List<Subscription>> getSubscriptions({
    String? accountId,
    String? categoryId,
    bool? isActive,
  }) async => [];
  @override
  Future<Subscription?> getSubscriptionById(String id) async => null;
  @override
  Future<void> createSubscription(Subscription subscription) async {}
  @override
  Future<void> updateSubscription(Subscription subscription) async {}
  @override
  Future<void> deleteSubscription(String id) async {}
  @override
  Future<void> toggleActive(String id, bool isActive) async {}
  @override
  Future<void> updateNextDueDate(String id, DateTime nextDueDate) async {}
}

class FakeBudgetRepo implements BudgetRepository {
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

class FakeGoalRepo implements SavingsGoalRepository {
  @override
  Future<List<SavingsGoal>> getSavingsGoals({bool? isCompleted}) async => [];
  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async => null;
  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async {}
  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {}
  @override
  Future<void> deleteSavingsGoal(String id) async {}
  @override
  Future<void> adjustCurrentAmount(String id, int newCurrentAmountCents) async {}
}

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late FakeDriveService fakeDriveService;
  late FakeCloudBackupService fakeCloudBackupService;
  late FakeFileExportService fakeFileExportService;
  late BackupProvider backupProv;
  late AccountsProvider accountsProv;
  late TransactionsProvider txProv;
  late SubscriptionsProvider subsProv;
  late BudgetsProvider budgetsProv;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    await dbHelper.database;

    fakeDriveService = FakeDriveService();
    fakeCloudBackupService = FakeCloudBackupService();
    fakeFileExportService = FakeFileExportService();

    backupProv = BackupProvider(
      dbHelper: dbHelper,
      driveService: fakeDriveService,
      cloudBackupService: fakeCloudBackupService,
      fileExportService: fakeFileExportService,
    );

    accountsProv = AccountsProvider(repository: FakeAccountRepo());
    txProv = TransactionsProvider(
      transactionRepository: FakeTxRepo(),
      categoryRepository: FakeCatRepo(),
    );
    subsProv = SubscriptionsProvider(repository: FakeSubRepo());
    budgetsProv = BudgetsProvider(
      budgetRepository: FakeBudgetRepo(),
      savingsGoalRepository: FakeGoalRepo(),
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BackupProvider>.value(value: backupProv),
        ChangeNotifierProvider<AccountsProvider>.value(value: accountsProv),
        ChangeNotifierProvider<TransactionsProvider>.value(value: txProv),
        ChangeNotifierProvider<SubscriptionsProvider>.value(value: subsProv),
        ChangeNotifierProvider<BudgetsProvider>.value(value: budgetsProv),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BackupSettingsScreen(),
      ),
    );
  }

  group('BackupSettingsScreen Widget Tests', () {
    testWidgets('renders Dual Cloud Backup card, export & share tiles, and local restore tile when signed out', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Backup & Export'), findsOneWidget);
      expect(find.text('Dual Cloud Backup (Firestore + Drive)'), findsOneWidget);
      expect(find.text('Firebase Firestore'), findsOneWidget);
      expect(find.text('Google Drive'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Export & Share CSV (Excel)'), findsOneWidget);
      expect(find.text('Export & Share JSON Snapshot'), findsOneWidget);
      expect(find.text('Restore from Local File (.json)'), findsOneWidget);
    });

    testWidgets('tapping CSV export triggers native share service', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export & Share CSV (Excel)'));
      await tester.pumpAndSettle();

      expect(fakeFileExportService.shareCsvCalled, isTrue);
    });

    testWidgets('tapping JSON snapshot triggers native share service', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.text('Export & Share JSON Snapshot'));
        await Future.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();

      expect(fakeFileExportService.shareJsonCalled, isTrue);
    });

    testWidgets('tapping local file restore opens confirmation dialog and can be cancelled', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from Local File (.json)'));
      await tester.pumpAndSettle();

      expect(find.text('Restore Local Backup File?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Restore Local Backup File?'), findsNothing);
    });
  });
}
