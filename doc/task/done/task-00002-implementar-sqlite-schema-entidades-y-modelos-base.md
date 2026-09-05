---
id: task-00002-implementar-sqlite-schema-entidades-y-modelos-base
type: task
code: "00002"
slug: implementar-sqlite-schema-entidades-y-modelos-base
title: Implement SQLite Schema, Domain Entities, and Base Data Models
description: Implement SQLite database infrastructure, tables, indices, domain entities, and data models with full integer-cent precision across all core entities.
status: done
created: 2026-09-04
updated: 2026-09-04
tags:
  - flutter
  - sqlite
  - sqflite
  - domain
  - data-models
  - persistence
related:
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - rfc-00001-arquitectura-base-de-finance-tracker
supersedes: []
superseded_by: null
---

# Task 00002: Implement SQLite Schema, Domain Entities, and Base Data Models

## 1. Prime Directive

> [!Prime Directive]
> Establish the local persistence foundation and domain data layer in `ui/` by implementing pure Dart domain entities, SQLite table schemas (`sqflite`), data models with bidirectional Map serialization, and zero-float integer cents monetary invariants specified in `spec-00002`.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `sqflite`, `path`, `intl`, `flutter_test`

## 3. Checklist

### 3.1. Phase 1 — Domain Entities & Currency Invariants

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00002
  phase: Phase 1
  language: dart
```

- [x] Implement `Account` entity and `AccountType` enum (`ui/lib/domain/entities/account.dart`) with credit limit and available balance helpers
- [x] Implement `Category` entity and `CategoryType` enum (`ui/lib/domain/entities/category.dart`)
- [x] Implement `Transaction` entity and `TransactionType` enum (`ui/lib/domain/entities/transaction.dart`) supporting transfers and atomic relations
- [x] Implement `Subscription` entity and `RecurrenceFrequency` enum (`ui/lib/domain/entities/subscription.dart`) with normalized monthly/annual calculations
- [x] Implement `Budget` entity (`ui/lib/domain/entities/budget.dart`)
- [x] Implement `SavingsGoal` entity (`ui/lib/domain/entities/savings_goal.dart`) with progress and remaining amount helpers
- [x] Implement currency and cent conversion utility (`ui/lib/core/utils/currency_formatter.dart`)
- [x] Quality gates passes

### 3.2. Phase 2 — SQLite Database Infrastructure & Schema Setup

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00002
  phase: Phase 2
  language: dart
```

- [x] Implement `DatabaseHelper` singleton (`ui/lib/data/datasources/local/database_helper.dart`) managing SQLite lifecycle and foreign keys
- [x] Define SQLite DDL schemas (`accounts`, `categories`, `transactions`, `subscriptions`, `budgets`, `savings_goals`) with integer cent columns and constraints
- [x] Create database indexes on high-frequency query columns (`transaction_date`, `account_id`, `category_id`, `budget_period`, `subscription_due_date`)
- [x] Implement default system category seeds on initial database creation
- [x] Quality gates passes

### 3.3. Phase 3 — Data Models & Serialization

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00002
  phase: Phase 3
  language: dart
```

- [x] Implement `AccountModel` (`ui/lib/data/models/account_model.dart`) with `fromMap`, `toMap`, `toEntity`, and `fromEntity`
- [x] Implement `CategoryModel` (`ui/lib/data/models/category_model.dart`) with `fromMap`, `toMap`, `toEntity`, and `fromEntity`
- [x] Implement `TransactionModel` (`ui/lib/data/models/transaction_model.dart`) with `fromMap`, `toMap`, `toEntity`, and `fromEntity`
- [x] Implement `SubscriptionModel` (`ui/lib/data/models/subscription_model.dart`) with `fromMap`, `toMap`, `toEntity`, and `fromEntity`
- [x] Implement `BudgetModel` (`ui/lib/data/models/budget_model.dart`) with `fromMap`, `toMap`, `toEntity`, and `fromEntity`
- [x] Implement `SavingsGoalModel` (`ui/lib/data/models/savings_goal_model.dart`) with `fromMap`, `toMap`, `toEntity`, and `fromEntity`
- [x] Quality gates passes

### 3.4. Phase 4 — Unit Testing & Verification

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00002
  phase: Phase 4
  language: dart
```

- [x] Add unit tests for entity business logic and monetary calculations (`ui/test/unit/domain/`)
- [x] Add unit tests for data models and map serialization roundtrips (`ui/test/unit/data/models/`)
- [x] Add unit tests for currency formatter and cent conversions (`ui/test/unit/core/`)
- [x] Run static analysis (`dart analyze` / `flutter analyze`) and test suite (`flutter test`)
- [x] Quality gates passes

### 3.5. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00002
  phase: Phase Z
  language: dart
```

- [x] Update README files on packages modified
- [x] Validate repository governance via vector MCP
