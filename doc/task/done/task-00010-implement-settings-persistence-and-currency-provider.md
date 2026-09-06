---
id: task-00010-implement-settings-persistence-and-currency-provider
type: task
code: "00010"
slug: implement-settings-persistence-and-currency-provider
title: Implement Settings Persistence and Currency Provider
description: Create SQLite key-value settings storage, AppCurrency enum, CurrencyFormatter multi-currency support, and SettingsProvider.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - sqlite
  - provider
  - currency
  - settings
  - state-management
related:
  - rfc-00002-i18n-currency-settings
  - plan-00002-i18n-currency-settings-plan
supersedes: []
superseded_by: null
---

# Task 00010: Implement Settings Persistence and Currency Provider

## 1. Prime Directive

> [!Prime Directive]
> Implement SQLite key-value table `app_settings`, create `AppCurrency` enum with USD and COP support, update `CurrencyFormatter` to format dynamically according to active currency and locale, and implement `SettingsProvider` registered in the root provider tree.

## 2. Specs

- **Module:** `ui/lib/core`, `ui/lib/data`, `ui/lib/providers`
- **Dependencies:** `sqflite`, `provider`, `intl`

## 3. Checklist

### 3.1. Phase 1 — SQLite Persistence & Domain Currency Model

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00010
  phase: Phase 1
  language: dart
```

- [x] Add `app_settings` table to SQLite schema in `DatabaseConstants` and migration in `DatabaseHelper`
- [x] Implement `getSetting(key)` and `setSetting(key, value)` in `DatabaseHelper`
- [x] Define `AppCurrency` enum (`usd`, `cop`) with symbol, code, default decimals, and name in `core/constants/` or `domain/models/`
- [x] Refactor `CurrencyFormatter` to accept `AppCurrency` and format USD ($12.50) vs COP ($50.000) properly
- [x] Quality gates passes

### 3.2. Phase 2 — SettingsProvider Implementation and Registration

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00010
  phase: Phase 2
  language: dart
```

- [x] Implement `SettingsProvider` (`ChangeNotifier`) with `Locale?` and `AppCurrency` properties
- [x] Implement `loadSettings()`, `setLocale(Locale?)`, and `setCurrency(AppCurrency)` with asynchronous SQLite persistence
- [x] Register `SettingsProvider` in `MultiProvider` in `main.dart`
- [x] Bind `MaterialApp.locale` to `settingsProvider.locale`
- [x] Quality gates passes

