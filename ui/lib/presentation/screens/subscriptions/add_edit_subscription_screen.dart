import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_currency.dart';
import '../../../core/utils/category_localization_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/subscription.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/subscriptions_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/cards/currency_conversion_card.dart';

/// Screen for creating and editing recurring commitments / subscriptions.
class AddEditSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;

  const AddEditSubscriptionScreen({super.key, this.subscription});

  bool get isEditing => subscription != null;

  @override
  State<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late RecurrenceFrequency _frequency;
  late String _selectedCurrency;
  double? _customRate;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  late DateTime _nextDueDate;
  late int _billingDay;
  late bool _autoRegister;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;

    _nameController = TextEditingController(text: sub?.name ?? '');
    _amountController = TextEditingController(
      text:
          sub != null
              ? (sub.amountCents / 100.0).toStringAsFixed(2)
              : '',
    );
    _frequency = sub?.frequency ?? RecurrenceFrequency.monthly;
    _selectedCurrency = sub?.currency ?? CurrencyFormatter.defaultCurrency.code;
    _selectedAccountId = sub?.accountId;
    _selectedCategoryId = sub?.categoryId;
    _nextDueDate = sub?.nextDueDate ?? DateTime.now().add(const Duration(days: 7));
    _billingDay = sub?.billingDay ?? _nextDueDate.day;
    _autoRegister = sub?.autoRegister ?? false;
    _isActive = sub?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final accountsProv = context.watch<AccountsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    final accounts = accountsProv.accounts.where((a) => !a.isArchived).toList();
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final categories = txProv.expenseCategories;
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.editSubscription : l10n.addSubscription,
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              tooltip: l10n.delete,
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Service Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.serviceName,
                hintText: l10n.serviceNameHint,
                prefixIcon: const Icon(Icons.subscriptions_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.pleaseEnterServiceName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount & Currency Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.periodicAmount,
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return l10n.pleaseEnterPeriodicAmount;
                      }
                      final cents = CurrencyFormatter.parseToCents(
                        val,
                        currency: AppCurrency.fromCode(_selectedCurrency),
                      );
                      if (cents <= 0) {
                        return l10n.limitMustBeGreaterThanZero;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'COP', child: Text('COP')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCurrency = val;
                          _customRate = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frequency Dropdown
            DropdownButtonFormField<RecurrenceFrequency>(
              value: _frequency,
              decoration: InputDecoration(
                labelText: l10n.billingFrequency,
                prefixIcon: const Icon(Icons.repeat),
                border: const OutlineInputBorder(),
              ),
              items:
                  RecurrenceFrequency.values.map((freq) {
                    final String label;
                    switch (freq) {
                      case RecurrenceFrequency.monthly:
                        label = l10n.freqMonthly;
                        break;
                      case RecurrenceFrequency.weekly:
                        label = l10n.freqWeekly;
                        break;
                      case RecurrenceFrequency.biweekly:
                        label = l10n.freqBiweekly;
                        break;
                      case RecurrenceFrequency.annual:
                        label = l10n.freqAnnual;
                        break;
                    }
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(label),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _frequency = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Account Dropdown
            DropdownButtonFormField<String>(
              value: _selectedAccountId,
              decoration: InputDecoration(
                labelText: l10n.accountToDebit,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: const OutlineInputBorder(),
              ),
              items:
                  accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text(acc.name),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedAccountId = val;
                });
              },
              validator: (val) => val == null ? l10n.pleaseSelectAccount : null,
            ),
            if (_selectedAccountId != null) ...[
              () {
                final acc = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
                final accCurrency = acc?.currency ?? 'USD';
                if (_selectedCurrency != accCurrency) {
                  final amountCents = CurrencyFormatter.parseToCents(_amountController.text);
                  return CurrencyConversionCard(
                    fromCurrency: _selectedCurrency,
                    toCurrency: accCurrency,
                    amountCents: amountCents,
                    customRate: _customRate,
                    onCustomRateChanged: (rate) {
                      setState(() {
                        _customRate = rate;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              }(),
            ],
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: l10n.category,
                prefixIcon: const Icon(Icons.category_outlined),
                border: const OutlineInputBorder(),
              ),
              items:
                  categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(
                        CategoryLocalizationHelper.getLocalizedName(
                          context,
                          categoryId: cat.id,
                          defaultName: cat.name,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategoryId = val;
                });
              },
              validator: (val) => val == null ? l10n.pleaseSelectCategory : null,
            ),
            const SizedBox(height: 16),

            // Next Due Date & Billing Day Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.nextDueDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy', locale).format(
                                _nextDueDate,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: Text(l10n.edit),
                          onPressed: _pickDueDate,
                        ),
                      ],
                    ),
                    if (_frequency == RecurrenceFrequency.monthly) ...[
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.monthlyBillingDay,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          DropdownButton<int>(
                            value: _billingDay,
                            items:
                                List.generate(31, (i) => i + 1).map((day) {
                                  return DropdownMenuItem(
                                    value: day,
                                    child: Text(l10n.billingDayNumber(day)),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _billingDay = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Automation & Active Toggles
            SwitchListTile(
              title: Text(l10n.autoRegisterTransaction),
              subtitle: Text(l10n.autoRegisterDesc),
              value: _autoRegister,
              onChanged: (val) {
                setState(() {
                  _autoRegister = val;
                });
              },
            ),

            if (widget.isEditing)
              SwitchListTile(
                title: Text(l10n.activeCommitment),
                subtitle: Text(l10n.activeCommitmentDesc),
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
              ),

            const SizedBox(height: 24),

            // Submit Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                widget.isEditing ? l10n.saveChanges : l10n.createSubscription,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _saveSubscription,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
        _billingDay = picked.day;
      });
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final amountCents = CurrencyFormatter.parseToCents(
      _amountController.text,
      currency: AppCurrency.fromCode(_selectedCurrency),
    );
    final subsProv = context.read<SubscriptionsProvider>();

    final sub = Subscription(
      id:
          widget.subscription?.id ??
          'sub_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      amountCents: amountCents,
      currency: _selectedCurrency,
      frequency: _frequency,
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      billingDay: _billingDay,
      nextDueDate: _nextDueDate,
      autoRegister: _autoRegister,
      isActive: _isActive,
      createdAt: widget.subscription?.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    try {
      if (widget.isEditing) {
        await subsProv.updateSubscription(sub);
      } else {
        await subsProv.addSubscription(sub);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? l10n.subscriptionUpdatedSuccess
                  : l10n.subscriptionAddedSuccess,
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingSubscription(e.toString())),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.deleteSubscriptionQuestion),
            content: Text(
              l10n.confirmDeleteSubscriptionDetail(widget.subscription?.name ?? ''),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final subsProv = context.read<SubscriptionsProvider>();
      await subsProv.deleteSubscription(widget.subscription!.id);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
