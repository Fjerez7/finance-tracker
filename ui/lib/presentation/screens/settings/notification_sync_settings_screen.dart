import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../data/repositories/account_repository_impl.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/repositories/subscription_repository_impl.dart';
import '../../../data/repositories/transaction_repository_impl.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/notification_sync_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transactions_provider.dart';

/// Configuration screen for Android push notification banking synchronization and whitelist management.
class NotificationSyncSettingsScreen extends StatefulWidget {
  final AccountRepository? accountRepository;
  final CategoryRepository? categoryRepository;
  final TransactionRepository? transactionRepository;
  final SubscriptionRepository? subscriptionRepository;

  const NotificationSyncSettingsScreen({
    super.key,
    this.accountRepository,
    this.categoryRepository,
    this.transactionRepository,
    this.subscriptionRepository,
  });

  @override
  State<NotificationSyncSettingsScreen> createState() => _NotificationSyncSettingsScreenState();
}

class _NotificationSyncSettingsScreenState extends State<NotificationSyncSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSyncProvider>().checkPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationSyncProvider>().checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final notifSync = context.watch<NotificationSyncProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.notificationSync,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Android Permission Status Card
          _buildPermissionCard(context, notifSync, l10n, colorScheme),
          const SizedBox(height: 24),

          // 2. Monitored Banking Apps Whitelist Section
          _buildMonitoredBanksSection(context, notifSync, l10n, colorScheme),
          const SizedBox(height: 24),

          // 3. Manual Sync Action Card
          _buildSyncActionCard(context, notifSync, settings, l10n, colorScheme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    NotificationSyncProvider notifSync,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final isGranted = notifSync.isPermissionGranted;

    return Card(
      elevation: 0,
      color: isGranted
          ? Colors.green.shade50.withValues(alpha: 0.6)
          : Colors.amber.shade50.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isGranted ? Colors.green.shade200 : Colors.amber.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isGranted ? Colors.green.shade100 : Colors.amber.shade100,
                  child: Icon(
                    isGranted ? Icons.notifications_active : Icons.notification_important,
                    color: isGranted ? Colors.green.shade800 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notificationAccessStatus,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        isGranted ? l10n.notificationAccessGranted : l10n.notificationAccessDenied,
                        style: TextStyle(
                          color: isGranted ? Colors.green.shade800 : Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.grantNotificationAccessDesc,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (!isGranted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => notifSync.requestPermission(),
                  icon: const Icon(Icons.settings),
                  label: Text(l10n.grantNotificationAccess),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoredBanksSection(
    BuildContext context,
    NotificationSyncProvider notifSync,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.monitoredBanks,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddBankDialog(context, notifSync, l10n),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addBankApp),
            ),
          ],
        ),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < notifSync.monitoredApps.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 64),
                _buildBankAppTile(context, notifSync, notifSync.monitoredApps[i], colorScheme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankAppTile(
    BuildContext context,
    NotificationSyncProvider notifSync,
    dynamic app,
    ColorScheme colorScheme,
  ) {
    final isNubank = app.id == 'nubank';

    return SwitchListTile(
      secondary: CircleAvatar(
        backgroundColor: isNubank ? Colors.purple.shade100 : colorScheme.primaryContainer,
        child: Icon(
          Icons.account_balance_wallet,
          color: isNubank ? Colors.purple.shade800 : colorScheme.primary,
        ),
      ),
      title: Text(
        app.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        app.packageName,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      value: app.isEnabled,
      onChanged: (bool value) async {
        await notifSync.toggleBankApp(app.id, value);
      },
    );
  }

  Widget _buildSyncActionCard(
    BuildContext context,
    NotificationSyncProvider notifSync,
    SettingsProvider settings,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: notifSync.isSyncing
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final accounts = context.read<AccountsProvider>();
                        final txs = context.read<TransactionsProvider>();

                        final count = await notifSync.syncPendingNotifications(
                          geminiApiKey: settings.geminiApiKey,
                          accountRepository: widget.accountRepository ?? AccountRepositoryImpl(),
                          categoryRepository: widget.categoryRepository ?? CategoryRepositoryImpl(),
                          transactionRepository: widget.transactionRepository ?? TransactionRepositoryImpl(),
                          subscriptionRepository: widget.subscriptionRepository ?? SubscriptionRepositoryImpl(),
                          accountsProvider: accounts,
                          transactionsProvider: txs,
                        );

                        if (notifSync.errorMessage != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(notifSync.errorMessage!),
                              backgroundColor: Colors.red.shade800,
                            ),
                          );
                        } else if (count > 0) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l10n.notificationSyncSuccess(count)),
                              backgroundColor: Colors.green.shade800,
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.noPendingNotifications)),
                          );
                        }
                      },
                icon: notifSync.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  notifSync.isSyncing ? l10n.syncingNotifications : l10n.syncNotificationsNow,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (notifSync.lastSyncTime != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.lastSyncTime(
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(notifSync.lastSyncTime!.toLocal()),
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddBankDialog(
    BuildContext context,
    NotificationSyncProvider notifSync,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController();
    final pkgController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.addBankApp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.bankAppName,
                  hintText: 'e.g. Nequi, Lulo Bank',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pkgController,
                decoration: InputDecoration(
                  labelText: l10n.androidPackageName,
                  hintText: 'e.g. com.nequi.MobileApp',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final pkg = pkgController.text.trim();
                if (name.isNotEmpty && pkg.isNotEmpty) {
                  final success = await notifSync.addMonitoredBankApp(
                    displayName: name,
                    packageName: pkg,
                  );
                  if (context.mounted && success) {
                    Navigator.of(dialogCtx).pop();
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
