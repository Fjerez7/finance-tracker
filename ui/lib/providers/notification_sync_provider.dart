import 'package:flutter/material.dart';
import '../data/datasources/local/database_helper.dart';
import '../data/models/inbox_transaction_model.dart';
import '../data/models/monitored_bank_app_model.dart';
import '../data/models/pending_bank_notification_model.dart';
import '../domain/entities/account.dart';
import '../domain/entities/category.dart';
import '../domain/entities/monitored_bank_app.dart';
import '../domain/entities/subscription.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/subscription_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../services/gemini_extraction_service.dart';
import '../services/notification_bridge_service.dart';
import 'accounts_provider.dart';
import 'subscriptions_provider.dart';
import 'transactions_provider.dart';

/// Provider managing real-time and buffered banking push notification synchronization.
class NotificationSyncProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final NotificationBridgeService _bridgeService;
  final GeminiExtractionService _geminiService;

  bool _isInitialized = false;
  bool _isPermissionGranted = false;
  bool _isSyncing = false;
  List<MonitoredBankApp> _monitoredApps = [];
  List<PendingBankNotification> _pendingNotifications = [];
  int _lastSyncCount = 0;
  DateTime? _lastSyncTime;
  String? _errorMessage;

  NotificationSyncProvider({
    DatabaseHelper? dbHelper,
    NotificationBridgeService? bridgeService,
    GeminiExtractionService? geminiService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _bridgeService = bridgeService ?? NotificationBridgeService(),
        _geminiService = geminiService ?? GeminiExtractionServiceImpl();

  bool get isInitialized => _isInitialized;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isSyncing => _isSyncing;
  List<MonitoredBankApp> get monitoredApps => List.unmodifiable(_monitoredApps);
  List<MonitoredBankApp> get activeApps => _monitoredApps.where((a) => a.isEnabled).toList();
  List<PendingBankNotification> get pendingNotifications => List.unmodifiable(_pendingNotifications);
  int get lastSyncCount => _lastSyncCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;

  /// Initializes permission status, loads whitelist from SQLite, and flushes initial native buffer.
  Future<void> initialize() async {
    try {
      _isPermissionGranted = await _bridgeService.isNotificationAccessGranted();
      await _loadMonitoredApps();
      await _syncActivePackagesToNative();
      _bridgeService.setNotificationReceivedHandler(_handleRealtimeNotification);
      await _fetchAndBufferNativeNotifications();
      await _loadPendingNotifications();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationSyncProvider.initialize error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Checks and updates Android Notification Access permission status.
  Future<void> checkPermission() async {
    final granted = await _bridgeService.isNotificationAccessGranted();
    if (granted != _isPermissionGranted) {
      _isPermissionGranted = granted;
      notifyListeners();
    }
  }

  /// Requests the operating system to open Notification Access settings.
  Future<void> requestPermission() async {
    await _bridgeService.requestNotificationAccess();
  }

  /// Loads monitored bank apps from SQLite database.
  Future<void> _loadMonitoredApps() async {
    final rawList = await _dbHelper.getMonitoredBankApps();
    if (rawList.isEmpty) {
      // Seed Nubank by default if none exist
      final defaultNu = MonitoredBankApp(
        id: 'nubank',
        packageName: 'com.nu.production',
        displayName: 'Nubank',
        isEnabled: true,
        createdAt: DateTime.now().toUtc(),
      );
      await _dbHelper.insertMonitoredBankApp(MonitoredBankAppModel.fromEntity(defaultNu).toMap());
      _monitoredApps = [defaultNu];
    } else {
      _monitoredApps = rawList.map((m) => MonitoredBankAppModel.fromMap(m).toEntity()).toList();
    }
  }

  /// Syncs active package names to native SharedPreferences for instant background dropping.
  Future<void> _syncActivePackagesToNative() async {
    final activePackages = activeApps.map((a) => a.packageName).toList();
    await _bridgeService.syncMonitoredPackages(activePackages);
  }

  /// Toggles a monitored bank app on or off.
  Future<void> toggleBankApp(String id, bool isEnabled) async {
    final index = _monitoredApps.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final updated = _monitoredApps[index].copyWith(isEnabled: isEnabled);
    _monitoredApps[index] = updated;
    notifyListeners();
    await _dbHelper.updateMonitoredBankApp(id, {'is_enabled': isEnabled ? 1 : 0});
    await _syncActivePackagesToNative();
  }

  /// Registers a new monitored bank application.
  Future<bool> addMonitoredBankApp({
    required String displayName,
    required String packageName,
  }) async {
    final cleanPkg = packageName.trim();
    final cleanName = displayName.trim();

    if (cleanPkg.isEmpty || cleanName.isEmpty) return false;

    // Prevent duplicates
    if (_monitoredApps.any((a) => a.packageName == cleanPkg)) {
      _errorMessage = 'Package "$cleanPkg" is already registered';
      notifyListeners();
      return false;
    }

    final newApp = MonitoredBankApp(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      packageName: cleanPkg,
      displayName: cleanName,
      isEnabled: true,
      createdAt: DateTime.now().toUtc(),
    );

    _monitoredApps.add(newApp);
    await _dbHelper.insertMonitoredBankApp(MonitoredBankAppModel.fromEntity(newApp).toMap());
    await _syncActivePackagesToNative();
    notifyListeners();
    return true;
  }

  /// Removes a monitored bank application from the registry.
  Future<void> deleteMonitoredBankApp(String id) async {
    _monitoredApps.removeWhere((a) => a.id == id);
    await _dbHelper.deleteMonitoredBankApp(id);
    await _syncActivePackagesToNative();
    notifyListeners();
  }

  /// Loads pending notifications from SQLite buffer.
  Future<void> _loadPendingNotifications() async {
    final raw = await _dbHelper.getPendingBankNotifications(unprocessedOnly: true);
    _pendingNotifications = raw.map((m) => PendingBankNotification.fromMap(m)).toList();
  }

  /// Fetches native notifications from SharedPreferences buffer and saves to SQLite.
  Future<void> _fetchAndBufferNativeNotifications() async {
    final rawList = await _bridgeService.getBufferedNotifications();
    if (rawList.isEmpty) return;

    for (final notif in rawList) {
      final String pkg = notif['packageName']?.toString() ?? '';
      final String key = notif['notificationKey']?.toString() ?? '';
      final String title = notif['title']?.toString() ?? '';
      final String body = notif['body']?.toString() ?? '';
      final int postTime = int.tryParse(notif['postTime']?.toString() ?? '0') ??
          DateTime.now().millisecondsSinceEpoch;

      if (key.isNotEmpty && (body.isNotEmpty || title.isNotEmpty)) {
        await _dbHelper.insertPendingBankNotification({
          'id': 'pnotif_${DateTime.now().millisecondsSinceEpoch}_${key.hashCode.abs()}',
          'package_name': pkg,
          'notification_key': key,
          'title': title,
          'body': body,
          'post_time': postTime,
          'is_processed': 0,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    }
  }

  /// Handles real-time push notification delivered while Flutter is in foreground.
  void _handleRealtimeNotification(Map<String, dynamic> notif) async {
    try {
      final String pkg = notif['packageName']?.toString() ?? '';
      final String key = notif['notificationKey']?.toString() ?? '';
      final String title = notif['title']?.toString() ?? '';
      final String body = notif['body']?.toString() ?? '';
      final int postTime = int.tryParse(notif['postTime']?.toString() ?? '0') ??
          DateTime.now().millisecondsSinceEpoch;

      if (key.isNotEmpty && (body.isNotEmpty || title.isNotEmpty)) {
        await _dbHelper.insertPendingBankNotification({
          'id': 'pnotif_${DateTime.now().millisecondsSinceEpoch}_${key.hashCode.abs()}',
          'package_name': pkg,
          'notification_key': key,
          'title': title,
          'body': body,
          'post_time': postTime,
          'is_processed': 0,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
        await _loadPendingNotifications();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('NotificationSyncProvider _handleRealtimeNotification error: $e');
    }
  }

  /// Synchronizes pending buffered notifications through Gemini extraction and saves to SQLite transactions.
  Future<int> syncPendingNotifications({
    required String? geminiApiKey,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required TransactionRepository transactionRepository,
    SubscriptionRepository? subscriptionRepository,
    AccountsProvider? accountsProvider,
    TransactionsProvider? transactionsProvider,
  }) async {
    if (_isSyncing) return 0;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Flush any pending notifications from native Android layer
      await _fetchAndBufferNativeNotifications();
      await _loadPendingNotifications();

      if (_pendingNotifications.isEmpty) {
        _isSyncing = false;
        _lastSyncCount = 0;
        _lastSyncTime = DateTime.now();
        notifyListeners();
        return 0;
      }

      if (geminiApiKey == null || geminiApiKey.trim().isEmpty) {
        _errorMessage = 'Gemini API Key is required to extract bank transactions.';
        _isSyncing = false;
        notifyListeners();
        return 0;
      }

      final List<Account> accounts = await accountRepository.getAccounts(includeArchived: false);
      final List<Category> categories = await categoryRepository.getCategories();
      final List<Subscription> activeSubscriptions =
          await subscriptionRepository?.getSubscriptions(isActive: true) ?? [];

      int syncedCount = 0;

      for (final notif in _pendingNotifications) {
        final cleanKey = notif.notificationKey.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
        final localTxId = 'tx_notif_$cleanKey';

        // Check if already in SQLite
        final existing = await transactionRepository.getTransactionById(localTxId);
        if (existing != null) {
          await _dbHelper.markPendingBankNotificationProcessed(notif.id);
          syncedCount++;
          continue;
        }

        try {
          final notifDate = DateTime.fromMillisecondsSinceEpoch(notif.postTime, isUtc: true);
          final InboxTransactionModel? extracted = await _geminiService.extractTransaction(
            emailBody: notif.body,
            emailSubject: notif.title ?? '',
            sender: notif.packageName,
            emailDate: notifDate,
            messageId: notif.notificationKey,
            apiKey: geminiApiKey,
          );

          if (extracted == null) {
            // Non-transactional notification (e.g. statement ready or promotion)
            await _dbHelper.markPendingBankNotificationProcessed(notif.id);
            continue;
          }

          // Resolve matching Account
          final Account? matchedAccount = _matchAccount(extracted, accounts);
          if (matchedAccount == null) {
            // No matching account, still mark processed to prevent infinite looping
            await _dbHelper.markPendingBankNotificationProcessed(notif.id);
            continue;
          }

          // Resolve matching Category
          final Category matchedCategory = _matchCategory(extracted, categories);

          // Check subscription match
          Subscription? matchedSub;
          for (final sub in activeSubscriptions) {
            final double ratio = (sub.amountCents - extracted.amount).abs() / sub.amountCents;
            if (ratio <= 0.15 &&
                extracted.merchant.toLowerCase().contains(sub.name.toLowerCase())) {
              matchedSub = sub;
              break;
            }
          }

          final TransactionType txType;
          switch (extracted.type.toLowerCase()) {
            case 'income':
              txType = TransactionType.income;
              break;
            case 'transfer':
              txType = TransactionType.transfer;
              break;
            case 'expense':
            default:
              txType = TransactionType.expense;
              break;
          }

          final newTx = Transaction(
            id: localTxId,
            accountId: matchedAccount.id,
            categoryId: matchedCategory.id,
            amountCents: extracted.amountCents,
            originalCurrency: extracted.currency.toUpperCase(),
            type: txType,
            description: extracted.merchant.isNotEmpty ? extracted.merchant : (notif.title ?? 'Bank Notification'),
            transactionDate: notifDate,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          );

          await transactionRepository.createTransaction(newTx);

          if (matchedSub != null && subscriptionRepository != null) {
            try {
              final DateTime nextDue = SubscriptionsProvider.calculateNextDueDate(
                matchedSub.nextDueDate,
                matchedSub.frequency,
                billingDay: matchedSub.billingDay,
              );
              await subscriptionRepository.updateNextDueDate(matchedSub.id, nextDue);
            } catch (_) {}
          }

          await _dbHelper.markPendingBankNotificationProcessed(notif.id);
          syncedCount++;
        } catch (e) {
          debugPrint('NotificationSyncProvider error processing notification ${notif.id}: $e');
        }
      }

      await _loadPendingNotifications();
      _lastSyncCount = syncedCount;
      _lastSyncTime = DateTime.now();

      if (accountsProvider != null) {
        await accountsProvider.loadAccounts();
      }
      if (transactionsProvider != null) {
        await transactionsProvider.fetchTransactions();
      }

      return syncedCount;
    } catch (e) {
      _errorMessage = 'Notification sync error: $e';
      return 0;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Matches extracted transaction with local user account.
  Account? _matchAccount(InboxTransactionModel item, List<Account> accounts) {
    if (accounts.isEmpty) return null;

    final String digitsOnly = item.accountMask.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 2) {
      for (final Account acc in accounts) {
        if (acc.name.contains(digitsOnly)) {
          return acc;
        }
      }
    }

    final String bankRaw = item.bankName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final bool isCredit = item.accountType == 'credit_card';

    // Check brand matching with Nu / Nubank / neobanks
    for (final Account acc in accounts) {
      final String accNorm = acc.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (accNorm.contains('nu') || bankRaw.contains('nu') || accNorm.contains(bankRaw) || bankRaw.contains(accNorm)) {
        if (isCredit && acc.type == AccountType.creditCard) {
          return acc;
        }
        if (!isCredit && acc.type != AccountType.creditCard) {
          return acc;
        }
      }
    }

    // Fallback: If credit card transaction and user only has 1 credit card account
    if (isCredit) {
      final creditCards = accounts.where((a) => a.type == AccountType.creditCard).toList();
      if (creditCards.length == 1) {
        return creditCards.first;
      }
    }

    // No registered account matched (e.g. debit transaction with no registered debit account)
    return null;
  }

  /// Matches or falls back category.
  Category _matchCategory(InboxTransactionModel item, List<Category> categories) {
    final String target = item.categorySuggestion.toLowerCase().trim();
    for (final cat in categories) {
      if (cat.name.toLowerCase().trim() == target) {
        return cat;
      }
    }
    return categories.firstWhere(
      (c) => c.type == CategoryType.expense,
      orElse: () => categories.first,
    );
  }

  /// Clears active error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
