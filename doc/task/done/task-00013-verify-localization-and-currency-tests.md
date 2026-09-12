---
id: task-00013-verify-localization-and-currency-tests
type: task
code: "00013"
slug: verify-localization-and-currency-tests
title: Verify Localization and Currency Tests
description: Author unit and widget tests for CurrencyFormatter, SettingsProvider, SettingsScreen, and verify full test suite passes.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - flutter
  - testing
  - unit-tests
  - widget-tests
  - i18n
related:
  - rfc-00002-i18n-currency-settings
  - plan-00002-i18n-currency-settings-plan
supersedes: []
superseded_by: null
---

# Task 00013: Verify Localization and Currency Tests

## 1. Prime Directive

> [!Prime Directive]
> Write and execute unit tests for `CurrencyFormatter` (multi-currency USD/COP) and `SettingsProvider` (state & SQLite persistence), widget tests for `SettingsScreen` and language switching, and ensure 100% clean test and lint passes.

## 2. Specs

- **Module:** `ui/test/`
- **Dependencies:** `flutter_test`, `sqflite_common_ffi`

## 3. Checklist

### 3.1. Phase 1 — Unit & Widget Tests Creation

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00013
  phase: Phase 1
  language: flutter, dart
```

- [x] Write unit tests for `CurrencyFormatter` covering USD ($12.50) and COP ($50.000 / $50,000) formatting and parsing
- [x] Write unit tests for `SettingsProvider` verifying reactive notifications and storage
- [x] Write widget tests for `SettingsScreen` language & currency modals and dynamic locale updates
- [x] Quality gates passes

### 3.2. Phase 2 — Comprehensive Test Execution & Static Analysis

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00013
  phase: Phase 2
  language: flutter, dart
```

- [x] Run `flutter analyze` and resolve any warnings or deprecations
- [x] Run `flutter test` across all unit and widget tests
- [x] Update documentation and mark tasks as done upon completion
- [x] Quality gates passes
