import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/savings_goal.dart';
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
    final budgetsProv = context.watch<BudgetsProvider>();
    final accountsProv = context.watch<AccountsProvider>();
    final txProv = context.watch<TransactionsProvider>();

    final activeGoals = budgetsProv.activeSavingsGoals;
    final completedGoals = budgetsProv.completedSavingsGoals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeGoals.length})'),
            Tab(text: 'Completed (${completedGoals.length})'),
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
                title: 'No active savings goals',
                message:
                    'Set savings targets for vacations, emergency funds, or gadgets by tapping "+"',
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
                title: 'No completed goals yet',
                message: 'Goals you reach 100% will be celebrated here',
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
        tooltip: 'New Savings Goal',
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

    final deposited = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Deposit to ${goal.name}'),
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
                      decoration: const InputDecoration(
                        labelText: 'Deposit Amount',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter deposit amount';
                        }
                        final cents = CurrencyFormatter.parseToCents(val);
                        if (cents <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (accounts.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Source Account',
                          prefixIcon: Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
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
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(ctx).pop(true);
                    }
                  },
                  child: const Text('Deposit'),
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
              'Deposited ${CurrencyFormatter.formatCents(amountCents)} into ${goal.name}!',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error depositing funds: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
