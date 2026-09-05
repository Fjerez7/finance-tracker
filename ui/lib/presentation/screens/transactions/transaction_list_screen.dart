import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../widgets/cards/transaction_list_tile.dart';
import 'quick_transaction_screen.dart';
import 'transaction_detail_screen.dart';

/// Screen presenting the full filterable and searchable ledger of transactions.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final txProv = context.watch<TransactionsProvider>();
    final accountsProv = context.watch<AccountsProvider>();

    final transactions = txProv.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Transaction',
            onPressed: () => _openAddTransaction(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search notes or descriptions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              txProv.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => txProv.setSearchQuery(val),
                ),
                const SizedBox(height: 10),

                // Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: txProv.selectedType == null,
                        onSelected: () => txProv.setFilterType(null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Expenses',
                        isSelected:
                            txProv.selectedType == TransactionType.expense,
                        onSelected: () =>
                            txProv.setFilterType(TransactionType.expense),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Income',
                        isSelected:
                            txProv.selectedType == TransactionType.income,
                        onSelected: () =>
                            txProv.setFilterType(TransactionType.income),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Transfers',
                        isSelected:
                            txProv.selectedType == TransactionType.transfer,
                        onSelected: () =>
                            txProv.setFilterType(TransactionType.transfer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cashflow Summary Bar for Current Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: colorScheme.surfaceContainerLowest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCashflowMetric(
                  label: 'Income',
                  amountCents: txProv.totalIncomeCents,
                  color: Colors.green.shade600,
                  sign: '+',
                ),
                _buildCashflowMetric(
                  label: 'Expense',
                  amountCents: txProv.totalExpenseCents,
                  color: Colors.red.shade600,
                  sign: '-',
                ),
                _buildCashflowMetric(
                  label: 'Net',
                  amountCents: txProv.netCashFlowCents,
                  color: txProv.netCashFlowCents >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  sign: txProv.netCashFlowCents >= 0 ? '+' : '',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Transactions Feed or Empty State
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => txProv.fetchTransactions(),
              child: transactions.isEmpty
                  ? _buildEmptyState(context)
                  : _buildGroupedTransactionList(
                      context,
                      transactions,
                      txProv,
                      accountsProv,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCashflowMetric({
    required String label,
    required int amountCents,
    required Color color,
    required String sign,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          '$sign${CurrencyFormatter.formatCents(amountCents.abs())}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No transactions found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the "+" button to record a new transaction.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedTransactionList(
    BuildContext context,
    List<Transaction> transactions,
    TransactionsProvider txProv,
    AccountsProvider accountsProv,
  ) {
    // Group transactions by Date header (e.g., "Today", "Yesterday", "MMMM d, yyyy")
    final Map<String, List<Transaction>> grouped = {};

    for (final tx in transactions) {
      final dateKey = _formatDateHeader(tx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final dateHeader = grouped.keys.elementAt(index);
        final txList = grouped[dateHeader]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
              child: Text(
                dateHeader,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...txList.map((tx) {
              final category = txProv.getCategoryById(tx.categoryId);
              final account = accountsProv.accounts
                  .where((a) => a.id == tx.accountId)
                  .firstOrNull;
              final toAccount = tx.toAccountId != null
                  ? accountsProv.accounts
                        .where((a) => a.id == tx.toAccountId)
                        .firstOrNull
                  : null;

              return TransactionListTile(
                transaction: tx,
                category: category,
                account: account,
                toAccount: toAccount,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(transaction: tx),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(local.year, local.month, local.day);

    if (txDay == today) {
      return 'Today';
    } else if (txDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (local.year == now.year) {
      return DateFormat('EEEE, MMMM d').format(local);
    } else {
      return DateFormat('MMMM d, yyyy').format(local);
    }
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QuickTransactionScreen()));
  }
}
