---
id: task-00006-implementar-modulo-presupuestos-y-metas-de-ahorro
type: task
code: "00006"
slug: implementar-modulo-presupuestos-y-metas-de-ahorro
title: "Implement Module 4: Budgets and Savings Goals Engine"
description: Implement Budget and SavingsGoal repositories, reactive BudgetsProvider with 80%/100% threshold alert calculations, progress cards, and budget & savings goal screens.
status: done
created: 2026-09-05
updated: 2026-09-05
tags:
  - flutter
  - budgets
  - savings-goals
  - clean-architecture
  - provider
  - ui
related:
  - plan-00001-implementacion-de-modulos-finance-tracker-v1
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - task-00005-implementar-modulo-suscripciones-y-pagos-recurrentes
supersedes: []
superseded_by: null
---

# Task 00006: Implement Module 4: Budgets and Savings Goals Engine

## 1. Prime Directive

> [!Prime Directive]
> Deliver the full Budgets and Savings Goals functional module in `ui/` by implementing `BudgetRepository`, `SavingsGoalRepository`, SQLite implementations, reactive `BudgetsProvider` with real-time monthly category spend calculation, 80%/100% threshold visual alerts, fund allocation workflows, presentation cards (`BudgetProgressCard`, `SavingsGoalCard`), and complete management screens (`BudgetsScreen`, `SavingsGoalsScreen`, `AddEditBudgetScreen`, `AddEditSavingsGoalScreen`) adhering strictly to `spec-00002` and the zero-float invariant.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `provider`, `sqflite`, `intl`, `flutter_test`

## 3. Checklist

### 3.1. Phase 1 — Repositories Layer (Budgets & Savings Goals)

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00006
  phase: Phase 1
  language: dart
```

- [x] Define `BudgetRepository` domain contract (`ui/lib/domain/repositories/budget_repository.dart`)
- [x] Define `SavingsGoalRepository` domain contract (`ui/lib/domain/repositories/savings_goal_repository.dart`)
- [x] Implement `BudgetRepositoryImpl` (`ui/lib/data/repositories/budget_repository_impl.dart`) with SQLite queries via `DatabaseHelper`
- [x] Implement `SavingsGoalRepositoryImpl` (`ui/lib/data/repositories/savings_goal_repository_impl.dart`) with SQLite queries via `DatabaseHelper`
- [x] Add unit tests for repositories using in-memory SQLite (`ui/test/unit/data/repositories/budget_repository_test.dart` & `savings_goal_repository_test.dart`)
- [x] Quality gates passes

### 3.2. Phase 2 — State Management (BudgetsProvider)

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00006
  phase: Phase 2
  language: dart
```

- [x] Implement `BudgetsProvider` (`ui/lib/providers/budgets_provider.dart`) extending `ChangeNotifier`
- [x] Implement real-time monthly category spend computation cross-referenced against `TransactionsProvider`
- [x] Implement alert threshold classification (Safe <80%, Warning 80-99%, Exceeded >=100%)
- [x] Implement savings goals allocation workflow (deposit funds into goal, adjust goal balance)
- [x] Add unit tests for `BudgetsProvider` (`ui/test/unit/providers/budgets_provider_test.dart`)
- [x] Quality gates passes

### 3.3. Phase 3 — UI Components & Screens

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00006
  phase: Phase 3
  language: dart
```

- [x] Implement `BudgetProgressCard` (`ui/lib/presentation/widgets/cards/budget_progress_card.dart`) with progress bars, spent vs limit labels, and alert badges
- [x] Implement `SavingsGoalCard` (`ui/lib/presentation/widgets/cards/savings_goal_card.dart`) with circular/linear progress, remaining target, and deposit action
- [x] Implement `BudgetsScreen` (`ui/lib/presentation/screens/budgets/budgets_screen.dart`) with month selector, total monthly budget gauge, and category budget cards
- [x] Implement `SavingsGoalsScreen` (`ui/lib/presentation/screens/budgets/savings_goals_screen.dart`) with active and completed goals
- [x] Implement `AddEditBudgetScreen` (`ui/lib/presentation/screens/budgets/add_edit_budget_screen.dart`) with category selector and amount input
- [x] Implement `AddEditSavingsGoalScreen` (`ui/lib/presentation/screens/budgets/add_edit_savings_goal_screen.dart`) with target amount, target date, color, and icon pickers
- [x] Register `BudgetsProvider` in `ui/lib/main.dart`
- [x] Quality gates passes

### 3.4. Phase 4 — Widget Testing & Quality Gates

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00006
  phase: Phase 4
  language: dart
```

- [x] Add widget tests for `BudgetProgressCard` (`ui/test/widget/presentation/budgets/budget_progress_card_test.dart`)
- [x] Add widget tests for `SavingsGoalCard` (`ui/test/widget/presentation/budgets/savings_goal_card_test.dart`)
- [x] Add widget tests for `BudgetsScreen` (`ui/test/widget/presentation/budgets/budgets_screen_test.dart`)
- [x] Add widget tests for `SavingsGoalsScreen` (`ui/test/widget/presentation/budgets/savings_goals_screen_test.dart`)
- [x] Verify full test suite passes with 0 warnings/errors (`flutter test` & `flutter analyze`)
- [x] Quality gates passes

### 3.5. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00006
  phase: Phase Z
  language: dart
```

- [x] Move task to `doc/task/done/` and update status to `done`
- [x] Verify Vector documentation validation passes (`validate_fix`)
