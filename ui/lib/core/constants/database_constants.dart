/// Database table and column name constants for SQLite storage.
class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'finance_tracker.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableAccounts = 'accounts';
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';
  static const String tableSubscriptions = 'subscriptions';
  static const String tableBudgets = 'budgets';
  static const String tableSavingsGoals = 'savings_goals';

  // Common Columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colColorHex = 'color_hex';
  static const String colIconName = 'icon_name';

  // Accounts Columns
  static const String colAccountType = 'type';
  static const String colBalanceCents = 'balance_cents';
  static const String colCreditLimitCents = 'credit_limit_cents';
  static const String colCurrency = 'currency';
  static const String colIsArchived = 'is_archived';

  // Categories Columns
  static const String colCategoryType = 'type';
  static const String colIsDefault = 'is_default';

  // Transactions Columns
  static const String colAccountId = 'account_id';
  static const String colToAccountId = 'to_account_id';
  static const String colCategoryId = 'category_id';
  static const String colAmountCents = 'amount_cents';
  static const String colTransactionType = 'type';
  static const String colDescription = 'description';
  static const String colTransactionDate = 'transaction_date';

  // Subscriptions Columns
  static const String colFrequency = 'frequency';
  static const String colBillingDay = 'billing_day';
  static const String colNextDueDate = 'next_due_date';
  static const String colAutoRegister = 'auto_register';
  static const String colIsActive = 'is_active';

  // Budgets Columns
  static const String colMonth = 'month';
  static const String colYear = 'year';
  static const String colLimitCents = 'limit_cents';

  // Savings Goals Columns
  static const String colTargetAmountCents = 'target_amount_cents';
  static const String colCurrentAmountCents = 'current_amount_cents';
  static const String colTargetDate = 'target_date';
  static const String colIsCompleted = 'is_completed';
}
