import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/inbox_sync_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transactions_provider.dart';

/// Screen allowing configuration and execution of client-side Gmail bank notification sync.
class GmailSyncSettingsScreen extends StatefulWidget {
  const GmailSyncSettingsScreen({super.key});

  @override
  State<GmailSyncSettingsScreen> createState() => _GmailSyncSettingsScreenState();
}

class _GmailSyncSettingsScreenState extends State<GmailSyncSettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _sendersController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyController = TextEditingController(text: settings.geminiApiKey);
    _sendersController = TextEditingController(text: settings.bankSenders);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _sendersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final inboxSync = context.watch<InboxSyncProvider>();
    final accountsProv = context.watch<AccountsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gmailBankSync),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Google Account Connection Card
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
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mail_outline,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.googleAccount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              inboxSync.isGoogleSignedIn
                                  ? l10n.googleAccountConnected(
                                      inboxSync.googleUserEmail ?? l10n.connected,
                                    )
                                  : l10n.notConnected,
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
                  if (inboxSync.isGoogleSignedIn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.logout, size: 18),
                            label: Text(l10n.signOut),
                            onPressed: () => inboxSync.disconnectGoogle(),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.login),
                        label: Text(l10n.signInWithGoogle),
                        onPressed: () async {
                          final ok = await inboxSync.connectGoogle();
                          if (!ok && context.mounted && inboxSync.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(inboxSync.errorMessage!),
                                backgroundColor: Colors.red.shade800,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Gemini AI Extraction Settings Card
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
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.purple.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.geminiApiKey,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.geminiApiKeyDesc,
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
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      labelText: l10n.enterGeminiApiKey,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.geminiApiKeyHelper,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.save, size: 18),
                      label: Text(l10n.save),
                      onPressed: () async {
                        await settings.setGeminiApiKey(_apiKeyController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.apiKeySaved)),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Monitored Bank Senders Card
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
                          Icons.filter_list,
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
                              l10n.bankSenders,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.bankSendersDesc,
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
                  TextField(
                    controller: _sendersController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _sendersController.text = SettingsProvider.defaultBankSenders;
                          settings.setBankSenders(SettingsProvider.defaultBankSenders);
                        },
                        child: Text(l10n.restoreDefaultSenders),
                      ),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.save, size: 18),
                        label: Text(l10n.save),
                        onPressed: () async {
                          await settings.setBankSenders(_sendersController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.bankSendersSaved)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Background Auto-Sync Switch Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: SwitchListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                l10n.enableAutoSync,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                l10n.enableAutoSyncDesc,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              value: settings.isGmailSyncEnabled,
              onChanged: (val) => settings.setGmailSyncEnabled(val),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Manual Sync Action & Status Feedback
          if (inboxSync.lastSyncTime != null) ...[
            Center(
              child: Text(
                l10n.lastSyncTime(
                  DateFormat('yyyy-MM-dd HH:mm').format(inboxSync.lastSyncTime!),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: inboxSync.isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                inboxSync.isSyncing ? l10n.syncingGmail : l10n.syncNow,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: inboxSync.isSyncing
                  ? null
                  : () async {
                      if (!inboxSync.isGoogleSignedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.googleSignInRequired)),
                        );
                        return;
                      }
                      if (settings.geminiApiKey.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.geminiKeyRequired)),
                        );
                        return;
                      }

                      final count = await inboxSync.syncNow(
                        geminiApiKey: settings.geminiApiKey,
                        bankSenders: settings.bankSendersList,
                        accountsProvider: accountsProv,
                        transactionsProvider: txProv,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              count > 0 ? l10n.syncSuccess(count) : l10n.syncUpToDate,
                            ),
                          ),
                        );
                      }
                    },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
