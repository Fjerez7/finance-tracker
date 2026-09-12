import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_currency.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import 'backup_settings_screen.dart';

/// Screen presenting user preferences (Language, Currency), Data options, and App info.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Preferences Section
          _buildSectionHeader(context, l10n.preferences),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Language Selection Tile
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.language, color: colorScheme.primary),
                  ),
                  title: Text(
                    l10n.language,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(_getLanguageLabel(settings.locale, l10n)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, settings),
                ),
                const Divider(height: 1, indent: 64),
                // Currency Selection Tile
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(Icons.attach_money, color: colorScheme.secondary),
                  ),
                  title: Text(
                    l10n.currency,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(_getCurrencyLabel(settings.currency, l10n)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCurrencyDialog(context, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Data & Storage Section
          _buildSectionHeader(context, l10n.dataAndStorage),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.tertiaryContainer,
                    child: Icon(Icons.cloud_sync_outlined, color: colorScheme.tertiary),
                  ),
                  title: Text(
                    l10n.cloudBackup,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(l10n.cloudBackupDesc),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BackupSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. About Section
          _buildSectionHeader(context, l10n.about),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.info_outline, color: colorScheme.primary),
                  ),
                  title: Text(
                    l10n.appTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(l10n.appDescription),
                ),
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.storage_outlined, color: colorScheme.onSurfaceVariant),
                  ),
                  title: Text(
                    l10n.databaseStatus,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(l10n.databaseStatusOk),
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getLanguageLabel(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.systemDefault;
    if (locale.languageCode == 'es') return l10n.spanish;
    if (locale.languageCode == 'en') return l10n.english;
    return locale.languageCode;
  }

  String _getCurrencyLabel(AppCurrency currency, AppLocalizations l10n) {
    switch (currency) {
      case AppCurrency.usd:
        return l10n.currencyUsd;
      case AppCurrency.cop:
        return l10n.currencyCop;
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                title: Text(l10n.systemDefault),
                value: null,
                groupValue: settings.locale?.languageCode,
                onChanged: (val) {
                  settings.setLocale(null);
                  Navigator.of(dialogCtx).pop();
                },
              ),
              RadioListTile<String?>(
                title: Text(l10n.spanish),
                value: 'es',
                groupValue: settings.locale?.languageCode,
                onChanged: (val) {
                  settings.setLocale(const Locale('es'));
                  Navigator.of(dialogCtx).pop();
                },
              ),
              RadioListTile<String?>(
                title: Text(l10n.english),
                value: 'en',
                groupValue: settings.locale?.languageCode,
                onChanged: (val) {
                  settings.setLocale(const Locale('en'));
                  Navigator.of(dialogCtx).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.selectCurrency),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppCurrency>(
                title: Text(l10n.currencyUsd),
                value: AppCurrency.usd,
                groupValue: settings.currency,
                onChanged: (val) {
                  if (val != null) {
                    settings.setCurrency(val);
                  }
                  Navigator.of(dialogCtx).pop();
                },
              ),
              RadioListTile<AppCurrency>(
                title: Text(l10n.currencyCop),
                value: AppCurrency.cop,
                groupValue: settings.currency,
                onChanged: (val) {
                  if (val != null) {
                    settings.setCurrency(val);
                  }
                  Navigator.of(dialogCtx).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}
