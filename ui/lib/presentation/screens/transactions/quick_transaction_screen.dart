import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/transaction.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/common/calculator_numpad.dart';
import '../../widgets/common/category_grid_picker.dart';

/// Screen for rapid 2-tap micro-expense capture and full transaction entry.
class QuickTransactionScreen extends StatefulWidget {
  final TransactionType initialType;
  final String? initialAccountId;

  const QuickTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.initialAccountId,
  });

  @override
  State<QuickTransactionScreen> createState() => _QuickTransactionScreenState();
}

class _QuickTransactionScreenState extends State<QuickTransactionScreen> {
  late TransactionType _selectedType;
  int _amountCents = 0;
  String? _selectedAccountId;
  String? _toAccountId; // For transfers
  String? _selectedCategoryId;
  DateTime _transactionDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedAccountId = widget.initialAccountId;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final accountsProv = context.watch<AccountsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    final accounts = accountsProv.accounts.where((a) => !a.isArchived).toList();

    // Default account selection if not set
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final currentAccount =
        accounts.where((a) => a.id == _selectedAccountId).firstOrNull ??
        accounts.firstOrNull;
    final currencyCode = currentAccount?.currency ?? 'USD';

    final categories = _selectedType == TransactionType.income
        ? txProv.incomeCategories
        : txProv.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTransaction),
        actions: [
          IconButton(
            icon: Icon(
              _showDetails ? Icons.keyboard_arrow_up : Icons.edit_note_outlined,
            ),
            tooltip: l10n.toggleNoteAndDate,
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Type Selector & Amount Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Segmented Type Selector
                  SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text(l10n.expense),
                        icon: const Icon(Icons.arrow_downward, size: 16),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(l10n.income),
                        icon: const Icon(Icons.arrow_upward, size: 16),
                      ),
                      ButtonSegment(
                        value: TransactionType.transfer,
                        label: Text(l10n.transfer),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (Set<TransactionType> newSelection) {
                      setState(() {
                        _selectedType = newSelection.first;
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Amount Display Hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          CurrencyFormatter.formatCents(
                            _amountCents,
                            symbol: currencyCode == 'USD'
                                ? '\$'
                                : '$currencyCode ',
                          ),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: _selectedType == TransactionType.expense
                                ? Colors.red.shade600
                                : _selectedType == TransactionType.income
                                ? Colors.green.shade600
                                : colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Account Selector pill
                        _buildAccountSelector(accounts),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Optional Details (Note & Date)
            if (_showDetails)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: l10n.noteOrDescription,
                            prefixIcon: const Icon(Icons.description_outlined),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'yyyy-MM-dd, HH:mm',
                              ).format(_transactionDate),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(l10n.changeDate),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Middle Section: Category Picker OR Transfer Destination
            Expanded(
              child: _selectedType == TransactionType.transfer
                  ? _buildTransferDestinationPicker(accounts)
                  : SingleChildScrollView(
                      child: CategoryGridPicker(
                        categories: categories,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                          // 2-Tap rapid micro-expense flow:
                          // If amount is already entered (> 0), automatically submit!
                          if (_amountCents > 0) {
                            _submitTransaction();
                          }
                        },
                      ),
                    ),
            ),

            // Bottom Section: Custom On-screen Calculator Numpad
            CalculatorNumpad(
              initialAmountCents: _amountCents,
              onAmountChanged: (cents) {
                setState(() {
                  _amountCents = cents;
                });
              },
              onDone: _submitTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector(List<Account> accounts) {
    final l10n = AppLocalizations.of(context)!;
    if (accounts.isEmpty) {
      return Text(
        l10n.noAccountsFoundCreateFirst,
        style: const TextStyle(color: Colors.red),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 16),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: _selectedAccountId,
          isDense: true,
          underline: const SizedBox(),
          items: accounts.map((account) {
            return DropdownMenuItem<String>(
              value: account.id,
              child: Text(
                account.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedAccountId = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTransferDestinationPicker(List<Account> accounts) {
    final l10n = AppLocalizations.of(context)!;
    final destinationAccounts = accounts
        .where((a) => a.id != _selectedAccountId)
        .toList();

    if (_toAccountId == null && destinationAccounts.isNotEmpty) {
      _toAccountId = destinationAccounts.first.id;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transferDestinationAccount,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _toAccountId,
            decoration: InputDecoration(
              labelText: l10n.toAccount,
              prefixIcon: const Icon(Icons.input),
              border: const OutlineInputBorder(),
            ),
            items: destinationAccounts.map((account) {
              return DropdownMenuItem<String>(
                value: account.id,
                child: Text(account.name),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _toAccountId = val;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.check),
            label: Text(l10n.confirmTransfer),
            onPressed: _submitTransaction,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_transactionDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _transactionDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    if (_amountCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterAmountGreaterThanZero),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectAccount),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedType == TransactionType.transfer) {
      if (_toAccountId == null || _toAccountId == _selectedAccountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectDifferentDestination),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      accountId: _selectedAccountId!,
      toAccountId: _selectedType == TransactionType.transfer
          ? _toAccountId
          : null,
      categoryId: _selectedType != TransactionType.transfer
          ? _selectedCategoryId
          : null,
      amountCents: _amountCents,
      type: _selectedType,
      description: _noteController.text.trim(),
      transactionDate: _transactionDate,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    final txProv = context.read<TransactionsProvider>();
    final accountsProv = context.read<AccountsProvider>();

    try {
      await txProv.addTransaction(tx, accountsProvider: accountsProv);

      if (mounted) {
        final typeLabel = _selectedType == TransactionType.income
            ? l10n.income
            : (_selectedType == TransactionType.expense ? l10n.expense : l10n.transfer);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.recordedSuccessfully(typeLabel.toUpperCase()),
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingTransaction(e.toString())),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
