import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/backup_provider.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/subscriptions_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../services/google_drive_service.dart';

/// Screen allowing Google Drive cloud backups, CSV transaction exports, and JSON database restore.
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
    final backupProv = context.watch<BackupProvider>();
    final txProv = context.watch<TransactionsProvider>();
    final accountsProv = context.watch<AccountsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Export'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Feedback Snackbars / Status Banners
          if (backupProv.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                  const SizedBox(width: 8),
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

          // 1. Google Drive Cloud Backup Card
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
                            const Text(
                              'Google Drive Cloud Sync',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              backupProv.isSignedIn
                                  ? (backupProv.currentUser?.email ?? 'Connected')
                                  : 'Sync encrypted snapshots to private appDataFolder',
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
                              backupProv.isSyncing ? 'Backing up...' : 'Back Up Now',
                            ),
                            onPressed: backupProv.isSyncing
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final ok = await backupProv.createCloudBackup();
                                    if (ok && mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Cloud backup created successfully!'),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => backupProv.signOut(),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Cloud Backups',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: 'Refresh Backups',
                          onPressed: () => backupProv.fetchCloudBackups(),
                        ),
                      ],
                    ),
                    if (backupProv.cloudBackups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No cloud backups found',
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
                        label: const Text('Sign In with Google'),
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

          // 2. Local CSV Data Export Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
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
              title: const Text(
                'Export Ledger (CSV)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Export all ${txProv.transactions.length} transactions with account and category mappings',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.download),
              onTap: () {
                final csv = backupProv.exportTransactionsCsv(
                  transactions: txProv.transactions,
                  accounts: accountsProv.accounts,
                  categories: txProv.categories,
                );

                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('CSV Export Preview'),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          csv,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // 3. Local JSON Database Snapshot Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
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
              title: const Text(
                'Export Database Snapshot (JSON)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Full database dump with SHA-256 integrity checksum',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.code),
              onTap: () async {
                final snapshot = await backupProv.createLocalSnapshot();
                final jsonStr = jsonEncode(snapshot);

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Database Snapshot JSON'),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 300,
                        child: SingleChildScrollView(
                          child: SelectableText(
                            jsonStr,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudBackupTile(BuildContext context, DriveBackupInfo backup) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dateStr = backup.modifiedTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(backup.modifiedTime!)
        : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.history_outlined, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: () => _confirmRestore(context, backup),
            child: const Text('Restore', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore(BuildContext context, DriveBackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Cloud Backup?'),
        content: Text(
          'This will overwrite existing local data with the snapshot from ${backup.name}. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final backupProv = context.read<BackupProvider>();
      final ok = await backupProv.restoreCloudBackup(backup.id);
      if (ok && context.mounted) {
        // Refresh all local providers
        await Future.wait([
          context.read<AccountsProvider>().loadAccounts(),
          context.read<TransactionsProvider>().fetchTransactions(),
          context.read<SubscriptionsProvider>().loadSubscriptions(),
          context.read<BudgetsProvider>().loadBudgetsForSelectedPeriod(),
        ]);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database restored successfully from Google Drive!'),
            ),
          );
        }
      }
    }
  }
}
