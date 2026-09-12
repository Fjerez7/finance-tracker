import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/cards/savings_goal_card.dart';
import 'add_edit_savings_goal_screen.dart';

/// Screen managing savings targets and fund deposits.
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgetsProv = context.watch<BudgetsProvider>();
    final accountsProv = context.watch<AccountsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    final activeGoals = budgetsProv.activeSavingsGoals;
    final completedGoals = budgetsProv.completedSavingsGoals;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savingsGoals),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.activeCount(activeGoals.length)),
            Tab(text: l10n.completedCount(completedGoals.length)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Goals Tab
          activeGoals.isEmpty
              ? _buildEmptyState(
                context,
                title: l10n.noActiveSavingsGoals,
                message: l10n.savingsGoalsDesc,
              )
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                itemCount: activeGoals.length,
                itemBuilder: (context, index) {
                  final goal = activeGoals[index];
                  return SavingsGoalCard(
                    goal: goal,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditSavingsGoalScreen(goal: goal),
                        ),
                      );
                    },
                    onDeposit:
                        () => _showDepositDialog(
                          context,
                          goal,
                          budgetsProv,
                          accountsProv,
                          txProv,
                        ),
                  );
                },
              ),

          // Completed Goals Tab
          completedGoals.isEmpty
              ? _buildEmptyState(
                context,
                title: l10n.noCompletedGoals,
                message: l10n.completedGoalsDesc,
              )
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                itemCount: completedGoals.length,
                itemBuilder: (context, index) {
                  final goal = completedGoals[index];
                  return SavingsGoalCard(
                    goal: goal,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditSavingsGoalScreen(goal: goal),
                        ),
                      );
                    },
                  );
                },
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.newSavingsGoal,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditSavingsGoalScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDepositDialog(
    BuildContext context,
    SavingsGoal goal,
    BudgetsProvider budgetsProv,
    AccountsProvider accountsProv,
    TransactionsProvider txProv,
  ) async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final accounts = accountsProv.accounts.where((a) => !a.isArchived).toList();
    String? selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final deposited = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.depositToGoal(goal.name)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.depositAmount,
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.pleaseEnterDepositAmount;
                        }
                        final cents = CurrencyFormatter.parseToCents(val);
                        if (cents <= 0) {
                          return l10n.amountMustBeGreaterThanZero;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (accounts.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedAccountId,
                        decoration: InputDecoration(
                          labelText: l10n.sourceAccount,
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
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
                            selectedAccountId = val;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(ctx).pop(true);
                    }
                  },
                  child: Text(l10n.deposit),
                ),
              ],
            );
          },
        );
      },
    );

    if (deposited == true) {
      final int amountCents = CurrencyFormatter.parseToCents(
        amountController.text,
      );
      try {
        await budgetsProv.depositFunds(
          goal.id,
          amountCents,
          fromAccountId: selectedAccountId,
          accountsProvider: accountsProv,
          transactionsProvider: txProv,
        );
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.depositedIntoGoal(CurrencyFormatter.formatCents(amountCents), goal.name),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorDepositingFunds(e.toString())),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
