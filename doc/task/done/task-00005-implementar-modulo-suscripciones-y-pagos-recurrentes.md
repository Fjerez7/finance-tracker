---
id: task-00005-implementar-modulo-suscripciones-y-pagos-recurrentes
type: task
code: "00005"
slug: implementar-modulo-suscripciones-y-pagos-recurrentes
title: "Implement Module 3: Subscriptions and Recurring Payments Engine"
description: Implement subscription repository, reactive SubscriptionsProvider with normalized burn rate analytics and 1-tap payment posting, SubscriptionCard, and complete subscription management UI screens.
status: done
created: 2026-09-05
updated: 2026-09-05
tags:
  - flutter
  - subscriptions
  - recurring-payments
  - clean-architecture
  - provider
  - ui
related:
  - plan-00001-implementacion-de-modulos-finance-tracker-v1
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - task-00004-implementar-modulo-transacciones-rapidas-y-calculadora
supersedes: []
superseded_by: null
---

# Task 00005: Implement Module 3: Subscriptions and Recurring Payments Engine

## 1. Prime Directive

> [!Prime Directive]
> Deliver the full Subscriptions & Recurring Payments functional module in `ui/` by implementing `SubscriptionRepository` and SQLite implementation, reactive `SubscriptionsProvider` with normalized monthly/annual burn rate aggregation and 1-tap ledger posting, custom presentation cards (`SubscriptionCard`), and complete subscription UI screens (`SubscriptionsScreen`, `AddEditSubscriptionScreen`) adhering strictly to `spec-00002` and the zero-float invariant.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `provider`, `sqflite`, `intl`, `flutter_test`

## 3. Checklist

### 3.1. Phase 1 — Subscription Repository Layer

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00005
  phase: Phase 1
  language: dart
```

- [x] Define `SubscriptionRepository` domain contract (`ui/lib/domain/repositories/subscription_repository.dart`)
- [x] Implement `SubscriptionRepositoryImpl` (`ui/lib/data/repositories/subscription_repository_impl.dart`) with SQLite queries via `DatabaseHelper`
- [x] Add unit tests for `SubscriptionRepositoryImpl` using in-memory SQLite (`ui/test/unit/data/repositories/subscription_repository_test.dart`)
- [x] Quality gates passes

### 3.2. Phase 2 — State Management (SubscriptionsProvider)

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00005
  phase: Phase 2
  language: dart
```

- [x] Implement `SubscriptionsProvider` (`ui/lib/providers/subscriptions_provider.dart`) extending `ChangeNotifier`
- [x] Implement normalized monthly burn rate ($Total Monthly Cost$) and annual projection formulas
- [x] Implement recurrence scheduler helper to advance `nextDueDate` after payment
- [x] Implement 1-tap payment posting to ledger creating real `Transaction` records and updating account balances
- [x] Add unit tests for `SubscriptionsProvider` (`ui/test/unit/providers/subscriptions_provider_test.dart`)
- [x] Quality gates passes

### 3.3. Phase 3 — UI Components & Screens

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00005
  phase: Phase 3
  language: dart
```

- [x] Implement `SubscriptionCard` widget (`ui/lib/presentation/widgets/cards/subscription_card.dart`) with due date countdown badges, category icon, and 1-tap pay action
- [x] Implement `SubscriptionsScreen` (`ui/lib/presentation/screens/subscriptions/subscriptions_screen.dart`) with monthly burn rate hero banner, active/inactive lists, and sorting
- [x] Implement `AddEditSubscriptionScreen` (`ui/lib/presentation/screens/subscriptions/add_edit_subscription_screen.dart`) with frequency selector, billing day picker, account & category selectors, and auto-register toggle
- [x] Register `SubscriptionsProvider` in `ui/lib/main.dart` and expose in navigation
- [x] Quality gates passes

### 3.4. Phase 4 — Widget Testing & End-to-End Verification

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00005
  phase: Phase 4
  language: dart
```

- [x] Add widget tests for `SubscriptionCard` (`ui/test/widget/presentation/subscriptions/subscription_card_test.dart`)
- [x] Add widget tests for `SubscriptionsScreen` (`ui/test/widget/presentation/subscriptions/subscriptions_screen_test.dart`)
- [x] Add widget tests for `AddEditSubscriptionScreen` (`ui/test/widget/presentation/subscriptions/add_edit_subscription_screen_test.dart`)
- [x] Verify full test suite passes with 0 warnings/errors (`flutter test` & `flutter analyze`)
- [x] Quality gates passes

### 3.5. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00005
  phase: Phase Z
  language: dart
```

- [x] Move task to `doc/task/done/` and update status to `done`
- [x] Verify Vector documentation validation passes (`validate_fix`)
