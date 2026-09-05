---
id: task-00004-implementar-modulo-transacciones-rapidas-y-calculadora
type: task
code: "00004"
slug: implementar-modulo-transacciones-rapidas-y-calculadora
title: "Implement Module 2: Rapid Transaction Capture and Numpad Calculator"
description: Implement transaction and category repositories with balance synchronization, TransactionsProvider, custom on-screen calculator numpad, and rapid transaction UI screens.
status: done
created: 2026-09-04
updated: 2026-09-04
tags:
  - flutter
  - transactions
  - calculator
  - rapid-entry
  - clean-architecture
  - provider
  - ui
related:
  - plan-00001-implementacion-de-modulos-finance-tracker-v1
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - task-00003-implementar-modulo-cuentas-y-patrimonio-neto
supersedes: []
superseded_by: null
---

# Task 00004: Implement Module 2: Rapid Transaction Capture and Numpad Calculator

## 1. Prime Directive

> [!Prime Directive]
> Deliver the full Rapid Transaction Capture & Micro-Expense functional module in `ui/` by implementing `TransactionRepository` and `CategoryRepository` with atomic balance synchronization, reactive `TransactionsProvider`, custom on-screen `CalculatorNumpad`, `CategoryGridPicker`, `TransactionListTile`, and rapid capture screens (`QuickTransactionScreen`, `TransactionListScreen`, `TransactionDetailScreen`) adhering strictly to `spec-00002` and the zero-float invariant.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `provider`, `sqflite`, `intl`, `flutter_test`

## 3. Checklist

### 3.1. Phase 1 — Transaction & Category Repositories

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00004
  phase: Phase 1
  language: dart
```

- [x] Define `TransactionRepository` and `CategoryRepository` domain contracts (`ui/lib/domain/repositories/`)
- [x] Implement `CategoryRepositoryImpl` (`ui/lib/data/repositories/category_repository_impl.dart`)
- [x] Implement `TransactionRepositoryImpl` (`ui/lib/data/repositories/transaction_repository_impl.dart`) with SQLite atomic transactions to synchronize account balances on insert, update, and delete
- [x] Add unit tests for repositories using in-memory SQLite (`ui/test/unit/data/repositories/`)
- [x] Quality gates passes

### 3.2. Phase 2 — State Management (TransactionsProvider)

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00004
  phase: Phase 2
  language: dart
```

- [x] Implement `TransactionsProvider` (`ui/lib/providers/transactions_provider.dart`) extending `ChangeNotifier`
- [x] Provide reactive state for recent transactions, filtered transaction queries (by date range, account, category, transaction type, search term), and cached categories
- [x] Implement CRUD operations with account balance synchronization and error handling
- [x] Add unit tests for `TransactionsProvider` (`ui/test/unit/providers/transactions_provider_test.dart`)
- [x] Quality gates passes

### 3.3. Phase 3 — Calculator Numpad & UI Components

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00004
  phase: Phase 3
  language: dart
```

- [x] Implement custom on-screen `CalculatorNumpad` widget (`ui/lib/presentation/widgets/common/calculator_numpad.dart`) with live basic arithmetic operations (+, -, *, /) and integer cents output
- [x] Implement `CategoryGridPicker` widget (`ui/lib/presentation/widgets/common/category_grid_picker.dart`)
- [x] Implement `TransactionListTile` widget (`ui/lib/presentation/widgets/cards/transaction_list_tile.dart`)
- [x] Implement `QuickTransactionScreen` (`ui/lib/presentation/screens/transactions/quick_transaction_screen.dart`) featuring the 2-tap micro-expense capture flow
- [x] Implement `TransactionListScreen` (`ui/lib/presentation/screens/transactions/transaction_list_screen.dart`) with chronological grouping, search, and multi-dimensional filters
- [x] Implement `TransactionDetailScreen` (`ui/lib/presentation/screens/transactions/transaction_detail_screen.dart`)
- [x] Register `TransactionsProvider` in `ui/lib/main.dart` and wire up navigation tabs and FAB
- [x] Quality gates passes

### 3.4. Phase 4 — Widget Testing & End-to-End Verification

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00004
  phase: Phase 4
  language: dart
```

- [x] Add widget tests for `CalculatorNumpad` (`ui/test/widget/calculator_numpad_test.dart`)
- [x] Add widget tests for `QuickTransactionScreen` (`ui/test/widget/quick_transaction_screen_test.dart`)
- [x] Add widget tests for `TransactionListScreen` (`ui/test/widget/transaction_list_screen_test.dart`)
- [x] Verify full test suite passes with 0 warnings/errors (`flutter test` & `flutter analyze`)
- [x] Quality gates passes

### 3.5. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00004
  phase: Phase Z
  language: dart
```

- [x] Move task to `doc/task/done/` and update status to `done`
- [x] Verify Vector documentation validation passes (`validate_fix`)
