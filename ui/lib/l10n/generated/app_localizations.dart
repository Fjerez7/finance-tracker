import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Finance Tracker'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get navSubscriptions;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @monthlyCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cash Flow'**
  String get monthlyCashFlow;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions yet'**
  String get noRecentTransactions;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// No description provided for @activeBudgets.
  ///
  /// In en, this message translates to:
  /// **'Active Budgets'**
  String get activeBudgets;

  /// No description provided for @upcomingSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Subscriptions'**
  String get upcomingSubscriptions;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @currentDebt.
  ///
  /// In en, this message translates to:
  /// **'CURRENT DEBT'**
  String get currentDebt;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimit;

  /// No description provided for @includeInNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Include in Net Worth'**
  String get includeInNetWorth;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? All associated transactions will also be deleted.'**
  String get confirmDeleteAccount;

  /// No description provided for @confirmDeleteAccountNamed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{accountName}\"? This action cannot be undone.'**
  String confirmDeleteAccountNamed(String accountName);

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found. Create one to get started!'**
  String get noAccountsFound;

  /// No description provided for @noAccountsFoundCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'No accounts found. Please create one first.'**
  String get noAccountsFoundCreateFirst;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get accountNotFound;

  /// No description provided for @adjustBalance.
  ///
  /// In en, this message translates to:
  /// **'Adjust Balance'**
  String get adjustBalance;

  /// No description provided for @adjustBalanceFor.
  ///
  /// In en, this message translates to:
  /// **'Adjust Balance for {accountName}'**
  String adjustBalanceFor(String accountName);

  /// No description provided for @enterNewReconciledBalance.
  ///
  /// In en, this message translates to:
  /// **'Enter the new reconciled balance:'**
  String get enterNewReconciledBalance;

  /// No description provided for @newBalance.
  ///
  /// In en, this message translates to:
  /// **'New Balance'**
  String get newBalance;

  /// No description provided for @updateBalance.
  ///
  /// In en, this message translates to:
  /// **'Update Balance'**
  String get updateBalance;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountQuestion;

  /// No description provided for @unarchiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Account'**
  String get unarchiveAccount;

  /// No description provided for @archiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Archive Account'**
  String get archiveAccount;

  /// No description provided for @creditLimitAndUtilization.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit & Utilization'**
  String get creditLimitAndUtilization;

  /// No description provided for @availableCredit.
  ///
  /// In en, this message translates to:
  /// **'Available Credit'**
  String get availableCredit;

  /// No description provided for @totalLimit.
  ///
  /// In en, this message translates to:
  /// **'Total Limit'**
  String get totalLimit;

  /// No description provided for @availableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount}'**
  String availableAmount(String amount);

  /// No description provided for @creditUsedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{percentage} used of {total}'**
  String creditUsedOfTotal(String percentage, String total);

  /// No description provided for @accountTypeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get accountTypeChecking;

  /// No description provided for @accountTypeSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// No description provided for @accountTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get accountTypeCreditCard;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get accountTypeInvestment;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get accountTypeBank;

  /// No description provided for @accountTypeDigitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get accountTypeDigitalWallet;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// No description provided for @quickTransaction.
  ///
  /// In en, this message translates to:
  /// **'Quick Transaction'**
  String get quickTransaction;

  /// No description provided for @transactionDetail.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetail;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @accountTransfer.
  ///
  /// In en, this message translates to:
  /// **'Account Transfer'**
  String get accountTransfer;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// No description provided for @sourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Source Account'**
  String get sourceAccount;

  /// No description provided for @destinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Destination Account'**
  String get destinationAccount;

  /// No description provided for @payee.
  ///
  /// In en, this message translates to:
  /// **'Payee / Merchant'**
  String get payee;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeleted;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get confirmDeleteTransaction;

  /// No description provided for @confirmDeleteTransactionDetail.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this transaction and automatically reverse its effect on your account balance.'**
  String get confirmDeleteTransactionDetail;

  /// No description provided for @deleteTransactionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteTransactionQuestion;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// No description provided for @filterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get filterExpenses;

  /// No description provided for @filterTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get filterTransfer;

  /// No description provided for @filterTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get filterTransfers;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesFound;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully'**
  String get transactionSaved;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes or descriptions...'**
  String get searchHint;

  /// No description provided for @netFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Flow'**
  String get netFlow;

  /// No description provided for @tapPlusToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to record a new transaction.'**
  String get tapPlusToRecord;

  /// No description provided for @toggleNoteAndDate.
  ///
  /// In en, this message translates to:
  /// **'Toggle Note & Date'**
  String get toggleNoteAndDate;

  /// No description provided for @noteOrDescription.
  ///
  /// In en, this message translates to:
  /// **'Note / Description'**
  String get noteOrDescription;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change Date'**
  String get changeDate;

  /// No description provided for @transferDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Transfer Destination Account:'**
  String get transferDestinationAccount;

  /// No description provided for @confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get confirmTransfer;

  /// No description provided for @pleaseEnterAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount greater than 0'**
  String get pleaseEnterAmountGreaterThanZero;

  /// No description provided for @pleaseSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get pleaseSelectAccount;

  /// No description provided for @pleaseSelectDifferentDestination.
  ///
  /// In en, this message translates to:
  /// **'Please select a different destination account'**
  String get pleaseSelectDifferentDestination;

  /// No description provided for @recordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{type} recorded successfully!'**
  String recordedSuccessfully(String type);

  /// No description provided for @errorSavingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Error saving transaction: {error}'**
  String errorSavingTransaction(String error);

  /// No description provided for @unknownAccount.
  ///
  /// In en, this message translates to:
  /// **'Unknown Account'**
  String get unknownAccount;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @budgetsAndGoals.
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get budgetsAndGoals;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @setCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Category Budget'**
  String get setCategoryBudget;

  /// No description provided for @budgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'BUDGET PERIOD'**
  String get budgetPeriod;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @monthlySpendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending Limit'**
  String get monthlySpendingLimit;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseEnterBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Please enter budget limit'**
  String get pleaseEnterBudgetLimit;

  /// No description provided for @limitMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Limit must be greater than 0'**
  String get limitMustBeGreaterThanZero;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// No description provided for @budgetUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get budgetUpdatedSuccess;

  /// No description provided for @budgetSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget set successfully'**
  String get budgetSetSuccess;

  /// No description provided for @errorSavingBudget.
  ///
  /// In en, this message translates to:
  /// **'Error saving budget: {error}'**
  String errorSavingBudget(String error);

  /// No description provided for @deleteBudgetLimitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget Limit?'**
  String get deleteBudgetLimitQuestion;

  /// No description provided for @confirmDeleteBudgetDetail.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this category budget limit? Past recorded transactions will remain unaffected.'**
  String get confirmDeleteBudgetDetail;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonth;

  /// No description provided for @totalMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'TOTAL MONTHLY BUDGET'**
  String get totalMonthlyBudget;

  /// No description provided for @percentSpent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% spent'**
  String percentSpent(int percent);

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofAmount(String amount);

  /// No description provided for @totalBudgetExceededBy.
  ///
  /// In en, this message translates to:
  /// **'Total budget exceeded by {amount}'**
  String totalBudgetExceededBy(String amount);

  /// No description provided for @amountLeftForMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} left for the month'**
  String amountLeftForMonth(String amount);

  /// No description provided for @categoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get categoryBudgets;

  /// No description provided for @configuredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} configured'**
  String configuredCount(int count);

  /// No description provided for @noBudgetsSetForMonth.
  ///
  /// In en, this message translates to:
  /// **'No budgets set for this month'**
  String get noBudgetsSetForMonth;

  /// No description provided for @setMonthlyLimitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set monthly category limits to keep your spending on track by tapping \"+\"'**
  String get setMonthlyLimitsDesc;

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Category Budget'**
  String get categoryBudget;

  /// No description provided for @budgetExceededBy.
  ///
  /// In en, this message translates to:
  /// **'Exceeded by {amount}'**
  String budgetExceededBy(String amount);

  /// No description provided for @budgetApproachingLimit.
  ///
  /// In en, this message translates to:
  /// **'Approaching limit ({percent}%)'**
  String budgetApproachingLimit(int percent);

  /// No description provided for @budgetRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemainingAmount(String amount);

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Budget Limit'**
  String get budgetLimit;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @noBudgetsFound.
  ///
  /// In en, this message translates to:
  /// **'No budgets created for this month'**
  String get noBudgetsFound;

  /// No description provided for @confirmDeleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get confirmDeleteBudget;

  /// No description provided for @addSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Savings Goal'**
  String get addSavingsGoal;

  /// No description provided for @editSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Savings Goal'**
  String get editSavingsGoal;

  /// No description provided for @newSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'New Savings Goal'**
  String get newSavingsGoal;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal Reached!'**
  String get goalReached;

  /// No description provided for @addFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get addFunds;

  /// No description provided for @withdrawFunds.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get withdrawFunds;

  /// No description provided for @noSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'No savings goals created yet'**
  String get noSavingsGoals;

  /// No description provided for @confirmDeleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this savings goal?'**
  String get confirmDeleteGoal;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String activeCount(int count);

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String completedCount(int count);

  /// No description provided for @noActiveSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'No active savings goals'**
  String get noActiveSavingsGoals;

  /// No description provided for @savingsGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set savings targets for vacations, emergency funds, or gadgets by tapping \"+\"'**
  String get savingsGoalsDesc;

  /// No description provided for @noCompletedGoals.
  ///
  /// In en, this message translates to:
  /// **'No completed goals yet'**
  String get noCompletedGoals;

  /// No description provided for @completedGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Goals you reach 100% will be celebrated here'**
  String get completedGoalsDesc;

  /// No description provided for @depositToGoal.
  ///
  /// In en, this message translates to:
  /// **'Deposit to {goalName}'**
  String depositToGoal(String goalName);

  /// No description provided for @depositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount'**
  String get depositAmount;

  /// No description provided for @pleaseEnterDepositAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter deposit amount'**
  String get pleaseEnterDepositAmount;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @depositedIntoGoal.
  ///
  /// In en, this message translates to:
  /// **'Deposited {amount} into {goalName}!'**
  String depositedIntoGoal(String amount, String goalName);

  /// No description provided for @errorDepositingFunds.
  ///
  /// In en, this message translates to:
  /// **'Error depositing funds: {error}'**
  String errorDepositingFunds(String error);

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Emergency Fund, Japan Trip, New Laptop'**
  String get goalTitleHint;

  /// No description provided for @pleaseEnterGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a goal title'**
  String get pleaseEnterGoalTitle;

  /// No description provided for @targetSavingsAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Savings Amount'**
  String get targetSavingsAmount;

  /// No description provided for @pleaseEnterTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the target amount'**
  String get pleaseEnterTargetAmount;

  /// No description provided for @targetAmountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Target amount must be greater than 0'**
  String get targetAmountMustBeGreaterThanZero;

  /// No description provided for @currentSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Saved Amount'**
  String get currentSavedAmount;

  /// No description provided for @pleaseEnterCurrentSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter current saved amount'**
  String get pleaseEnterCurrentSavedAmount;

  /// No description provided for @amountCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be negative'**
  String get amountCannotBeNegative;

  /// No description provided for @targetDeadlineOptional.
  ///
  /// In en, this message translates to:
  /// **'Target Deadline (Optional)'**
  String get targetDeadlineOptional;

  /// No description provided for @noDeadlineSet.
  ///
  /// In en, this message translates to:
  /// **'No deadline set'**
  String get noDeadlineSet;

  /// No description provided for @setDate.
  ///
  /// In en, this message translates to:
  /// **'Set Date'**
  String get setDate;

  /// No description provided for @selectGoalColor.
  ///
  /// In en, this message translates to:
  /// **'Select Goal Color'**
  String get selectGoalColor;

  /// No description provided for @selectGoalIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Goal Icon'**
  String get selectGoalIcon;

  /// No description provided for @createSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Savings Goal'**
  String get createSavingsGoal;

  /// No description provided for @savingsGoalUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Savings goal updated successfully'**
  String get savingsGoalUpdatedSuccess;

  /// No description provided for @savingsGoalCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Savings goal created successfully'**
  String get savingsGoalCreatedSuccess;

  /// No description provided for @errorSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'Error saving goal: {error}'**
  String errorSavingGoal(String error);

  /// No description provided for @deleteSavingsGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Savings Goal?'**
  String get deleteSavingsGoalQuestion;

  /// No description provided for @confirmDeleteSavingsGoalDetail.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{goalName}\"? Recorded transactions will remain unaffected.'**
  String confirmDeleteSavingsGoalDetail(String goalName);

  /// No description provided for @completedTag.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedTag;

  /// No description provided for @targetDeadlineDate.
  ///
  /// In en, this message translates to:
  /// **'Target: {date}'**
  String targetDeadlineDate(String date);

  /// No description provided for @noTargetDeadline.
  ///
  /// In en, this message translates to:
  /// **'No target deadline'**
  String get noTargetDeadline;

  /// No description provided for @savedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} saved'**
  String savedAmount(String amount);

  /// No description provided for @targetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String targetAmountLabel(String amount);

  /// No description provided for @needMonthlySavings.
  ///
  /// In en, this message translates to:
  /// **'Need ~{amount}/mo to reach target on time'**
  String needMonthlySavings(String amount);

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @subscriptionsAndBills.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions & Bills'**
  String get subscriptionsAndBills;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'Edit Subscription'**
  String get editSubscription;

  /// No description provided for @createSubscription.
  ///
  /// In en, this message translates to:
  /// **'Create Subscription'**
  String get createSubscription;

  /// No description provided for @billingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle'**
  String get billingCycle;

  /// No description provided for @billingDay.
  ///
  /// In en, this message translates to:
  /// **'Billing Day'**
  String get billingDay;

  /// No description provided for @nextPayment.
  ///
  /// In en, this message translates to:
  /// **'Next Payment'**
  String get nextPayment;

  /// No description provided for @monthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Total'**
  String get monthlyTotal;

  /// No description provided for @yearlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Yearly Total'**
  String get yearlyTotal;

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get activeSubscriptions;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @autoRegister.
  ///
  /// In en, this message translates to:
  /// **'Auto-register Transaction'**
  String get autoRegister;

  /// No description provided for @confirmDeleteSubscription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this subscription?'**
  String get confirmDeleteSubscription;

  /// No description provided for @noSubscriptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions found'**
  String get noSubscriptionsFound;

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// No description provided for @freqBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Bi-weekly'**
  String get freqBiweekly;

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqMonthly;

  /// No description provided for @freqYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get freqYearly;

  /// No description provided for @freqAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get freqAnnual;

  /// No description provided for @pausedCount.
  ///
  /// In en, this message translates to:
  /// **'Paused ({count})'**
  String pausedCount(int count);

  /// No description provided for @monthlySubscriptionCommitment.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY SUBSCRIPTION COMMITMENT'**
  String get monthlySubscriptionCommitment;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get perMonth;

  /// No description provided for @annualProjection.
  ///
  /// In en, this message translates to:
  /// **'Annual Projection: {amount}/year'**
  String annualProjection(String amount);

  /// No description provided for @noActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions'**
  String get noActiveSubscriptions;

  /// No description provided for @subscriptionsActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Track fixed commitments like Netflix, Spotify, or Rent by tapping \"+\"'**
  String get subscriptionsActiveDesc;

  /// No description provided for @noPausedSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No paused subscriptions'**
  String get noPausedSubscriptions;

  /// No description provided for @pausedSubscriptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Paused subscriptions will appear here'**
  String get pausedSubscriptionsDesc;

  /// No description provided for @postPaymentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Post {subName} Payment?'**
  String postPaymentQuestion(String subName);

  /// No description provided for @confirmPaymentDetail.
  ///
  /// In en, this message translates to:
  /// **'This will create a real expense transaction of {amount} from \"{accountName}\" and advance the next due date.'**
  String confirmPaymentDetail(String amount, String accountName);

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @paymentRecordedFor.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded for {subName}!'**
  String paymentRecordedFor(String subName);

  /// No description provided for @errorPostingPayment.
  ///
  /// In en, this message translates to:
  /// **'Error posting payment: {error}'**
  String errorPostingPayment(String error);

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get serviceName;

  /// No description provided for @serviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Netflix, Spotify, Gym, Rent'**
  String get serviceNameHint;

  /// No description provided for @pleaseEnterServiceName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a service name'**
  String get pleaseEnterServiceName;

  /// No description provided for @periodicAmount.
  ///
  /// In en, this message translates to:
  /// **'Periodic Amount'**
  String get periodicAmount;

  /// No description provided for @pleaseEnterPeriodicAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the periodic amount'**
  String get pleaseEnterPeriodicAmount;

  /// No description provided for @billingFrequency.
  ///
  /// In en, this message translates to:
  /// **'Billing Frequency'**
  String get billingFrequency;

  /// No description provided for @accountToDebit.
  ///
  /// In en, this message translates to:
  /// **'Account to Debit'**
  String get accountToDebit;

  /// No description provided for @nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next Due Date'**
  String get nextDueDate;

  /// No description provided for @monthlyBillingDay.
  ///
  /// In en, this message translates to:
  /// **'Monthly Billing Day:'**
  String get monthlyBillingDay;

  /// No description provided for @billingDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String billingDayNumber(int day);

  /// No description provided for @autoRegisterTransaction.
  ///
  /// In en, this message translates to:
  /// **'Auto-register transaction'**
  String get autoRegisterTransaction;

  /// No description provided for @autoRegisterDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically post transaction on due date without manual confirmation'**
  String get autoRegisterDesc;

  /// No description provided for @activeCommitment.
  ///
  /// In en, this message translates to:
  /// **'Active Commitment'**
  String get activeCommitment;

  /// No description provided for @activeCommitmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Include in monthly burn rate and payment schedules'**
  String get activeCommitmentDesc;

  /// No description provided for @subscriptionUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated successfully'**
  String get subscriptionUpdatedSuccess;

  /// No description provided for @subscriptionAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription added successfully'**
  String get subscriptionAddedSuccess;

  /// No description provided for @errorSavingSubscription.
  ///
  /// In en, this message translates to:
  /// **'Error saving subscription: {error}'**
  String errorSavingSubscription(String error);

  /// No description provided for @deleteSubscriptionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription?'**
  String get deleteSubscriptionQuestion;

  /// No description provided for @confirmDeleteSubscriptionDetail.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{subName}\"? Past recorded transactions will remain unaffected.'**
  String confirmDeleteSubscriptionDetail(String subName);

  /// No description provided for @pausedTag.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get pausedTag;

  /// No description provided for @payAndAdvance.
  ///
  /// In en, this message translates to:
  /// **'Pay & Advance'**
  String get payAndAdvance;

  /// No description provided for @autoRegistersOnDueDate.
  ///
  /// In en, this message translates to:
  /// **'Auto-registers on due date'**
  String get autoRegistersOnDueDate;

  /// No description provided for @manualConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Manual confirmation'**
  String get manualConfirmation;

  /// No description provided for @overdueDays.
  ///
  /// In en, this message translates to:
  /// **'Overdue ({days} days)'**
  String overdueDays(int days);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days ({date})'**
  String dueInDays(int days, String date);

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @visualAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Visual Analytics'**
  String get visualAnalytics;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @incomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by Category'**
  String get incomeByCategory;

  /// No description provided for @cashFlowTrend.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Trend'**
  String get cashFlowTrend;

  /// No description provided for @monthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// No description provided for @noAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to display analytics'**
  String get noAnalyticsData;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get last90Days;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @monthOverMonthSpendDelta.
  ///
  /// In en, this message translates to:
  /// **'Month-over-Month Spend Delta'**
  String get monthOverMonthSpendDelta;

  /// No description provided for @momIncreaseDesc.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more than last month ({amount})'**
  String momIncreaseDesc(String percent, String amount);

  /// No description provided for @momDecreaseDesc.
  ///
  /// In en, this message translates to:
  /// **'{percent}% less than last month ({amount})'**
  String momDecreaseDesc(String percent, String amount);

  /// No description provided for @sixMonthCashFlowComparison.
  ///
  /// In en, this message translates to:
  /// **'6-Month Cash Flow Comparison'**
  String get sixMonthCashFlowComparison;

  /// No description provided for @categoryExpenseProportions.
  ///
  /// In en, this message translates to:
  /// **'Category Expense Proportions'**
  String get categoryExpenseProportions;

  /// No description provided for @noCashflowData.
  ///
  /// In en, this message translates to:
  /// **'No cashflow data available'**
  String get noCashflowData;

  /// No description provided for @noExpensesPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded in this period'**
  String get noExpensesPeriod;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD - \$)'**
  String get currencyUsd;

  /// No description provided for @currencyCop.
  ///
  /// In en, this message translates to:
  /// **'Colombian Peso (COP - \$)'**
  String get currencyCop;

  /// No description provided for @dataAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataAndStorage;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @cloudBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore your data with Google Drive'**
  String get cloudBackupDesc;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvDesc.
  ///
  /// In en, this message translates to:
  /// **'Export transactions to a CSV spreadsheet file'**
  String get exportCsvDesc;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Privacy-focused, local-first personal finance tracker.'**
  String get appDescription;

  /// No description provided for @databaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Local Database'**
  String get databaseStatus;

  /// No description provided for @databaseStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Healthy (SQLite)'**
  String get databaseStatusOk;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @backupAndExport.
  ///
  /// In en, this message translates to:
  /// **'Backup & Export'**
  String get backupAndExport;

  /// No description provided for @googleDriveBackup.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Backup'**
  String get googleDriveBackup;

  /// No description provided for @googleDriveCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Cloud Sync'**
  String get googleDriveCloudSync;

  /// No description provided for @syncEncryptedSnapshotsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync encrypted snapshots to private appDataFolder'**
  String get syncEncryptedSnapshotsDesc;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get googleAccount;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get signInWithGoogle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back Up Now'**
  String get backUpNow;

  /// No description provided for @backingUp.
  ///
  /// In en, this message translates to:
  /// **'Backing up...'**
  String get backingUp;

  /// No description provided for @restoreNow.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get restoreNow;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get lastBackup;

  /// No description provided for @availableCloudBackups.
  ///
  /// In en, this message translates to:
  /// **'Available Cloud Backups'**
  String get availableCloudBackups;

  /// No description provided for @noCloudBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No cloud backups found'**
  String get noCloudBackupsFound;

  /// No description provided for @exportLedgerCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Ledger (CSV)'**
  String get exportLedgerCsv;

  /// No description provided for @exportLedgerCsvDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all {count} transactions with account and category mappings'**
  String exportLedgerCsvDesc(int count);

  /// No description provided for @csvExportPreview.
  ///
  /// In en, this message translates to:
  /// **'CSV Export Preview'**
  String get csvExportPreview;

  /// No description provided for @exportDatabaseSnapshotJson.
  ///
  /// In en, this message translates to:
  /// **'Export Database Snapshot (JSON)'**
  String get exportDatabaseSnapshotJson;

  /// No description provided for @databaseSnapshotJsonDesc.
  ///
  /// In en, this message translates to:
  /// **'Full database dump with SHA-256 integrity checksum'**
  String get databaseSnapshotJsonDesc;

  /// No description provided for @databaseSnapshotJson.
  ///
  /// In en, this message translates to:
  /// **'Database Snapshot JSON'**
  String get databaseSnapshotJson;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreCloudBackupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Restore Cloud Backup?'**
  String get restoreCloudBackupQuestion;

  /// No description provided for @confirmRestoreCloudBackupDetail.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite existing local data with the snapshot from {backupName}. Are you sure?'**
  String confirmRestoreCloudBackupDetail(String backupName);

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @cloudBackupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup created successfully!'**
  String get cloudBackupCreatedSuccess;

  /// No description provided for @databaseRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully from Google Drive!'**
  String get databaseRestoredSuccess;

  /// No description provided for @noBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup found in Google Drive'**
  String get noBackupFound;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded successfully to Google Drive'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully from Google Drive'**
  String get restoreSuccess;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring will replace all current local data with the cloud backup. Do you want to continue?'**
  String get restoreWarning;

  /// No description provided for @backupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Creating and uploading encrypted backup...'**
  String get backupInProgress;

  /// No description provided for @restoreInProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading and restoring data...'**
  String get restoreInProgress;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Cloud Backup'**
  String get autoBackup;

  /// No description provided for @autoBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically back up database when changes occur'**
  String get autoBackupDesc;

  /// No description provided for @categoryFoodDining.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get categoryFoodDining;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get categoryTransportation;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing & Rent'**
  String get categoryHousing;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get categoryHealthcare;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get categoryPersonalCare;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other Expense'**
  String get categoryOtherExpense;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get categoryFreelance;

  /// No description provided for @categoryInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get categoryInvestments;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get categoryOtherIncome;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive amount'**
  String get validationInvalidAmount;

  /// No description provided for @validationSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Source and destination accounts must be different'**
  String get validationSameAccount;

  /// No description provided for @currencyConversion.
  ///
  /// In en, this message translates to:
  /// **'Currency Conversion'**
  String get currencyConversion;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @customRate.
  ///
  /// In en, this message translates to:
  /// **'Custom Rate'**
  String get customRate;

  /// No description provided for @editExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Edit Exchange Rate'**
  String get editExchangeRate;

  /// No description provided for @setCustomRate.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Rate'**
  String get setCustomRate;

  /// No description provided for @resetRate.
  ///
  /// In en, this message translates to:
  /// **'Reset to Live Rate'**
  String get resetRate;

  /// No description provided for @debitedAmount.
  ///
  /// In en, this message translates to:
  /// **'Debited from account'**
  String get debitedAmount;

  /// No description provided for @creditedAmount.
  ///
  /// In en, this message translates to:
  /// **'Credited to account'**
  String get creditedAmount;

  /// No description provided for @rateUnitFormat.
  ///
  /// In en, this message translates to:
  /// **'1 {from} = {rate} {to}'**
  String rateUnitFormat(String from, String rate, String to);

  /// No description provided for @refreshRateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh live exchange rate'**
  String get refreshRateTooltip;

  /// No description provided for @exchangeRateHint.
  ///
  /// In en, this message translates to:
  /// **'Live rate from open.er-api.com'**
  String get exchangeRateHint;

  /// No description provided for @ratePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate (e.g. 4150.0)'**
  String get ratePlaceholder;

  /// No description provided for @customRateActive.
  ///
  /// In en, this message translates to:
  /// **'Custom rate applied'**
  String get customRateActive;

  /// No description provided for @originalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original Amount'**
  String get originalAmount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
