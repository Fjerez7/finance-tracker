import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/subscription.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/subscriptions_provider.dart';
import '../../../providers/transactions_provider.dart';

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
          widget.isEditing ? 'Edit Subscription' : 'Add Subscription',
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              tooltip: 'Delete Subscription',
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
              decoration: const InputDecoration(
                labelText: 'Service Name',
                hintText: 'e.g., Netflix, Spotify, Gym, Rent',
                prefixIcon: Icon(Icons.subscriptions_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a service name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Periodic Amount',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter the periodic amount';
                }
                final cents = CurrencyFormatter.parseToCents(val);
                if (cents <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Frequency Dropdown
            DropdownButtonFormField<RecurrenceFrequency>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Billing Frequency',
                prefixIcon: Icon(Icons.repeat),
                border: OutlineInputBorder(),
              ),
              items:
                  RecurrenceFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq.name.toUpperCase()),
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
              decoration: const InputDecoration(
                labelText: 'Account to Debit',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(),
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
              validator: (val) => val == null ? 'Please select an account' : null,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items:
                  categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategoryId = val;
                });
              },
              validator: (val) => val == null ? 'Please select a category' : null,
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
                            const Text(
                              'Next Due Date',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(
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
                          label: const Text('Change'),
                          onPressed: _pickDueDate,
                        ),
                      ],
                    ),
                    if (_frequency == RecurrenceFrequency.monthly) ...[
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monthly Billing Day:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          DropdownButton<int>(
                            value: _billingDay,
                            items:
                                List.generate(31, (i) => i + 1).map((day) {
                                  return DropdownMenuItem(
                                    value: day,
                                    child: Text('Day $day'),
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
              title: const Text('Auto-register transaction'),
              subtitle: const Text(
                'Automatically post transaction on due date without manual confirmation',
              ),
              value: _autoRegister,
              onChanged: (val) {
                setState(() {
                  _autoRegister = val;
                });
              },
            ),

            if (widget.isEditing)
              SwitchListTile(
                title: const Text('Active Commitment'),
                subtitle: const Text('Include in monthly burn rate and payment schedules'),
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
                widget.isEditing ? 'Save Changes' : 'Create Subscription',
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

    final name = _nameController.text.trim();
    final amountCents = CurrencyFormatter.parseToCents(_amountController.text);
    final subsProv = context.read<SubscriptionsProvider>();

    final sub = Subscription(
      id:
          widget.subscription?.id ??
          'sub_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      amountCents: amountCents,
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
                  ? 'Subscription updated successfully'
                  : 'Subscription added successfully',
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
            content: Text('Error saving subscription: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Subscription?'),
            content: Text(
              'Are you sure you want to delete "${widget.subscription?.name}"? Past recorded transactions will remain unaffected.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
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
