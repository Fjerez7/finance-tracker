// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get custom => 'Custom';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get notes => 'Notes';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get type => 'Type';

  @override
  String get name => 'Name';

  @override
  String get actions => 'Actions';

  @override
  String get clear => 'Clear';

  @override
  String get filter => 'Filter';

  @override
  String get search => 'Search';

  @override
  String get status => 'Status';

  @override
  String get details => 'Details';

  @override
  String get done => 'Done';

  @override
  String get add => 'Add';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navSubscriptions => 'Subscriptions';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navSettings => 'Settings';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get assets => 'Assets';

  @override
  String get liabilities => 'Liabilities';

  @override
  String get net => 'Net';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get monthlyCashFlow => 'Monthly Cash Flow';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get noRecentTransactions => 'No recent transactions yet';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get activeBudgets => 'Active Budgets';

  @override
  String get upcomingSubscriptions => 'Upcoming Subscriptions';

  @override
  String get accounts => 'Accounts';

  @override
  String get addAccount => 'Add Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountType => 'Account Type';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get currentDebt => 'CURRENT DEBT';

  @override
  String get creditLimit => 'Credit Limit';

  @override
  String get includeInNetWorth => 'Include in Net Worth';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete this account? All associated transactions will also be deleted.';

  @override
  String confirmDeleteAccountNamed(String accountName) {
    return 'Are you sure you want to delete \"$accountName\"? This action cannot be undone.';
  }

  @override
  String get noAccountsFound => 'No accounts found. Create one to get started!';

  @override
  String get noAccountsFoundCreateFirst =>
      'No accounts found. Please create one first.';

  @override
  String get accountNotFound => 'Account not found';

  @override
  String get adjustBalance => 'Adjust Balance';

  @override
  String adjustBalanceFor(String accountName) {
    return 'Adjust Balance for $accountName';
  }

  @override
  String get enterNewReconciledBalance => 'Enter the new reconciled balance:';

  @override
  String get newBalance => 'New Balance';

  @override
  String get updateBalance => 'Update Balance';

  @override
  String get deleteAccountQuestion => 'Delete Account?';

  @override
  String get unarchiveAccount => 'Unarchive Account';

  @override
  String get archiveAccount => 'Archive Account';

  @override
  String get creditLimitAndUtilization => 'Credit Limit & Utilization';

  @override
  String get availableCredit => 'Available Credit';

  @override
  String get totalLimit => 'Total Limit';

  @override
  String availableAmount(String amount) {
    return 'Available: $amount';
  }

  @override
  String creditUsedOfTotal(String percentage, String total) {
    return '$percentage used of $total';
  }

  @override
  String get accountTypeChecking => 'Checking';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeCreditCard => 'Credit Card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeInvestment => 'Investment';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accountTypeBank => 'Bank Account';

  @override
  String get accountTypeDigitalWallet => 'Digital Wallet';

  @override
  String get transactions => 'Transactions';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get quickTransaction => 'Quick Transaction';

  @override
  String get transactionDetail => 'Transaction Details';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get accountTransfer => 'Account Transfer';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get sourceAccount => 'Source Account';

  @override
  String get destinationAccount => 'Destination Account';

  @override
  String get payee => 'Payee / Merchant';

  @override
  String get transactionDeleted => 'Transaction deleted successfully';

  @override
  String get confirmDeleteTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get confirmDeleteTransactionDetail =>
      'This will permanently delete this transaction and automatically reverse its effect on your account balance.';

  @override
  String get deleteTransactionQuestion => 'Delete Transaction?';

  @override
  String get filterAll => 'All';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpense => 'Expense';

  @override
  String get filterExpenses => 'Expenses';

  @override
  String get filterTransfer => 'Transfer';

  @override
  String get filterTransfers => 'Transfers';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get noCategoriesFound => 'No categories available';

  @override
  String get transactionSaved => 'Transaction saved successfully';

  @override
  String get calculator => 'Calculator';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get searchHint => 'Search notes or descriptions...';

  @override
  String get netFlow => 'Net Flow';

  @override
  String get tapPlusToRecord =>
      'Tap the \"+\" button to record a new transaction.';

  @override
  String get toggleNoteAndDate => 'Toggle Note & Date';

  @override
  String get noteOrDescription => 'Note / Description';

  @override
  String get changeDate => 'Change Date';

  @override
  String get transferDestinationAccount => 'Transfer Destination Account:';

  @override
  String get confirmTransfer => 'Confirm Transfer';

  @override
  String get pleaseEnterAmountGreaterThanZero =>
      'Please enter an amount greater than 0';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get pleaseSelectDifferentDestination =>
      'Please select a different destination account';

  @override
  String recordedSuccessfully(String type) {
    return '$type recorded successfully!';
  }

  @override
  String errorSavingTransaction(String error) {
    return 'Error saving transaction: $error';
  }

  @override
  String get unknownAccount => 'Unknown Account';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get budgets => 'Budgets';

  @override
  String get budgetsAndGoals => 'Budgets & Goals';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get setCategoryBudget => 'Set Category Budget';

  @override
  String get budgetPeriod => 'BUDGET PERIOD';

  @override
  String get expenseCategory => 'Expense Category';

  @override
  String get monthlySpendingLimit => 'Monthly Spending Limit';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseEnterBudgetLimit => 'Please enter budget limit';

  @override
  String get limitMustBeGreaterThanZero => 'Limit must be greater than 0';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get budgetUpdatedSuccess => 'Budget updated successfully';

  @override
  String get budgetSetSuccess => 'Budget set successfully';

  @override
  String errorSavingBudget(String error) {
    return 'Error saving budget: $error';
  }

  @override
  String get deleteBudgetLimitQuestion => 'Delete Budget Limit?';

  @override
  String get confirmDeleteBudgetDetail =>
      'Are you sure you want to remove this category budget limit? Past recorded transactions will remain unaffected.';

  @override
  String get previousMonth => 'Previous Month';

  @override
  String get nextMonth => 'Next Month';

  @override
  String get totalMonthlyBudget => 'TOTAL MONTHLY BUDGET';

  @override
  String percentSpent(int percent) {
    return '$percent% spent';
  }

  @override
  String ofAmount(String amount) {
    return 'of $amount';
  }

  @override
  String totalBudgetExceededBy(String amount) {
    return 'Total budget exceeded by $amount';
  }

  @override
  String amountLeftForMonth(String amount) {
    return '$amount left for the month';
  }

  @override
  String get categoryBudgets => 'Category Budgets';

  @override
  String configuredCount(int count) {
    return '$count configured';
  }

  @override
  String get noBudgetsSetForMonth => 'No budgets set for this month';

  @override
  String get setMonthlyLimitsDesc =>
      'Set monthly category limits to keep your spending on track by tapping \"+\"';

  @override
  String get categoryBudget => 'Category Budget';

  @override
  String budgetExceededBy(String amount) {
    return 'Exceeded by $amount';
  }

  @override
  String budgetApproachingLimit(int percent) {
    return 'Approaching limit ($percent%)';
  }

  @override
  String budgetRemainingAmount(String amount) {
    return '$amount remaining';
  }

  @override
  String get budgetLimit => 'Budget Limit';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get period => 'Period';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get yearly => 'Yearly';

  @override
  String get noBudgetsFound => 'No budgets created for this month';

  @override
  String get confirmDeleteBudget =>
      'Are you sure you want to delete this budget?';

  @override
  String get addSavingsGoal => 'Add Savings Goal';

  @override
  String get editSavingsGoal => 'Edit Savings Goal';

  @override
  String get newSavingsGoal => 'New Savings Goal';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentAmount => 'Current Amount';

  @override
  String get targetDate => 'Target Date';

  @override
  String get goalReached => 'Goal Reached!';

  @override
  String get addFunds => 'Add Funds';

  @override
  String get withdrawFunds => 'Withdraw Funds';

  @override
  String get noSavingsGoals => 'No savings goals created yet';

  @override
  String get confirmDeleteGoal =>
      'Are you sure you want to delete this savings goal?';

  @override
  String activeCount(int count) {
    return 'Active ($count)';
  }

  @override
  String completedCount(int count) {
    return 'Completed ($count)';
  }

  @override
  String get noActiveSavingsGoals => 'No active savings goals';

  @override
  String get savingsGoalsDesc =>
      'Set savings targets for vacations, emergency funds, or gadgets by tapping \"+\"';

  @override
  String get noCompletedGoals => 'No completed goals yet';

  @override
  String get completedGoalsDesc =>
      'Goals you reach 100% will be celebrated here';

  @override
  String depositToGoal(String goalName) {
    return 'Deposit to $goalName';
  }

  @override
  String get depositAmount => 'Deposit Amount';

  @override
  String get pleaseEnterDepositAmount => 'Please enter deposit amount';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get deposit => 'Deposit';

  @override
  String depositedIntoGoal(String amount, String goalName) {
    return 'Deposited $amount into $goalName!';
  }

  @override
  String errorDepositingFunds(String error) {
    return 'Error depositing funds: $error';
  }

  @override
  String get goalTitle => 'Goal Title';

  @override
  String get goalTitleHint => 'e.g., Emergency Fund, Japan Trip, New Laptop';

  @override
  String get pleaseEnterGoalTitle => 'Please enter a goal title';

  @override
  String get targetSavingsAmount => 'Target Savings Amount';

  @override
  String get pleaseEnterTargetAmount => 'Please enter the target amount';

  @override
  String get targetAmountMustBeGreaterThanZero =>
      'Target amount must be greater than 0';

  @override
  String get currentSavedAmount => 'Current Saved Amount';

  @override
  String get pleaseEnterCurrentSavedAmount =>
      'Please enter current saved amount';

  @override
  String get amountCannotBeNegative => 'Amount cannot be negative';

  @override
  String get targetDeadlineOptional => 'Target Deadline (Optional)';

  @override
  String get noDeadlineSet => 'No deadline set';

  @override
  String get setDate => 'Set Date';

  @override
  String get selectGoalColor => 'Select Goal Color';

  @override
  String get selectGoalIcon => 'Select Goal Icon';

  @override
  String get createSavingsGoal => 'Create Savings Goal';

  @override
  String get savingsGoalUpdatedSuccess => 'Savings goal updated successfully';

  @override
  String get savingsGoalCreatedSuccess => 'Savings goal created successfully';

  @override
  String errorSavingGoal(String error) {
    return 'Error saving goal: $error';
  }

  @override
  String get deleteSavingsGoalQuestion => 'Delete Savings Goal?';

  @override
  String confirmDeleteSavingsGoalDetail(String goalName) {
    return 'Are you sure you want to delete \"$goalName\"? Recorded transactions will remain unaffected.';
  }

  @override
  String get completedTag => 'COMPLETED';

  @override
  String targetDeadlineDate(String date) {
    return 'Target: $date';
  }

  @override
  String get noTargetDeadline => 'No target deadline';

  @override
  String savedAmount(String amount) {
    return '$amount saved';
  }

  @override
  String targetAmountLabel(String amount) {
    return 'Target: $amount';
  }

  @override
  String needMonthlySavings(String amount) {
    return 'Need ~$amount/mo to reach target on time';
  }

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get subscriptionsAndBills => 'Subscriptions & Bills';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get editSubscription => 'Edit Subscription';

  @override
  String get createSubscription => 'Create Subscription';

  @override
  String get billingCycle => 'Billing Cycle';

  @override
  String get billingDay => 'Billing Day';

  @override
  String get nextPayment => 'Next Payment';

  @override
  String get monthlyTotal => 'Monthly Total';

  @override
  String get yearlyTotal => 'Yearly Total';

  @override
  String get activeSubscriptions => 'Active Subscriptions';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get autoRegister => 'Auto-register Transaction';

  @override
  String get confirmDeleteSubscription =>
      'Are you sure you want to delete this subscription?';

  @override
  String get noSubscriptionsFound => 'No active subscriptions found';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get freqBiweekly => 'Bi-weekly';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqYearly => 'Yearly';

  @override
  String get freqAnnual => 'Annual';

  @override
  String pausedCount(int count) {
    return 'Paused ($count)';
  }

  @override
  String get monthlySubscriptionCommitment => 'MONTHLY SUBSCRIPTION COMMITMENT';

  @override
  String get perMonth => '/mo';

  @override
  String annualProjection(String amount) {
    return 'Annual Projection: $amount/year';
  }

  @override
  String get noActiveSubscriptions => 'No active subscriptions';

  @override
  String get subscriptionsActiveDesc =>
      'Track fixed commitments like Netflix, Spotify, or Rent by tapping \"+\"';

  @override
  String get noPausedSubscriptions => 'No paused subscriptions';

  @override
  String get pausedSubscriptionsDesc => 'Paused subscriptions will appear here';

  @override
  String postPaymentQuestion(String subName) {
    return 'Post $subName Payment?';
  }

  @override
  String confirmPaymentDetail(String amount, String accountName) {
    return 'This will create a real expense transaction of $amount from \"$accountName\" and advance the next due date.';
  }

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String paymentRecordedFor(String subName) {
    return 'Payment recorded for $subName!';
  }

  @override
  String errorPostingPayment(String error) {
    return 'Error posting payment: $error';
  }

  @override
  String get serviceName => 'Service Name';

  @override
  String get serviceNameHint => 'e.g., Netflix, Spotify, Gym, Rent';

  @override
  String get pleaseEnterServiceName => 'Please enter a service name';

  @override
  String get periodicAmount => 'Periodic Amount';

  @override
  String get pleaseEnterPeriodicAmount => 'Please enter the periodic amount';

  @override
  String get billingFrequency => 'Billing Frequency';

  @override
  String get accountToDebit => 'Account to Debit';

  @override
  String get nextDueDate => 'Next Due Date';

  @override
  String get monthlyBillingDay => 'Monthly Billing Day:';

  @override
  String billingDayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get autoRegisterTransaction => 'Auto-register transaction';

  @override
  String get autoRegisterDesc =>
      'Automatically post transaction on due date without manual confirmation';

  @override
  String get activeCommitment => 'Active Commitment';

  @override
  String get activeCommitmentDesc =>
      'Include in monthly burn rate and payment schedules';

  @override
  String get subscriptionUpdatedSuccess => 'Subscription updated successfully';

  @override
  String get subscriptionAddedSuccess => 'Subscription added successfully';

  @override
  String errorSavingSubscription(String error) {
    return 'Error saving subscription: $error';
  }

  @override
  String get deleteSubscriptionQuestion => 'Delete Subscription?';

  @override
  String confirmDeleteSubscriptionDetail(String subName) {
    return 'Are you sure you want to delete \"$subName\"? Past recorded transactions will remain unaffected.';
  }

  @override
  String get pausedTag => 'PAUSED';

  @override
  String get payAndAdvance => 'Pay & Advance';

  @override
  String get autoRegistersOnDueDate => 'Auto-registers on due date';

  @override
  String get manualConfirmation => 'Manual confirmation';

  @override
  String overdueDays(int days) {
    return 'Overdue ($days days)';
  }

  @override
  String get dueToday => 'Due Today';

  @override
  String get dueTomorrow => 'Due Tomorrow';

  @override
  String dueInDays(int days, String date) {
    return 'Due in $days days ($date)';
  }

  @override
  String get analytics => 'Analytics';

  @override
  String get visualAnalytics => 'Visual Analytics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get incomeByCategory => 'Income by Category';

  @override
  String get cashFlowTrend => 'Cash Flow Trend';

  @override
  String get monthlyComparison => 'Monthly Comparison';

  @override
  String get noAnalyticsData => 'Not enough data to display analytics';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get last90Days => '90 Days';

  @override
  String get thisYear => 'This Year';

  @override
  String get allTime => 'All Time';

  @override
  String get monthOverMonthSpendDelta => 'Month-over-Month Spend Delta';

  @override
  String momIncreaseDesc(String percent, String amount) {
    return '$percent% more than last month ($amount)';
  }

  @override
  String momDecreaseDesc(String percent, String amount) {
    return '$percent% less than last month ($amount)';
  }

  @override
  String get sixMonthCashFlowComparison => '6-Month Cash Flow Comparison';

  @override
  String get categoryExpenseProportions => 'Category Expense Proportions';

  @override
  String get noCashflowData => 'No cashflow data available';

  @override
  String get noExpensesPeriod => 'No expenses recorded in this period';

  @override
  String get settings => 'Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get currency => 'Currency';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get currencyUsd => 'US Dollar (USD - \$)';

  @override
  String get currencyCop => 'Colombian Peso (COP - \$)';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get cloudBackupDesc =>
      'Backup and restore your data with Google Drive';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportCsvDesc => 'Export transactions to a CSV spreadsheet file';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get appDescription =>
      'Privacy-focused, local-first personal finance tracker.';

  @override
  String get databaseStatus => 'Local Database';

  @override
  String get databaseStatusOk => 'Healthy (SQLite)';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get backupAndExport => 'Backup & Export';

  @override
  String get googleDriveBackup => 'Google Drive Backup';

  @override
  String get googleDriveCloudSync => 'Google Drive Cloud Sync';

  @override
  String get syncEncryptedSnapshotsDesc =>
      'Sync encrypted snapshots to private appDataFolder';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get notConnected => 'Not connected';

  @override
  String get connected => 'Connected';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get signOut => 'Sign Out';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get backUpNow => 'Back Up Now';

  @override
  String get backingUp => 'Backing up...';

  @override
  String get restoreNow => 'Restore Now';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get availableCloudBackups => 'Available Cloud Backups';

  @override
  String get noCloudBackupsFound => 'No cloud backups found';

  @override
  String get exportLedgerCsv => 'Export Ledger (CSV)';

  @override
  String exportLedgerCsvDesc(int count) {
    return 'Export all $count transactions with account and category mappings';
  }

  @override
  String get csvExportPreview => 'CSV Export Preview';

  @override
  String get exportDatabaseSnapshotJson => 'Export Database Snapshot (JSON)';

  @override
  String get databaseSnapshotJsonDesc =>
      'Full database dump with SHA-256 integrity checksum';

  @override
  String get databaseSnapshotJson => 'Database Snapshot JSON';

  @override
  String get restore => 'Restore';

  @override
  String get restoreCloudBackupQuestion => 'Restore Cloud Backup?';

  @override
  String confirmRestoreCloudBackupDetail(String backupName) {
    return 'This will overwrite existing local data with the snapshot from $backupName. Are you sure?';
  }

  @override
  String get restoreData => 'Restore Data';

  @override
  String get cloudBackupCreatedSuccess => 'Cloud backup created successfully!';

  @override
  String get databaseRestoredSuccess =>
      'Database restored successfully from Google Drive!';

  @override
  String get noBackupFound => 'No backup found in Google Drive';

  @override
  String get backupSuccess => 'Backup uploaded successfully to Google Drive';

  @override
  String get restoreSuccess => 'Data restored successfully from Google Drive';

  @override
  String get restoreWarning =>
      'Restoring will replace all current local data with the cloud backup. Do you want to continue?';

  @override
  String get backupInProgress => 'Creating and uploading encrypted backup...';

  @override
  String get restoreInProgress => 'Downloading and restoring data...';

  @override
  String get autoBackup => 'Automatic Cloud Backup';

  @override
  String get autoBackupDesc =>
      'Automatically back up database when changes occur';

  @override
  String get categoryFoodDining => 'Food & Dining';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryTransportation => 'Transportation';

  @override
  String get categoryHousing => 'Housing & Rent';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealthcare => 'Healthcare';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryPersonalCare => 'Personal Care';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryOtherExpense => 'Other Expense';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryFreelance => 'Freelance';

  @override
  String get categoryInvestments => 'Investments';

  @override
  String get categoryOtherIncome => 'Other Income';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidAmount => 'Please enter a valid positive amount';

  @override
  String get validationSameAccount =>
      'Source and destination accounts must be different';

  @override
  String get currencyConversion => 'Currency Conversion';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get customRate => 'Custom Rate';

  @override
  String get editExchangeRate => 'Edit Exchange Rate';

  @override
  String get setCustomRate => 'Set Custom Rate';

  @override
  String get resetRate => 'Reset to Live Rate';

  @override
  String get debitedAmount => 'Debited from account';

  @override
  String get creditedAmount => 'Credited to account';

  @override
  String rateUnitFormat(String from, String rate, String to) {
    return '1 $from = $rate $to';
  }

  @override
  String get refreshRateTooltip => 'Refresh live exchange rate';

  @override
  String get exchangeRateHint => 'Live rate from open.er-api.com';

  @override
  String get ratePlaceholder => 'Exchange rate (e.g. 4150.0)';

  @override
  String get customRateActive => 'Custom rate applied';

  @override
  String get originalAmount => 'Original Amount';
}
