---
id: task-00011-build-settings-screen-and-navigation
type: task
code: "00011"
slug: build-settings-screen-and-navigation
title: Build Settings Screen and Navigation
description: Create SettingsScreen with Language and Currency selectors, Google Drive backup navigation, and add Settings AppBar action button.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - flutter
  - ui
  - settings
  - navigation
  - material3
related:
  - rfc-00002-i18n-currency-settings
  - plan-00002-i18n-currency-settings-plan
supersedes: []
superseded_by: null
---

# Task 00011: Build Settings Screen and Navigation

## 1. Prime Directive

> [!Prime Directive]
> Build a dedicated Material 3 `SettingsScreen` containing language preferences (System Default, ES, EN), currency preferences (USD, COP), cloud backup entry point linking to `BackupSettingsScreen`, and an About dialog/section, integrated with AppBar actions across main screens.

## 2. Specs

- **Module:** `ui/lib/presentation/screens/settings`, `ui/lib/presentation/screens/dashboard`
- **Dependencies:** `flutter/material.dart`, `provider`

## 3. Checklist

### 3.1. Phase 1 — SettingsScreen UI Construction

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00011
  phase: Phase 1
  language: flutter, dart
```

- [x] Create `presentation/screens/settings/settings_screen.dart` with Material 3 grouped list sections
- [x] Build Language selection modal/dialog with active checkmark and instant provider update
- [x] Build Currency selection modal/dialog with active checkmark and instant provider update
- [x] Add Cloud Backup tile navigating to `BackupSettingsScreen`
- [x] Add App Info / About section displaying version and local-first architecture details
- [x] Quality gates passes

### 3.2. Phase 2 — AppBar Navigation Integration

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00011
  phase: Phase 2
  language: flutter, dart
```

- [x] Add Settings action button (⚙️) to `DashboardScreen` AppBar
- [x] Ensure smooth page transitions to `SettingsScreen`
- [x] Verify hot UI re-rendering upon changing language and currency
- [x] Quality gates passes

