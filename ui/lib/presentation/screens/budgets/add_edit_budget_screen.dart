import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/category_localization_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/budget.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final txProv = context.watch<TransactionsProvider>();
    final categories = txProv.expenseCategories;

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final date = DateTime(_selectedYear, _selectedMonth);
    final locale = Localizations.localeOf(context).toString();
    final periodName = DateFormat('MMMM yyyy', locale).format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editBudget : l10n.setCategoryBudget),
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
                        Text(
                          l10n.budgetPeriod,
                          style: const TextStyle(
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
              decoration: InputDecoration(
                labelText: l10n.expenseCategory,
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
              onChanged:
                  widget.isEditing
                      ? null // Category is locked during editing
                      : (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
              validator:
                  (val) => val == null ? l10n.pleaseSelectCategory : null,
            ),
            const SizedBox(height: 16),

            // Budget Limit Amount
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.monthlySpendingLimit,
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.pleaseEnterBudgetLimit;
                }
                final cents = CurrencyFormatter.parseToCents(val);
                if (cents <= 0) {
                  return l10n.limitMustBeGreaterThanZero;
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
                widget.isEditing ? l10n.saveChanges : l10n.setBudget,
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

    final l10n = AppLocalizations.of(context)!;
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
                  ? l10n.budgetUpdatedSuccess
                  : l10n.budgetSetSuccess,
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
            content: Text(l10n.errorSavingBudget(e.toString())),
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
            title: Text(l10n.deleteBudgetLimitQuestion),
            content: Text(l10n.confirmDeleteBudgetDetail),
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
      final budgetsProv = context.read<BudgetsProvider>();
      await budgetsProv.deleteBudget(widget.budget!.id);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
