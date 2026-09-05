import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../providers/budgets_provider.dart';

/// Screen for creating and editing target savings objectives.
class AddEditSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;

  const AddEditSavingsGoalScreen({super.key, this.goal});

  bool get isEditing => goal != null;

  @override
  State<AddEditSavingsGoalScreen> createState() =>
      _AddEditSavingsGoalScreenState();
}

class _AddEditSavingsGoalScreenState extends State<AddEditSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  DateTime? _targetDate;
  late String _selectedColorHex;
  late String _selectedIconName;

  static const List<String> _availableColors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#00BCD4', // Cyan
    '#FFC107', // Amber
    '#607D8B', // Blue Grey
  ];

  static const List<String> _availableIcons = [
    'savings',
    'flight',
    'home',
    'directions_car',
    'laptop',
    'school',
    'favorite',
    'star',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.goal;

    _nameController = TextEditingController(text: g?.name ?? '');
    _targetAmountController = TextEditingController(
      text: g != null ? (g.targetAmountCents / 100.0).toStringAsFixed(2) : '',
    );
    _currentAmountController = TextEditingController(
      text:
          g != null
              ? (g.currentAmountCents / 100.0).toStringAsFixed(2)
              : '0.00',
    );
    _targetDate = g?.targetDate;
    _selectedColorHex = g?.colorHex ?? _availableColors.first;
    _selectedIconName = g?.iconName ?? _availableIcons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Savings Goal' : 'New Savings Goal',
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              tooltip: 'Delete Goal',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Goal Title
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                hintText: 'e.g., Emergency Fund, Japan Trip, New Laptop',
                prefixIcon: Icon(Icons.flag_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a goal title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Target Amount
            TextFormField(
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Target Savings Amount',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter the target amount';
                }
                final cents = CurrencyFormatter.parseToCents(val);
                if (cents <= 0) {
                  return 'Target amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Current Saved Amount
            TextFormField(
              controller: _currentAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Current Saved Amount',
                hintText: '0.00',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter current saved amount';
                }
                final cents = CurrencyFormatter.parseToCents(val);
                if (cents < 0) {
                  return 'Amount cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Target Completion Date Picker Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Deadline (Optional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _targetDate != null
                              ? DateFormat('MMMM d, yyyy').format(_targetDate!)
                              : 'No deadline set',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (_targetDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _targetDate = null;
                              });
                            },
                          ),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: Text(_targetDate != null ? 'Change' : 'Set Date'),
                          onPressed: _pickTargetDate,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Color Selector
            const Text(
              'Select Goal Color',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _availableColors.map((hex) {
                    final color = Color(
                      int.parse(hex.replaceFirst('#', '0xFF')),
                    );
                    final isSelected = _selectedColorHex == hex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorHex = hex;
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: colorScheme.onSurface,
                                    width: 3,
                                  )
                                  : null,
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            // Icon Selector
            const Text(
              'Select Goal Icon',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _availableIcons.map((iconName) {
                    final iconData = IconHelper.getIconData(iconName);
                    final isSelected = _selectedIconName == iconName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconName = iconName;
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Icon(
                          iconData,
                          color:
                              isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 28),

            // Submit Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                widget.isEditing ? 'Save Changes' : 'Create Savings Goal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _saveGoal,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _targetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final targetCents = CurrencyFormatter.parseToCents(
      _targetAmountController.text,
    );
    final currentCents = CurrencyFormatter.parseToCents(
      _currentAmountController.text,
    );
    final budgetsProv = context.read<BudgetsProvider>();

    final goal = SavingsGoal(
      id:
          widget.goal?.id ??
          'goal_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      targetAmountCents: targetCents,
      currentAmountCents: currentCents,
      targetDate: _targetDate,
      colorHex: _selectedColorHex,
      iconName: _selectedIconName,
      isCompleted: currentCents >= targetCents,
      createdAt: widget.goal?.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    try {
      if (widget.isEditing) {
        await budgetsProv.updateSavingsGoal(goal);
      } else {
        await budgetsProv.addSavingsGoal(goal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Savings goal updated successfully'
                  : 'Savings goal created successfully',
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
            content: Text('Error saving goal: $e'),
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
            title: const Text('Delete Savings Goal?'),
            content: Text(
              'Are you sure you want to delete "${widget.goal?.name}"? Recorded transactions will remain unaffected.',
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
      final budgetsProv = context.read<BudgetsProvider>();
      await budgetsProv.deleteSavingsGoal(widget.goal!.id);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
