import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_currency.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/exchange_rate_provider.dart';

/// Interactive card presenting currency conversion preview, live rates, and manual TRM override.
class CurrencyConversionCard extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final int amountCents;
  final double? customRate;
  final ValueChanged<double?> onCustomRateChanged;
  final bool isIncome;

  const CurrencyConversionCard({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amountCents,
    this.customRate,
    required this.onCustomRateChanged,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final exchangeProv = context.watch<ExchangeRateProvider>();

    final double effectiveRate = customRate ??
        exchangeProv.getRate(fromCurrency, toCurrency) ??
        1.0;

    final int convertedCents = exchangeProv.convertAmount(
      amountCents: amountCents,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      customRate: effectiveRate,
    );

    final toAppCurrency = AppCurrency.fromCode(toCurrency);

    final String convertedFormatted = CurrencyFormatter.formatCents(
      convertedCents,
      currency: toAppCurrency,
    );

    final String rateString = effectiveRate >= 100
        ? effectiveRate.toStringAsFixed(2)
        : effectiveRate.toStringAsFixed(4);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: customRate != null
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_exchange,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.currencyConversion,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (exchangeProv.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: l10n.refreshRateTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    exchangeProv.fetchRates(
                      baseCurrency: fromCurrency,
                      force: true,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rate Indicator & Edit Button
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showEditRateDialog(context, effectiveRate),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        l10n.rateUnitFormat(
                          fromCurrency.toUpperCase(),
                          rateString,
                          toCurrency.toUpperCase(),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              if (customRate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.customRate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isIncome ? l10n.creditedAmount : l10n.debitedAmount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                convertedFormatted,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditRateDialog(BuildContext context, double currentRate) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentRate.toString());

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.editExchangeRate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1 $fromCurrency = ? $toCurrency',
                style: Theme.of(dialogCtx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.exchangeRate,
                  hintText: l10n.ratePlaceholder,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            if (customRate != null)
              TextButton(
                onPressed: () {
                  onCustomRateChanged(null);
                  Navigator.of(dialogCtx).pop();
                },
                child: Text(l10n.resetRate),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.replaceAll(',', '.').trim();
                final parsed = double.tryParse(text);
                if (parsed != null && parsed > 0) {
                  onCustomRateChanged(parsed);
                }
                Navigator.of(dialogCtx).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
