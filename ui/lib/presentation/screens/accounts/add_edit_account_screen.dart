import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../domain/entities/account.dart';
import '../../../providers/accounts_provider.dart';

/// Screen for creating a new account or editing an existing one.
class AddEditAccountScreen extends StatefulWidget {
  final Account? account;

  const AddEditAccountScreen({super.key, this.account});

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _creditLimitController;

  late AccountType _selectedType;
  late String _selectedColorHex;
  late String _selectedIconName;
  late String _selectedCurrency;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final Account? acc = widget.account;

    _nameController = TextEditingController(text: acc?.name ?? '');
    _balanceController = TextEditingController(
      text: acc != null
          ? CurrencyFormatter.centsToDouble(acc.balanceCents).toStringAsFixed(2)
          : '0.00',
    );
    _creditLimitController = TextEditingController(
      text: acc != null && acc.creditLimitCents > 0
          ? CurrencyFormatter.centsToDouble(
              acc.creditLimitCents,
            ).toStringAsFixed(2)
          : '0.00',
    );

    _selectedType = acc?.type ?? AccountType.bank;
    _selectedColorHex = acc?.colorHex ?? ColorHelper.presetColors.first;
    _selectedIconName = acc?.iconName ?? 'account_balance';
    _selectedCurrency = acc?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final String name = _nameController.text.trim();
    final int balanceCents = CurrencyFormatter.parseToCents(
      _balanceController.text,
    );
    final int creditLimitCents = _selectedType == AccountType.creditCard
        ? CurrencyFormatter.parseToCents(_creditLimitController.text)
        : 0;

    final DateTime now = DateTime.now().toUtc();
    final AccountsProvider provider = Provider.of<AccountsProvider>(
      context,
      listen: false,
    );

    try {
      if (_isEditing) {
        final Account updated = widget.account!.copyWith(
          name: name,
          type: _selectedType,
          balanceCents: balanceCents,
          creditLimitCents: creditLimitCents,
          currency: _selectedCurrency,
          colorHex: _selectedColorHex,
          iconName: _selectedIconName,
          updatedAt: now,
        );
        await provider.updateAccount(updated);
      } else {
        final Account newAccount = Account(
          id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          type: _selectedType,
          balanceCents: balanceCents,
          creditLimitCents: creditLimitCents,
          currency: _selectedCurrency,
          colorHex: _selectedColorHex,
          iconName: _selectedIconName,
          isArchived: false,
          createdAt: now,
          updatedAt: now,
        );
        await provider.addAccount(newAccount);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving account: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = ColorHelper.hexToColor(_selectedColorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'New Account'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAccount),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Preview Icon Avatar
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconHelper.getIconData(_selectedIconName),
                  color: activeColor,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g., Bancolombia, Chase, Cash Wallet',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an account name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Account Type Selector
            const Text(
              'Account Type',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                final bool isSelected = _selectedType == type;
                String label;
                switch (type) {
                  case AccountType.bank:
                    label = 'Bank';
                    break;
                  case AccountType.digitalWallet:
                    label = 'Digital Wallet';
                    break;
                  case AccountType.cash:
                    label = 'Cash';
                    break;
                  case AccountType.creditCard:
                    label = 'Credit Card';
                    break;
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                        if (type == AccountType.creditCard) {
                          _selectedIconName = 'credit_card';
                        } else if (type == AccountType.cash) {
                          _selectedIconName = 'wallet';
                        } else {
                          _selectedIconName = 'account_balance';
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Balance / Debt Input
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _selectedType == AccountType.creditCard
                    ? 'Current Debt Balance (\$)'
                    : 'Initial Balance (\$)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Credit Limit (conditional)
            if (_selectedType == AccountType.creditCard) ...[
              TextFormField(
                controller: _creditLimitController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Total Credit Limit (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_score),
                ),
                validator: (value) {
                  if (_selectedType == AccountType.creditCard) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a credit limit';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],

            // Color Palette
            const Text(
              'Color Accent',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ColorHelper.presetColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final String hex = ColorHelper.presetColors[index];
                  final Color color = ColorHelper.hexToColor(hex);
                  final bool isSelected = _selectedColorHex == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorHex = hex),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black87, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Icon Picker
            const Text(
              'Icon',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: IconHelper.accountIcons.entries.map((entry) {
                final bool isSelected = _selectedIconName == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconName = entry.key),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: activeColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? activeColor : Colors.grey.shade700,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save Button
            FilledButton.icon(
              onPressed: _saveAccount,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Save Changes' : 'Create Account'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
