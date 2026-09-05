---
id: spec-00002-functional-modules-and-product-requirements
type: spec
code: "00002"
slug: functional-modules-and-product-requirements
title: Functional Modules and Product Requirements Specification
description: Comprehensive functional and technical specification for the six core modules of Finance Tracker v1, detailing screens, data entities, money precision, invariants, and interaction flows.
category: interface
created: 2026-08-30
updated: 2026-08-30
authors: []
tags:
  - spec
  - functional
  - requirements
  - mobile
  - flutter
  - product
related:
  - rfc-00001-arquitectura-base-de-finance-tracker
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
supersedes: []
superseded_by: null
aliases:
  - "SPEC 00002: Functional Modules and Product Requirements Specification"
---

# SPEC 00002: Functional Modules and Product Requirements Specification

## 1. Purpose

This specification establishes the functional requirements, screen definitions, data entities, monetary calculation rules, business invariants, and user interaction flows for the six core modules comprising **Finance Tracker v1**.

Building upon the architectural foundation defined in [[rfc-00001-arquitectura-base-de-finance-tracker]] and the folder/coding standards defined in [[spec-00001-estructura-de-carpetas-y-convenciones-flutter]], this document serves as the single source of truth for the domain model and user experience contracts across the entire mobile application.

---

## 2. Definition

Finance Tracker v1 is organized into six functional modules:
1. **Accounts & Net Worth Engine**
2. **Rapid Transaction Capture (Micro-Expense Engine)**
3. **Subscriptions & Recurring Payments Engine**
4. **Budgets & Savings Goals Engine**
5. **Dashboard & Visual Analytics Engine**
6. **Backup, Restore & Local Export Engine**

```
+-------------------------------------------------------------------------------------------------------+
|                                        Finance Tracker v1 Modules                                     |
+-------------------------------------------------------------------------------------------------------+
|                                                                                                       |
|  +---------------------------+   +---------------------------+   +---------------------------------+  |
|  | 1. Accounts & Net Worth   |   | 2. Rapid Transactions     |   | 3. Subscriptions & Recurring    |  |
|  | - Banks, Wallets, Cash    |   | - 2-tap micro-expense     |   | - Fixed expenses & cut-off dates|  |
|  | - Credit cards & debts    |   | - Integrated numpad/calc  |   | - Monthly & annual projections  |  |
|  | - Real-time Net Worth     |   | - Expense/Income/Transfer |   | - Auto-post / 1-tap confirm     |  |
|  +-------------+-------------+   +-------------+-------------+   +----------------+----------------+  |
|                |                               |                                  |                   |
|                +-------------------------------+----------------------------------+                   |
|                                                |                                                      |
|  +---------------------------+   +-------------v-------------+   +---------------------------------+  |
|  | 4. Budgets & Goals        |   | 5. Dashboard & Analytics  |   | 6. Backup & Export              |  |
|  | - Category budgets (80/100)|   | - Net Worth hero card     |   | - Google Drive AppData sync     |  |
|  | - Visual progress bars    |   | - fl_chart interactive pie|   | - One-click snapshot restore    |  |
|  | - Target savings goals    |   | - Month-over-month trends |   | - Offline CSV/Excel export      |  |
|  +---------------------------+   +---------------------------+   +---------------------------------+  |
+-------------------------------------------------------------------------------------------------------+
```

---

### 2.1. Module 1: Accounts & Net Worth Engine

#### 2.1.1. Description
Provides centralized management of all liquid assets, digital wallets, physical cash, and revolving credit liabilities. Computes the user's real-time Net Worth by aggregating asset accounts and subtracting credit card debts.

#### 2.1.2. Supported Account Types
- **Bank Account (`bank`):** Traditional checking and savings accounts (e.g., Bancolombia, Chase, Wells Fargo).
- **Digital Wallet (`digital_wallet`):** Modern fintech wallets and peer-to-peer apps (e.g., Nequi, Daviplata, PayPal, Venmo).
- **Cash (`cash`):** Physical cash wallets, petty cash, or physical envelopes.
- **Credit Card (`credit_card`):** Revolving credit lines with total credit limit (`creditLimitCents`) and accumulated debt balance (`balanceCents`).

#### 2.1.3. Real-Time Net Worth Formula
$$\\text{Total Assets (Cents)} = \\sum_{A \\in \\{\\text{bank}, \\text{digital\\_wallet}, \\text{cash}\\}} A.\\text{balanceCents}$$
$$\\text{Total Liabilities (Cents)} = \\sum_{C \\in \\{\\text{credit\\_card}\\}} C.\\text{balanceCents}$$
$$\\text{Net Worth (Cents)} = \\text{Total Assets (Cents)} - \\text{Total Liabilities (Cents)}$$

For credit cards:
$$\\text{Available Credit (Cents)} = \\text{creditLimitCents} - \\text{balanceCents}$$

#### 2.1.4. Required Screens & Widgets
- **`AccountsScreen` (`lib/presentation/screens/accounts/accounts_screen.dart`):**
  - Header summary displaying Net Worth, Total Assets, and Total Liabilities.
  - Sectioned list grouping accounts into **Assets** and **Liabilities (Credit Cards)**.
  - Action to create a new account.
- **`AccountDetailScreen` (`lib/presentation/screens/accounts/account_detail_screen.dart`):**
  - Account balance card with credit utilization gauge (for credit cards).
  - Filterable transaction history specifically tied to the account.
  - Edit and archive account actions.
- **`AddEditAccountScreen` (`lib/presentation/screens/accounts/add_edit_account_screen.dart`):**
  - Form fields: Name, Account Type selector, Initial Balance, Credit Limit (conditional on `credit_card`), Currency code, Icon selector, Color picker.
- **Reusable Widgets:**
  - `AccountBalanceCard` (`lib/presentation/widgets/cards/account_balance_card.dart`): Card with balance, icon, type badge, and credit utilization bar.

#### 2.1.5. Data Entities & Money Rules
- All balance and limit values are stored as 64-bit integer cents (`int`).
- `AccountEntity`:
  - `id`: UUID string (`String`)
  - `name`: Account name (`String`, max 50 chars)
  - `type`: `AccountType` enum (`bank`, `digital_wallet`, `cash`, `credit_card`)
  - `balanceCents`: Current balance/debt in minor units (`int`)
  - `creditLimitCents`: Total credit limit in minor units (`int`, 0 for non-credit accounts)
  - `currency`: ISO 4217 currency code (`String`, e.g., `USD`, `COP`)
  - `colorHex`: Visual identifier (`String`, e.g., `#4CAF50`)
  - `iconName`: Material icon identifier (`String`, e.g., `account_balance`)
  - `isArchived`: Boolean soft-archive flag (`bool`)
  - `createdAt`: ISO 8601 UTC timestamp (`DateTime`)
  - `updatedAt`: ISO 8601 UTC timestamp (`DateTime`)

#### 2.1.6. User Interaction Flows
1. **Create Account:** User taps "+ Account" -> selects type (e.g., Credit Card) -> enters name ("Bancolombia Visa"), credit limit ($2,000.00 = 200,000 cents), and current debt ($350.00 = 35,000 cents) -> saves. Account list and Net Worth header update instantly.
2. **Reconciliation / Balance Adjustment:** User opens Account Detail -> taps "Adjust Balance" -> enters new balance -> system automatically creates a reconciliation transaction or updates balance.

---

### 2.2. Module 2: Rapid Transaction Capture (Micro-Expense Engine)

#### 2.2.1. Description
Designed specifically for frictionless, ultra-fast logging of daily micro-expenses ("gastos hormiga", e.g., coffee, snacks, parking, public transit) in under 3 seconds with minimal taps. Features a dedicated on-screen numerical calculator pad to avoid obstructive OS keyboard popups.

#### 2.2.2. Core Capabilities
- **2-Tap Micro-Expense Flow:**
  - Tap 1: Enter amount via custom on-screen numpad (with live basic arithmetic: +, -, *, /).
  - Tap 2: Tap category icon -> auto-saves with default active account and current timestamp.
- **Custom In-Screen Calculator Numpad:**
  - Big touch-friendly buttons (`0`-`9`, `.`, `C`, `backspace`, `+`, `-`, `=`, `done`).
  - Keeps user in a single cohesive flow without keyboard resizing jank.
- **Visual Category Palette:**
  - Large category grid with distinct icon badges, pastel backgrounds, and customizable colors.
- **Three Supported Transaction Types:**
  - `Expense`: Decreases source asset balance or increases credit card debt.
  - `Income`: Increases source asset balance.
  - `Transfer`: Atomic double-entry transfer moving funds from source account to destination account (`accountId` -> `toAccountId`).

#### 2.2.3. Required Screens & Widgets
- **`QuickTransactionScreen` (`lib/presentation/screens/transactions/quick_transaction_screen.dart`):**
  - Prominent amount display with currency prefix.
  - Segmented control for `Expense` / `Income` / `Transfer`.
  - In-screen calculator numpad.
  - Category selector grid with horizontal paging or scroll.
  - Account dropdown (defaults to most recently used account).
  - Optional note and custom date drawer.
- **`TransactionListScreen` (`lib/presentation/screens/transactions/transaction_list_screen.dart`):**
  - Grouped chronological transaction feed (Today, Yesterday, This Month).
  - Filter bar (by account, category, transaction type, date range).
  - Search field for notes and descriptions.
- **`TransactionDetailScreen` (`lib/presentation/screens/transactions/transaction_detail_screen.dart`):**
  - Full transaction breakdown, edit button, and delete confirmation modal.
- **Reusable Widgets:**
  - `CalculatorNumpad` (`lib/presentation/widgets/common/calculator_numpad.dart`)
  - `CategoryGridPicker` (`lib/presentation/widgets/common/category_grid_picker.dart`)
  - `TransactionListTile` (`lib/presentation/widgets/cards/transaction_list_tile.dart`)

#### 2.2.4. Data Entities & Money Rules
- `TransactionEntity`:
  - `id`: UUID string (`String`)
  - `accountId`: Source account UUID (`String`)
  - `toAccountId`: Destination account UUID for transfers (`String?`, required if type == `transfer`)
  - `categoryId`: Category UUID (`String?`, nullable for transfers)
  - `amountCents`: Transaction value in positive integer minor units (`int > 0`)
  - `type`: `TransactionType` enum (`expense`, `income`, `transfer`)
  - `description`: Text note (`String`, max 255 chars)
  - `transactionDate`: Logical transaction timestamp (`DateTime`)
  - `createdAt`: Audit timestamp (`DateTime`)
  - `updatedAt`: Audit timestamp (`DateTime`)
- `CategoryEntity`:
  - `id`: UUID string (`String`)
  - `name`: Category name (`String`, e.g., "Coffee & Snacks", "Groceries", "Salary")
  - `iconName`: Material icon key (`String`)
  - `colorHex`: Color string (`String`)
  - `type`: `CategoryType` enum (`expense`, `income`)
  - `isDefault`: Boolean system category flag (`bool`)
  - `createdAt`: ISO 8601 UTC timestamp (`DateTime`)
  - `updatedAt`: ISO 8601 UTC timestamp (`DateTime`)

#### 2.2.5. User Interaction Flows
1. **Fast Coffee Expense (2 Taps):**
   - User opens app -> taps "+" action.
   - Types `4500` (renders as `$4,500.00` / `$45.00` depending on currency locale).
   - Taps "Coffee & Snacks" category icon.
   - Transaction is committed immediately; haptic feedback confirms success.

---

### 2.3. Module 3: Subscriptions & Recurring Payments Engine

#### 2.3.1. Description
Centralizes the tracking, scheduling, and analytics for fixed recurring commitments (e.g., Netflix, Spotify, Internet, Gym, Rent, Insurance). Computes monthly and annual subscription burn rates and supports automated or one-tap ledger posting.

#### 2.3.2. Core Capabilities
- **Periodicities Supported:**
  - `weekly` (every 7 days)
  - `biweekly` (quincenal, every 14 days or 15th/30th)
  - `monthly` (every month on a specified `billingDay`)
  - `annual` (once a year on a specified date)
- **Billing Cycle & Cut-off Date Tracking:**
  - Tracks `billingDay` (1-31), `nextDueDate`, and days remaining until renewal.
  - Visual badges: "Due in 3 days", "Due tomorrow", "Overdue".
- **Ledger Posting Automation Modes:**
  - `auto_register`: App automatically inserts a real `Transaction` upon arrival of `nextDueDate` when opened.
  - `manual_confirm`: Creates an alert card on the Dashboard prompting "Confirm payment of $15.99 for Netflix from Credit Card?" with a 1-tap confirm button.
- **Analytics & Burn Rate Formulas:**
  - Normalized Monthly Cost:
    $$\\text{Monthly Cost (Cents)} = \\begin{cases}
      (\\text{amountCents} \\times 52) / 12 & \\text{if weekly} \\\\
      (\\text{amountCents} \\times 26) / 12 & \\text{if biweekly} \\\\
      \\text{amountCents} & \\text{if monthly} \\\\
      \\text{amountCents} / 12 & \\text{if annual}
    \\end{cases}$$
  - Annual Subscription Projection:
    $$\\text{Annual Projection (Cents)} = \\text{Monthly Cost (Cents)} \\times 12$$

#### 2.3.3. Required Screens & Widgets
- **`SubscriptionsScreen` (`lib/presentation/screens/subscriptions/subscriptions_screen.dart`):**
  - Top summary banner showing total monthly subscription commitment and annual projected spend.
  - List of active subscriptions sorted by next upcoming due date.
- **`AddEditSubscriptionScreen` (`lib/presentation/screens/subscriptions/add_edit_subscription_screen.dart`):**
  - Form fields: Name, Amount (`amountCents`), Frequency dropdown, First Due Date / Billing Day, Account to debit, Category, Automation mode toggle (`auto_register` vs `manual_confirm`), Notification reminder toggle.
- **Reusable Widgets:**
  - `SubscriptionCard` (`lib/presentation/widgets/cards/subscription_card.dart`): Subscription tile with service icon, next payment countdown, and monthly cost.

#### 2.3.4. Data Entities
- `SubscriptionEntity`:
  - `id`: UUID string (`String`)
  - `name`: Service/Item name (`String`, e.g., "Netflix Premium")
  - `amountCents`: Periodic charge in integer cents (`int > 0`)
  - `frequency`: `RecurrenceFrequency` enum (`weekly`, `biweekly`, `monthly`, `annual`)
  - `accountId`: Account to debit (`String`)
  - `categoryId`: Category UUID (`String`)
  - `billingDay`: Day of month for monthly bills (`int` 1-31)
  - `nextDueDate`: Next payment timestamp (`DateTime`)
  - `autoRegister`: Boolean flag (`bool`)
  - `isActive`: Boolean flag (`bool`)
  - `createdAt`: ISO 8601 UTC timestamp (`DateTime`)
  - `updatedAt`: ISO 8601 UTC timestamp (`DateTime`)

---

### 2.4. Module 4: Budgets & Savings Goals Engine

#### 2.4.1. Description
Provides proactive financial planning through monthly category spend limits and goal-oriented savings allocations. Features progressive visual indicators and early alert thresholds to prevent overspending.

#### 2.4.2. Monthly Category Budgets
- Defined per category for a specific month and year (`month`, `year`, `limitCents`).
- Real-time spend computation:
  $$\\text{Spent Cents} = \\sum_{T \\in \\text{Transactions}} T.\\text{amountCents} \\quad (\\text{matching category, month, year, type == expense})$$
  $$\\text{Progress Percentage} = (\\text{Spent Cents} / \\text{limitCents}) \\times 100$$
- **Visual Alert Thresholds:**
  - `0% - 79%` (Normal / Safe): Green progress bar.
  - `80% - 99%` (Warning Threshold): Amber / Yellow progress bar with warning chip "Approaching budget limit (80%+)".
  - `100%+` (Exceeded Threshold): Red progress bar with alert chip "Budget exceeded by $XX.XX".

#### 2.4.3. Savings Goals (Target Objectives)
- Defines concrete goals (e.g., "Emergency Fund", "Japan Trip 2027", "New Laptop").
- Parameters: Target Amount (`targetAmountCents`), Current Saved Amount (`currentAmountCents`), Target Completion Date (`targetDate`).
- **Fund Allocation Workflow:**
  - User can tap "Deposit Funds" -> enters amount -> selects source account (e.g., Bank Account) -> updates goal balance and deducts from liquid asset account if configured.
- Progress metrics: Percentage achieved, remaining amount, recommended monthly savings rate to meet target by deadline:
  $$\\text{Required Monthly Saving} = \\frac{\\text{targetAmountCents} - \\text{currentAmountCents}}{\\text{Months Remaining}}$$

#### 2.4.4. Required Screens & Widgets
- **`BudgetsScreen` (`lib/presentation/screens/budgets/budgets_screen.dart`):**
  - Month navigation selector (`< August 2026 >`).
  - Total monthly budget vs total spent overview progress gauge.
  - List of category budget progress cards.
- **`SavingsGoalsScreen` (`lib/presentation/screens/budgets/savings_goals_screen.dart`):**
  - Grid/list of active savings goal cards with visual progress rings.
  - Completed goals tab.
- **`AddEditBudgetScreen` & `AddEditSavingsGoalScreen`**
- **Reusable Widgets:**
  - `BudgetProgressCard` (`lib/presentation/widgets/cards/budget_progress_card.dart`)
  - `SavingsGoalCard` (`lib/presentation/widgets/cards/savings_goal_card.dart`)

#### 2.4.5. Data Entities
- `BudgetEntity`:
  - `id`: UUID string (`String`)
  - `categoryId`: Category UUID (`String`)
  - `month`: Month number (`int`, 1-12)
  - `year`: Gregorian year (`int`, e.g., 2026)
  - `limitCents`: Budget ceiling in integer cents (`int > 0`)
  - `createdAt`: ISO 8601 UTC timestamp (`DateTime`)
  - `updatedAt`: ISO 8601 UTC timestamp (`DateTime`)
- `SavingsGoalEntity`:
  - `id`: UUID string (`String`)
  - `name`: Goal title (`String`, e.g., "Emergency Fund")
  - `targetAmountCents`: Target value in integer cents (`int > 0`)
  - `currentAmountCents`: Accumulated funds in integer cents (`int >= 0`)
  - `targetDate`: Target completion deadline (`DateTime?`)
  - `colorHex`: Visual theme color (`String`)
  - `iconName`: Material icon key (`String`)
  - `isCompleted`: Completion status (`bool`)
  - `createdAt`: ISO 8601 UTC timestamp (`DateTime`)
  - `updatedAt`: ISO 8601 UTC timestamp (`DateTime`)

---

### 2.5. Module 5: Dashboard & Visual Analytics Engine

#### 2.5.1. Description
Serves as the executive summary and analytical command center of Finance Tracker. Surfaces critical balance indicators, interactive visual distributions via `fl_chart`, and month-over-month comparative metrics.

#### 2.5.2. Dashboard Visual Elements
1. **Hero Net Worth Card:**
   - Big typographic Net Worth total.
   - Asset breakdown pill (Banks + Cash) and Liability pill (Credit Card Debt).
   - Monthly cash flow mini-bar: Income vs Expense vs Net Savings.
2. **Interactive Expense Distribution Pie/Donut Chart:**
   - Built using the `fl_chart` package.
   - Slices representing category expense proportions for the selected period.
   - Interactive touch events: Tapping a slice highlights category name, spent amount in cents, and exact percentage.
3. **Month-over-Month Comparative Analytics:**
   - Compares Current Month total expense against Previous Month total expense at the same relative calendar day.
   - Delta metric: `Delta % = ((Current Month Spend - Previous Month Spend) / Previous Month Spend) * 100`.
4. **Top Spending Categories Rank List:**
   - Top 5 expense categories sorted in descending order by spend with progress bar indicators.
5. **Recent Transactions Feed:**
   - Quick list of the last 5 transactions with 1-tap navigation to the full transaction ledger.

#### 2.5.3. Required Screens & Widgets
- **`DashboardScreen` (`lib/presentation/screens/dashboard/dashboard_screen.dart`):** Main tab screen assembling hero cards, chart widgets, and feeds.
- **`AnalyticsScreen` (`lib/presentation/screens/analytics/analytics_screen.dart`):** Dedicated deep-dive analytics screen with monthly cash flow bar charts, historical trends, and category comparisons.
- **Reusable Chart Widgets:**
  - `CategoryExpensePieChart` (`lib/presentation/widgets/charts/category_expense_pie_chart.dart`): Interactive `fl_chart` `PieChart` wrapper.
  - `CashFlowBarChart` (`lib/presentation/widgets/charts/cash_flow_bar_chart.dart`): Monthly income vs expense comparison bars.

#### 2.5.4. Data Aggregation Contracts (DTOs)
```dart
class CategoryExpenseSummary {
  final String categoryId;
  final String categoryName;
  final String colorHex;
  final String iconName;
  final int totalSpentCents;
  final double percentage; // e.g., 24.5%

  const CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.colorHex,
    required this.iconName,
    required this.totalSpentCents,
    required this.percentage,
  });
}

class MonthOverMonthComparison {
  final int currentMonthSpentCents;
  final int previousMonthSpentCents;
  final double percentageDelta; // e.g., +12.3% or -5.1%
  final bool isSpendingHigher;

  const MonthOverMonthComparison({
    required this.currentMonthSpentCents,
    required this.previousMonthSpentCents,
    required this.percentageDelta,
    required this.isSpendingHigher,
  });
}
```

---

### 2.6. Module 6: Backup, Restore & Local Export Engine

#### 2.6.1. Description
Guarantees absolute data sovereignty and loss prevention for the local-first architecture. Integrates Google Sign-In with private Google Drive `appDataFolder` backup synchronization alongside offline CSV/Excel data export capabilities.

#### 2.6.2. Google Drive AppData Synchronization Flow
- **Authentication:** Authenticates the user via `google_sign_in` requesting strictly the `https://www.googleapis.com/auth/drive.appdata` scope.
- **Private Storage Guarantee:** Files created in `appDataFolder` are hidden from standard Google Drive file browsing, protecting financial backups from accidental deletion by the user or third-party apps.
- **Backup Snapshot Format:**
  - File naming pattern: `finance_tracker_backup_v1_<ISO8601_TIMESTAMP>.json`.
  - Structured, validated JSON payload encapsulating schema version, timestamp, integrity checksum (SHA-256), and complete database tables (`accounts`, `categories`, `transactions`, `subscriptions`, `budgets`, `savings_goals`).
- **One-Click Restore Workflow:**
  1. App queries `appDataFolder` for available snapshot files.
  2. Displays list of available backups with timestamps, file size, and total transaction count.
  3. User selects a snapshot -> confirms restoration prompt (with explicit warning of local overwrite).
  4. System validates JSON checksum and schema version.
  5. Executes SQLite transaction: clears local tables -> inserts snapshot rows -> reloads all Provider state stores.

#### 2.6.3. Local Data Export (CSV / Excel)
- Offline generation of standard comma-separated values (CSV) containing full transaction history:
  - Columns: `Date`, `Type`, `Account`, `ToAccount`, `Category`, `Amount`, `Currency`, `Description`, `CreatedAt`
- Triggers native OS share sheet (`share_plus`) enabling the user to save to Files, send via email, or open in spreadsheet viewers.

#### 2.6.4. Required Screens & Widgets
- **`BackupSettingsScreen` (`lib/presentation/screens/settings/backup_settings_screen.dart`):**
  - Google Account status tile (Connected user avatar/email, Disconnect button).
  - "Backup to Google Drive Now" primary action button with progress spinner.
  - "Restore from Cloud" list showing backup snapshots.
  - "Export to CSV / Excel" local export action.
  - Auto-backup toggle (e.g., Weekly when connected to Wi-Fi).

#### 2.6.5. Backup Snapshot Schema
```json
{
  "version": 1,
  "exportedAt": "2026-08-30T17:00:00.000Z",
  "checksumSha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "data": {
    "accounts": [],
    "categories": [],
    "transactions": [],
    "subscriptions": [],
    "budgets": [],
    "savingsGoals": []
  }
}
```

---

## 3. Invariants

1. **Integer Money Precision (Zero Float Invariant):**
   - Every monetary property (`balanceCents`, `creditLimitCents`, `amountCents`, `limitCents`, `targetAmountCents`, `currentAmountCents`) MUST be represented as an exact 64-bit integer (`int`) in minor currency units (cents).
   - Floating-point representations (`double`, `float`) are prohibited in domain entities, data models, calculations, and SQLite columns.

2. **Real-Time Net Worth Invariant:**
   - Net Worth MUST always equal total assets minus total liabilities across all non-archived accounts:
     $$\\text{Net Worth} = \\sum \\text{Assets} - \\sum \\text{Liabilities}$$
   - Any transaction creation, update, or deletion MUST synchronously update the associated account balance within an atomic SQLite transaction.

3. **Transfer Integrity Invariant:**
   - A transaction with `type == TransactionType.transfer` MUST provide both `accountId` (source) and `toAccountId` (destination), where `accountId != toAccountId`.
   - Category (`categoryId`) is optional for transfers. The debit and credit across both accounts must occur atomically.

4. **Non-Negative Amount Invariant:**
   - `amountCents` for transactions, budgets, subscriptions, and savings goal targets MUST always be strictly positive (`amountCents > 0`).

5. **Local-First Offline Independence:**
   - All core features (creating accounts, logging transactions, viewing analytics, managing budgets) MUST function 100% offline without network connectivity. Network access is restricted exclusively to Google Drive cloud backup synchronization.

6. **Backup Integrity Validation:**
   - A cloud backup snapshot MUST NOT be restored into the local SQLite database if the schema version is incompatible or if the payload fails checksum validation.

---

## 4. Examples

### 4.1. Domain Entity Definitions (`lib/domain/entities/`)

#### 4.1.1. Account Entity
```dart
enum AccountType { bank, digitalWallet, cash, creditCard }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final int balanceCents;
  final int creditLimitCents;
  final String currency;
  final String colorHex;
  final String iconName;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceCents,
    this.creditLimitCents = 0,
    required this.currency,
    required this.colorHex,
    required this.iconName,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCreditCard => type == AccountType.creditCard;
  int get availableCreditCents => isCreditCard ? creditLimitCents - balanceCents : 0;
  double get creditUtilizationRate => (isCreditCard && creditLimitCents > 0)
      ? (balanceCents / creditLimitCents).clamp(0.0, 1.0)
      : 0.0;
}
```

#### 4.1.2. Subscription Entity
```dart
enum RecurrenceFrequency { weekly, biweekly, monthly, annual }

class Subscription {
  final String id;
  final String name;
  final int amountCents;
  final RecurrenceFrequency frequency;
  final String accountId;
  final String categoryId;
  final int billingDay;
  final DateTime nextDueDate;
  final bool autoRegister;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.frequency,
    required this.accountId,
    required this.categoryId,
    required this.billingDay,
    required this.nextDueDate,
    this.autoRegister = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  int get monthlyEquivalentCents {
    switch (frequency) {
      case RecurrenceFrequency.weekly:
        return (amountCents * 52) ~/ 12;
      case RecurrenceFrequency.biweekly:
        return (amountCents * 26) ~/ 12;
      case RecurrenceFrequency.monthly:
        return amountCents;
      case RecurrenceFrequency.annual:
        return amountCents ~/ 12;
    }
  }

  int get annualProjectionCents => monthlyEquivalentCents * 12;
}
```

#### 4.1.3. Savings Goal Entity
```dart
class SavingsGoal {
  final String id;
  final String name;
  final int targetAmountCents;
  final int currentAmountCents;
  final DateTime? targetDate;
  final String colorHex;
  final String iconName;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmountCents,
    this.currentAmountCents = 0,
    this.targetDate,
    required this.colorHex,
    required this.iconName,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage => targetAmountCents > 0
      ? (currentAmountCents / targetAmountCents).clamp(0.0, 1.0)
      : 0.0;

  int get remainingAmountCents => (targetAmountCents - currentAmountCents).clamp(0, targetAmountCents);
}
```

### 4.2. Concrete CSV Export Example
```csv
Date,Type,Account,ToAccount,Category,Amount,Currency,Description,CreatedAt
2026-08-30,expense,Bancolombia,,Coffee & Snacks,4.50,USD,Espresso and Croissant,2026-08-30T14:30:00.000Z
2026-08-30,transfer,Bancolombia,Nequi,,50.00,USD,Wallet top-up,2026-08-30T14:35:00.000Z
2026-08-29,income,Bancolombia,,Salary,2500.00,USD,Biweekly payroll,2026-08-29T09:00:00.000Z
```

---

## 5. Open Questions

- **Biometric Lock (Face ID / Fingerprint):** Should an optional local biometric passcode gate be included in the v1 Settings module or scheduled for v1.1?
- **Recurring Notification Scheduler:** Which local background notification mechanism (`flutter_local_notifications` or `workmanager`) is optimal for background subscription due date alerts when the app is closed?
