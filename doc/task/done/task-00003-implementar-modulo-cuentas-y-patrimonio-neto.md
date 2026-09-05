---
id: task-00003-implementar-modulo-cuentas-y-patrimonio-neto
type: task
code: "00003"
slug: implementar-modulo-cuentas-y-patrimonio-neto
title: "Implement Module 1: Accounts and Net Worth Engine"
description: Implement account repository, reactive AccountsProvider with real-time net worth calculation, and complete account management UI screens and widgets.
status: done
created: 2026-09-04
updated: 2026-09-04
tags:
  - flutter
  - accounts
  - net-worth
  - clean-architecture
  - provider
  - ui
related:
  - plan-00001-implementacion-de-modulos-finance-tracker-v1
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - task-00002-implementar-sqlite-schema-entidades-y-modelos-base
supersedes: []
superseded_by: null
---

# Task 00003: Implement Module 1: Accounts and Net Worth Engine

## 1. Prime Directive

> [!Prime Directive]
> Deliver the full Accounts & Net Worth functional module in `ui/` by implementing the `AccountRepository` contract and SQLite implementation, the reactive `AccountsProvider` with real-time Net Worth aggregation, and the complete set of presentation screens and widgets (`AccountsScreen`, `AddEditAccountScreen`, `AccountDetailScreen`, `AccountBalanceCard`) complying with `spec-00002`.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `provider`, `sqflite`, `intl`, `flutter_test`

## 3. Checklist

### 3.1. Phase 1 — Account Repository Layer

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00003
  phase: Phase 1
  language: dart
```

- [x] Define `AccountRepository` abstract contract (`ui/lib/domain/repositories/account_repository.dart`)
- [x] Implement `AccountRepositoryImpl` (`ui/lib/data/repositories/account_repository_impl.dart`) querying SQLite via `DatabaseHelper`
- [x] Add unit tests for `AccountRepositoryImpl` using in-memory SQLite (`ui/test/unit/data/repositories/account_repository_test.dart`)
- [x] Quality gates passes

### 3.2. Phase 2 — State Management (AccountsProvider)

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00003
  phase: Phase 2
  language: dart
```

- [x] Implement `AccountsProvider` (`ui/lib/providers/accounts_provider.dart`) extending `ChangeNotifier`
- [x] Implement real-time Net Worth calculation ($Total Assets - Total Liabilities$) and account grouping (assets vs credit cards)
- [x] Add unit tests for `AccountsProvider` state transitions and net worth calculations (`ui/test/unit/providers/accounts_provider_test.dart`)
- [x] Quality gates passes

### 3.3. Phase 3 — UI Components & Screens

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00003
  phase: Phase 3
  language: dart
```

- [x] Implement `AccountBalanceCard` widget (`ui/lib/presentation/widgets/cards/account_balance_card.dart`) with credit utilization progress indicator
- [x] Implement `AccountsScreen` (`ui/lib/presentation/screens/accounts/accounts_screen.dart`) with hero Net Worth summary and sectioned account lists
- [x] Implement `AddEditAccountScreen` (`ui/lib/presentation/screens/accounts/add_edit_account_screen.dart`) with account type selector, initial balance, credit limit, color picker, and icon picker
- [x] Implement `AccountDetailScreen` (`ui/lib/presentation/screens/accounts/account_detail_screen.dart`) with balance adjustments and archive/delete actions
- [x] Connect `AccountsProvider` to application bootstrap in `ui/lib/main.dart`
- [x] Quality gates passes

### 3.4. Phase 4 — Widget Testing & End-to-End Verification

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00003
  phase: Phase 4
  language: dart
```

- [x] Add widget tests for `AccountsScreen`, `AddEditAccountScreen`, and `AccountBalanceCard` (`ui/test/widget/presentation/accounts/`)
- [x] Run static analysis (`dart analyze` / `flutter analyze`) and full test suite (`flutter test`)
- [x] Quality gates passes

### 3.5. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00003
  phase: Phase Z
  language: dart
```

- [x] Update README files on packages modified
- [x] Validate repository governance via vector MCP
