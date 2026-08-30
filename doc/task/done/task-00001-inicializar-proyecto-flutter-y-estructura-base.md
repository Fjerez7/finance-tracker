---
id: task-00001-inicializar-proyecto-flutter-y-estructura-base
type: task
code: "00001"
slug: inicializar-proyecto-flutter-y-estructura-base
title: Initialize Flutter Project and Base Structure
description: Initialize the Flutter project under ui/ with Clean Architecture directory layout, configure base dependencies, and verify compilation against spec-00001.
status: done
created: 2026-08-30
updated: 2026-08-30
tags:
  - flutter
  - setup
  - clean-architecture
  - initialization
related:
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - rfc-00001-arquitectura-base-de-finance-tracker
supersedes: []
superseded_by: null
---

# Task 00001: Initialize Flutter Project and Base Structure

## 1. Prime Directive

> [!Prime Directive]
> Initialize the Flutter application in the `ui/` directory with standard Clean Architecture layers, base dependencies, and verify compilation against spec-00001.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `flutter`, `provider`, `sqflite`, `path`, `fl_chart`, `intl`, `google_sign_in`, `googleapis`

## 3. Checklist

### 3.1. Phase 1 — Project Initialization and Directory Setup

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00001
  phase: Phase 1
  language: dart
```

- [x] Initialize Flutter project skeleton under `ui/` directory
- [x] Create Clean Architecture folder structure (`lib/core/`, `lib/domain/`, `lib/data/`, `lib/providers/`, `lib/presentation/screens/`, `lib/presentation/widgets/`)
- [x] Set up test directory layout mirroring `lib/` (`test/unit/`, `test/widget/`, `test/mocks/`)
- [x] Quality gates passes

### 3.2. Phase 2 — Dependencies and Configuration

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00001
  phase: Phase 2
  language: dart
```

- [x] Add required core dependencies to `ui/pubspec.yaml` (`provider`, `sqflite`, `path`, `fl_chart`, `intl`, `google_sign_in`, `googleapis`)
- [x] Configure asset directories (`assets/icons/`, `assets/images/`) in `pubspec.yaml`
- [x] Verify dependency resolution and clean compilation
- [x] Quality gates passes

### 3.3. Phase 3 — Baseline Compilation & Health Verification

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00001
  phase: Phase 3
  language: dart
```

- [x] Create initial placeholder entry point `ui/lib/main.dart` complying with Clean Architecture boundaries
- [x] Run static analysis (`flutter analyze` / `dart analyze`)
- [x] Verify test runner execution (`flutter test`)
- [x] Quality gates passes

### 3.4. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00001
  phase: Phase Z
  language: dart
```

- [x] Update README files on packages modified
- [x] Validate repository governance via vector MCP
