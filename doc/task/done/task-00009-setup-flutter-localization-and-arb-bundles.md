---
id: task-00009-setup-flutter-localization-and-arb-bundles
type: task
code: "00009"
slug: setup-flutter-localization-and-arb-bundles
title: Setup Flutter Localization and ARB Bundles
description: Configure Flutter gen-l10n, add flutter_localizations dependency, and create complete English and Spanish ARB translation files.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - flutter
  - i18n
  - localization
  - l10n
  - arb
related:
  - rfc-00002-i18n-currency-settings
  - plan-00002-i18n-currency-settings-plan
supersedes: []
superseded_by: null
---

# Task 00009: Setup Flutter Localization and ARB Bundles

## 1. Prime Directive

> [!Prime Directive]
> Configure Flutter native `gen-l10n` toolchain, author comprehensive English and Spanish ARB translation bundles (`app_en.arb` and `app_es.arb`), and integrate localizations delegates in `MaterialApp`.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `flutter_localizations`, `intl`
- **Configuration:** `l10n.yaml`, `lib/l10n/`

## 3. Checklist

### 3.1. Phase 1 — Tooling and Configuration

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00009
  phase: Phase 1
  language: flutter, dart
```

- [x] Add `flutter_localizations` SDK dependency and verify `intl` in `pubspec.yaml`
- [x] Enable `generate: true` under `flutter:` in `pubspec.yaml`
- [x] Create `ui/l10n.yaml` with synthetic package configuration
- [x] Quality gates passes

### 3.2. Phase 2 — ARB Resource Bundles Creation

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00009
  phase: Phase 2
  language: flutter, dart
```

- [x] Author `ui/lib/l10n/app_en.arb` with comprehensive UI strings, labels, placeholders, errors, and system category names
- [x] Author `ui/lib/l10n/app_es.arb` with complete, natural Spanish translations
- [x] Run `flutter gen-l10n` and verify generated `AppLocalizations` classes
- [x] Wire `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales` in `main.dart`
- [x] Quality gates passes

