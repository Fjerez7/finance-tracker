import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/budget.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/transactions_provider.dart';

/// Screen for creating and editing monthly category budgets.
class AddEditBudgetScreen extends StatefulWidget {
  final Budget? budget;
  final int? initialMonth;
  final int? initialYear;

  const AddEditBudgetScreen({
    super.key,
    this.budget,
    this.initialMonth,
    this.initialYear,
  });

  bool get isEditing => budget != null;

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _limitController;
  String? _selectedCategoryId;
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    _limitController = TextEditingController(
      text: b != null ? (b.limitCents / 100.0).toStringAsFixed(2) : '',
    );
    _selectedCategoryId = b?.categoryId;
    _selectedMonth =
        b?.month ?? widget.initialMonth ?? DateTime.now().month;
    _selectedYear =
        b?.year ?? widget.initialYear ?? DateTime.now().year;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final txProv = context.watch<TransactionsProvider>();
    final categories = txProv.expenseCategories;

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final date = DateTime(_selectedYear, _selectedMonth);
    final periodName = DateFormat('MMMM yyyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Budget' : 'Set Category Budget'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              tooltip: 'Delete Budget',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Period Display
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BUDGET PERIOD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          periodName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.calendar_month, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Expense Category',
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
              onChanged:
                  widget.isEditing
                      ? null // Category is locked during editing
                      : (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
              validator:
                  (val) => val == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Budget Limit Amount
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly Spending Limit',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter budget limit';
                }
                final cents = CurrencyFormatter.parseToCents(val);
                if (cents <= 0) {
                  return 'Limit must be greater than 0';
                }
                return null;
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
                widget.isEditing ? 'Save Changes' : 'Set Budget',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _saveBudget,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final limitCents = CurrencyFormatter.parseToCents(_limitController.text);
    final budgetsProv = context.read<BudgetsProvider>();

    final budget = Budget(
      id:
          widget.budget?.id ??
          'b_${_selectedCategoryId}_${_selectedYear}_$_selectedMonth',
      categoryId: _selectedCategoryId!,
      month: _selectedMonth,
      year: _selectedYear,
      limitCents: limitCents,
      createdAt: widget.budget?.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    try {
      if (widget.isEditing) {
        await budgetsProv.updateBudget(budget);
      } else {
        await budgetsProv.addBudget(budget);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Budget updated successfully'
                  : 'Budget set successfully',
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
            content: Text('Error saving budget: $e'),
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
            title: const Text('Delete Budget Limit?'),
            content: const Text(
              'Are you sure you want to remove this category budget limit? Past recorded transactions will remain unaffected.',
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
      await budgetsProv.deleteBudget(widget.budget!.id);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
