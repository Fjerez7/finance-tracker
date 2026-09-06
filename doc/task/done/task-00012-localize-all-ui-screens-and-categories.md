---
id: task-00012-localize-all-ui-screens-and-categories
type: task
code: "00012"
slug: localize-all-ui-screens-and-categories
title: Localize All UI Screens and Categories
description: Extract and refactor hardcoded strings across all UI screens, widgets, dialogs, enums, and system categories to consume AppLocalizations.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - flutter
  - ui
  - i18n
  - localization
  - refactor
related:
  - rfc-00002-i18n-currency-settings
  - plan-00002-i18n-currency-settings-plan
supersedes: []
superseded_by: null
---

# Task 00012: Localize All UI Screens and Categories

## 1. Prime Directive

> [!Prime Directive]
> Refactor all hardcoded UI text across screens, dialogs, form validation messages, bottom navigation items, enum labels, and system seeded categories to dynamically consume `AppLocalizations`.

## 2. Specs

- **Module:** `ui/lib/presentation/`
- **Dependencies:** `flutter_localizations`, `intl`, `provider`

## 3. Checklist

### 3.1. Phase 1 — Dashboard, Navigation, and Accounts Modules Localization

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00012
  phase: Phase 1
  language: flutter, dart
```

- [x] Localize bottom navigation bar labels in `main.dart`
- [x] Localize `DashboardScreen` and dashboard summary cards
- [x] Localize `AccountsScreen`, `AddEditAccountScreen`, `AccountDetailScreen` and account types
- [x] Quality gates passes

### 3.2. Phase 2 — Transactions, Budgets, and Subscriptions Modules Localization

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00012
  phase: Phase 2
  language: flutter, dart
```

- [x] Localize `TransactionListScreen`, `QuickTransactionScreen`, `TransactionDetailScreen`
- [x] Localize `BudgetsScreen`, `AddEditBudgetScreen`, `SavingsGoalsScreen`, `AddEditSavingsGoalScreen`
- [x] Localize `SubscriptionsScreen`, `AddEditSubscriptionScreen`
- [x] Localize `AnalyticsScreen` and `BackupSettingsScreen`
- [x] Implement system category key translation mapper (`groceries`, `salary`, `dining`, etc.)
- [x] Quality gates passes

