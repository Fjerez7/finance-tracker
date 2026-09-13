import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/cloud_backup_info.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/backup_provider.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscriptions_provider.dart';
import '../../../providers/transactions_provider.dart';

/// Screen managing hybrid cloud backups (Firestore & Drive), native CSV/JSON sharing, and local database restore.
class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final backupProv = context.watch<BackupProvider>();
    final txProv = context.watch<TransactionsProvider>();
    final accountsProv = context.watch<AccountsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupAndExport),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Status and Feedback Banners
          if (backupProv.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      backupProv.errorMessage!,
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => backupProv.clearStatus(),
                  ),
                ],
              ),
            ),
          ],
          if (backupProv.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      backupProv.successMessage!,
                      style: TextStyle(color: Colors.green.shade900, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => backupProv.clearStatus(),
                  ),
                ],
              ),
            ),
          ],

          // 2. Hybrid Cloud Backup (Firestore + Google Drive) Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_sync_outlined,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dualCloudBackup,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              backupProv.isSignedIn
                                  ? (backupProv.currentUser?.email ?? l10n.connected)
                                  : l10n.dualCloudBackupDesc,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Destination Pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                        label: Text(l10n.firestoreCloudBackup, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.orange.shade50,
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        avatar: const Icon(Icons.drive_folder_upload, size: 16, color: Colors.blue),
                        label: Text(l10n.googleDriveBackupLabel, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.blue.shade50,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (backupProv.isSignedIn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: backupProv.isSyncing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.backup_outlined, size: 18),
                            label: Text(
                              backupProv.isSyncing ? l10n.backingUp : l10n.backUpNow,
                            ),
                            onPressed: backupProv.isSyncing
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final ok = await backupProv.createCloudBackup();
                                    if (ok && mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.cloudBackupCreatedSuccess),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => backupProv.signOut(),
                          child: Text(l10n.signOut),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.availableCloudBackups,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: () => backupProv.fetchCloudBackups(),
                        ),
                      ],
                    ),
                    if (backupProv.cloudBackups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            l10n.noCloudBackupsFound,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      ...backupProv.cloudBackups.map(
                        (b) => _buildCloudBackupTile(context, b),
                      ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.login),
                        label: Text(l10n.signInWithGoogle),
                        onPressed: backupProv.isLoading
                            ? null
                            : () async {
                                await backupProv.signIn();
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Local Native File Exports & Sharing
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                // CSV Export (Excel)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.table_chart_outlined,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    l10n.shareCsv,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.shareCsvDesc(txProv.transactions.length),
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: const Icon(Icons.share_outlined),
                  onTap: () async {
                    await backupProv.shareTransactionsCsv(
                      transactions: txProv.transactions,
                      accounts: accountsProv.accounts,
                      categories: txProv.categories,
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // JSON Snapshot Export
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.data_object_outlined,
                      color: Colors.purple.shade700,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    l10n.shareJson,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.shareJsonDesc,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: const Icon(Icons.share_outlined),
                  onTap: () async {
                    await backupProv.shareDatabaseJson();
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Local JSON File Restore
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.file_open_outlined,
                      color: Colors.teal.shade700,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    l10n.pickLocalJson,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.pickLocalJsonDesc,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: const Icon(Icons.folder_open),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.restoreLocalBackupQuestion),
                        content: Text(l10n.confirmRestoreLocalBackupDetail),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(l10n.cancel),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(l10n.restoreData),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      final ok = await backupProv.pickAndRestoreLocalJson();
                      if (ok && context.mounted) {
                        await Future.wait([
                          context.read<SettingsProvider>().loadSettings(),
                          context.read<AccountsProvider>().loadAccounts(),
                          context.read<TransactionsProvider>().fetchTransactions(),
                          context.read<SubscriptionsProvider>().loadSubscriptions(),
                          context.read<BudgetsProvider>().loadBudgetsForSelectedPeriod(),
                        ]);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.localRestoreSuccess),
                              backgroundColor: Colors.green.shade800,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCloudBackupTile(BuildContext context, CloudBackupInfo backup) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(backup.modifiedTime);
    final isFirestore = backup.destination == CloudBackupDestination.firestore;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isFirestore ? Icons.local_fire_department : Icons.drive_folder_upload,
            size: 20,
            color: isFirestore ? Colors.orange.shade800 : Colors.blue.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        backup.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isFirestore ? Colors.orange.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isFirestore ? 'Firestore' : 'Drive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFirestore ? Colors.orange.shade900 : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: () => _confirmRestore(context, backup),
            child: Text(l10n.restore, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore(BuildContext context, CloudBackupInfo backup) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreCloudBackupQuestion),
        content: Text(
          l10n.confirmRestoreCloudBackupDetail(backup.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.restoreData),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final backupProv = context.read<BackupProvider>();
      final ok = await backupProv.restoreCloudBackup(backup);
      if (ok && context.mounted) {
        // Refresh all local providers
        await Future.wait([
          context.read<SettingsProvider>().loadSettings(),
          context.read<AccountsProvider>().loadAccounts(),
          context.read<TransactionsProvider>().fetchTransactions(),
          context.read<SubscriptionsProvider>().loadSubscriptions(),
          context.read<BudgetsProvider>().loadBudgetsForSelectedPeriod(),
        ]);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(backupProv.successMessage ?? l10n.localRestoreSuccess),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
      }
    }
  }
}
