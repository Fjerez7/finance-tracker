---
id: plan-00001-implementacion-de-modulos-finance-tracker-v1
type: plan
code: "00001"
slug: implementacion-de-modulos-finance-tracker-v1
title: Finance Tracker v1 Modular Implementation Plan
description: Master execution plan orchestrating the end-to-end delivery of the six core functional modules of Finance Tracker v1 based on spec-00002.
category: plan
status: draft
created: 2026-09-04
updated: 2026-09-04
authors: []
tags:
  - flutter
  - clean-architecture
  - roadmap
  - plan
  - execution
related:
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - rfc-00001-arquitectura-base-de-finance-tracker
  - task-00001-inicializar-proyecto-flutter-y-estructura-base
  - task-00002-implementar-sqlite-schema-entidades-y-modelos-base
  - task-00003-implementar-modulo-cuentas-y-patrimonio-neto
  - task-00004-implementar-modulo-transacciones-rapidas-y-calculadora
  - task-00005-implementar-modulo-suscripciones-y-pagos-recurrentes
  - task-00006-implementar-modulo-presupuestos-y-metas-de-ahorro
  - task-00007-implementar-modulo-dashboard-y-analiticas-visuales
  - task-00008-implementar-modulo-backup-cloud-y-exportacion-csv
supersedes: []
superseded_by: null
aliases:
  - "PLAN 00001: Finance Tracker v1 Modular Implementation Plan"
---

# PLAN 00001: Finance Tracker v1 Modular Implementation Plan

## 1. Purpose

This master execution plan coordinates the sequential implementation, testing, and delivery of the six core functional modules comprising **Finance Tracker v1**, as formally specified in [[spec-00002-functional-modules-and-product-requirements]] and aligned with the Clean Architecture rules in [[spec-00001-estructura-de-carpetas-y-convenciones-flutter]].

By enforcing a structured, bottom-up delivery pipeline, this plan ensures that core data persistence, financial domain rules, and atomic invariants are solidly in place before layering reactive UI screens and cross-cutting cloud synchronizers.

---

## 2. Design Prerequisites

### 2.1 — Project Skeleton & Governance Base
**Task:** [[task-00001-inicializar-proyecto-flutter-y-estructura-base]] — Completed  
**Module:** `ui`

Establishes the Flutter workspace skeleton under `ui/`, core package dependencies (`provider`, `sqflite`, `fl_chart`, `intl`, `google_sign_in`, `googleapis`), and test directory mirrors.

### 2.2 — SQLite Schema, Domain Entities & Monetary Invariants
**Task:** [[task-00002-implementar-sqlite-schema-entidades-y-modelos-base]] — Completed  
**Module:** `ui`

Establishes the pure Dart domain entities, zero-float integer cent calculations, SQLite table schemas (`sqflite`), indexes, default category seeds, and data models (`*Model`) with 100% verified unit test coverage.

---

## 3. Implementation Phases

Phases are ordered by functional and architectural dependency. Each phase delivers a standalone, testable functional module.

```
+-------------------------------------------------------------------------------------------------------+
|                                    Phase Pipeline (Delivery Order)                                    |
+-------------------------------------------------------------------------------------------------------+
|                                                                                                       |
|  +---------------------------+       +---------------------------+                                    |
|  | Phase 1: Local Foundation | ----> | Phase 2: Module 1         |                                    |
|  | (SQLite, Entities, Models)|       | Accounts & Net Worth      |                                    |
|  | [COMPLETED: task-00002]   |       | [task-00003]              |                                    |
|  +---------------------------+       +-------------+-------------+                                    |
|                                                    |                                                  |
|                                                    v                                                  |
|  +---------------------------+       +---------------------------+                                    |
|  | Phase 4: Module 3         | <---- | Phase 3: Module 2         |                                    |
|  | Subscriptions & Recurring |       | Rapid Micro-Transactions  |                                    |
|  | [task-00005]              |       | & Numpad Calculator       |                                    |
|  +-------------+-------------+       | [task-00004]              |                                    |
|                |                     +---------------------------+                                    |
|                v                                                                                      |
|  +---------------------------+       +---------------------------+       +-------------------------+  |
|  | Phase 5: Module 4         | ----> | Phase 6: Module 5         | ----> | Phase 7: Module 6       |  |
|  | Budgets & Savings Goals   |       | Dashboard & Visual        |       | Google Drive Backup     |  |
|  | [task-00006]              |       | Analytics (fl_chart)      |       | & CSV Local Export      |  |
|  +---------------------------+       | [task-00007]              |       | [task-00008]            |  |
|                                      +---------------------------+       +-------------------------+  |
+-------------------------------------------------------------------------------------------------------+
```

---

### Phase 1 — Persistence & Domain Models Foundation (Completed)

**Goal:** Establish database tables, foreign keys, domain entities, and data models with integer cent monetary precision.

**Tasks:**
- [[task-00002-implementar-sqlite-schema-entidades-y-modelos-base]]

**Input:** `spec-00002` data entity and invariant specifications  
**Output:** Pure domain entities, `DatabaseHelper` with SQLite DDL, seed data, and data models (`AccountModel`, `CategoryModel`, `TransactionModel`, `SubscriptionModel`, `BudgetModel`, `SavingsGoalModel`).

---

### Phase 2 — Module 1: Accounts & Net Worth Engine

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: "task-00003-implementar-modulo-cuentas-y-patrimonio-neto"
  document-type: task
```

**Goal:** Implement full CRUD account management, credit card utilization tracking, and real-time Net Worth calculation.

**Tasks:**
- `task-00003-implementar-modulo-cuentas-y-patrimonio-neto`

**Input:** `Account` entity, `AccountModel`, SQLite `accounts` table  
**Output:** `AccountRepository`, `AccountsProvider`, `AccountsScreen`, `AddEditAccountScreen`, `AccountDetailScreen`, `AccountBalanceCard`.

- Implement `AccountRepository` contract and SQLite implementation (`AccountRepositoryImpl`).
- Implement `AccountsProvider` managing reactive state, asset vs liability segregation, and live Net Worth formula.
- Build `AccountsScreen` with Net Worth header and grouped account lists.
- Build `AddEditAccountScreen` with account type selectors, credit limit input, color palette, and icons.
- Build `AccountDetailScreen` with balance card, credit utilization gauge, and account actions.

---

### Phase 3 — Module 2: Rapid Transaction Capture Engine (Micro-Expense Numpad)

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: "task-00004-implementar-modulo-transacciones-rapidas-y-calculadora"
  document-type: task
```

**Goal:** Provide frictionless, 2-tap micro-expense logging with an integrated in-screen calculator numpad and chronological ledger.

**Tasks:**
- `task-00004-implementar-modulo-transacciones-rapidas-y-calculadora`

**Input:** `Transaction` & `Category` entities, `AccountsProvider`, `accounts` and `transactions` tables  
**Output:** `TransactionRepository`, `CategoryRepository`, `TransactionsProvider`, `QuickTransactionScreen`, `CalculatorNumpad`, `CategoryGridPicker`, `TransactionListScreen`, `TransactionDetailScreen`.

- Implement `TransactionRepository` and `CategoryRepository` with atomic balance adjustments.
- Implement `TransactionsProvider` managing transaction streams, filtering, and balance sync.
- Build custom `CalculatorNumpad` widget with live arithmetic (+, -, *, /).
- Build `QuickTransactionScreen` with 2-tap expense flow and category picker.
- Build `TransactionListScreen` with grouped chronological feeds and filters.

---

### Phase 4 — Module 3: Subscriptions & Recurring Payments Engine

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: "task-00005-implementar-modulo-suscripciones-y-pagos-recurrentes"
  document-type: task
```

**Goal:** Centralize recurring commitments, billing cycle tracking, monthly/annual projections, and automated ledger postings.

**Tasks:**
- `task-00005-implementar-modulo-suscripciones-y-pagos-recurrentes`

**Input:** `Subscription` entity, `TransactionRepository`, SQLite `subscriptions` table  
**Output:** `SubscriptionRepository`, `SubscriptionsProvider`, `SubscriptionsScreen`, `AddEditSubscriptionScreen`, `SubscriptionCard`, recurring bill auto-poster.

- Implement `SubscriptionRepository` and `SubscriptionsProvider`.
- Calculate monthly burn rate and annual spend projections.
- Build `SubscriptionsScreen` with countdown badges ("Due in 3 days", "Overdue").
- Build `AddEditSubscriptionScreen` with frequency selectors and auto-register toggles.
- Implement due-date ledger posting logic (`auto_register` vs 1-tap confirmation).

---

### Phase 5 — Module 4: Budgets & Savings Goals Engine

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: "task-00006-implementar-modulo-presupuestos-y-metas-de-ahorro"
  document-type: task
```

**Goal:** Deliver proactive monthly category budgets with 80%/100% alert thresholds and target savings goals.

**Tasks:**
- `task-00006-implementar-modulo-presupuestos-y-metas-de-ahorro`

**Input:** `Budget` & `SavingsGoal` entities, `TransactionsProvider`, SQLite `budgets` and `savings_goals` tables  
**Output:** `BudgetRepository`, `SavingsGoalRepository`, `BudgetsProvider`, `BudgetsScreen`, `SavingsGoalsScreen`, `BudgetProgressCard`, `SavingsGoalCard`.

- Implement repositories and `BudgetsProvider`.
- Compute real-time category spend vs budget limit with warning threshold chips.
- Build `BudgetsScreen` with month navigation selector.
- Build `SavingsGoalsScreen` with progress rings and monthly savings target calculators.

---

### Phase 6 — Module 5: Dashboard & Visual Analytics Engine

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: "task-00007-implementar-modulo-dashboard-y-analiticas-visuales"
  document-type: task
```

**Goal:** Assemble the executive dashboard with `fl_chart` interactive pie charts, Net Worth hero card, and month-over-month metrics.

**Tasks:**
- `task-00007-implementar-modulo-dashboard-y-analiticas-visuales`

**Input:** All state providers (`AccountsProvider`, `TransactionsProvider`, `BudgetsProvider`, `SubscriptionsProvider`)  
**Output:** `DashboardScreen`, `AnalyticsScreen`, `CategoryExpensePieChart`, `CashFlowBarChart`, `HeroNetWorthCard`.

- Build `CategoryExpensePieChart` using `fl_chart` with interactive slice touch events.
- Build `CashFlowBarChart` comparing Income vs Expense.
- Assemble `DashboardScreen` combining Hero Net Worth card, pie chart, recent transactions, and top category rankings.
- Build `AnalyticsScreen` for historical trends and month-over-month spending delta comparisons.

---

### Phase 7 — Module 6: Backup, Restore & Local Export Engine

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: "task-00008-implementar-modulo-backup-cloud-y-exportacion-csv"
  document-type: task
```

**Goal:** Provide Google Drive `appDataFolder` private backup synchronization and offline CSV data export.

**Tasks:**
- `task-00008-implementar-modulo-backup-cloud-y-exportacion-csv`

**Input:** Complete SQLite database state across all tables  
**Output:** `GoogleDriveSyncService`, `CsvExportService`, `BackupSettingsScreen`, snapshot JSON builder with SHA-256 validation, one-click restore.

- Implement `CsvExportService` generating standard CSV files and triggering OS share sheets.
- Implement `GoogleDriveSyncService` using `google_sign_in` and private `drive.appdata` scope.
- Implement structured JSON snapshot generation with SHA-256 integrity checksums.
- Implement safe one-click database restore workflow within an atomic SQLite transaction.
- Build `BackupSettingsScreen` with Google Account status and export actions.

---

## 4. Invariants

- **Integer Cents Only:** Floating-point representations (`double`, `float`) are prohibited in domain entities, data models, calculations, and database columns.
- **Local-First Independence:** All features in Phases 1 through 5 MUST function 100% offline without network connectivity.
- **Atomic Double-Entry Balances:** Every transaction creation, modification, deletion, or transfer MUST update corresponding account balances within a single atomic SQLite transaction.
- **Strict Quality Gates:** Every phase must pass `dart format`, `flutter analyze` (zero issues), and `flutter test` before closure.

---

## 5. Staff Engineer Review

### On the Overall Plan

**Gaps covered:**
1. Database schema and zero-float invariants are already established in Phase 1 (`task-00002`).
2. Dependency sequence guarantees that each module builds on fully working providers and repositories.

**Flaws to watch:**
- Complex SQLite foreign key deletions: ensuring transfer deletions or category deletions correctly adjust account balances or set category references to null without data corruption.
- State synchronization across providers: ensuring `AccountsProvider` and `TransactionsProvider` stay reactively synced.

**Tradeoffs accepted by this plan:**
- UI dashboard is completed in Phase 6 after all data providers exist, ensuring real calculations without placeholder mock data.

---

## 6. Open Questions

- **Biometric Security:** Local biometric authentication (Face ID / Fingerprint) will be scheduled as an enhancement after Phase 7.
- **Background Notifications:** Local notifications for subscription due dates will be handled via `flutter_local_notifications`.