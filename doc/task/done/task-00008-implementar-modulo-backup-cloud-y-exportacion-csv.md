---
id: task-00008-implementar-modulo-backup-cloud-y-exportacion-csv
type: task
code: "00008"
slug: implementar-modulo-backup-cloud-y-exportacion-csv
title: "Implement Module 6: Google Drive Cloud Backup and CSV Local Export"
description: Implement CSV export, JSON database snapshot builder with SHA-256 checksum verification, Google Drive appDataFolder backup sync service, BackupProvider, and BackupSettingsScreen.
status: done
created: 2026-09-05
updated: 2026-09-05
tags:
  - flutter
  - backup
  - google-drive
  - csv-export
  - clean-architecture
  - provider
  - ui
related:
  - plan-00001-implementacion-de-modulos-finance-tracker-v1
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - task-00007-implementar-modulo-dashboard-y-analiticas-visuales
supersedes: []
superseded_by: null
---

# Task 00008: Implement Module 6: Google Drive Cloud Backup and CSV Local Export

## 1. Prime Directive

> [!Prime Directive]
> Deliver the full Backup, Restore & Local Export Engine in `ui/` by implementing `CsvExportService` for tabular transaction exports, `BackupRestoreService` for atomic JSON full-database snapshots with SHA-256 integrity verification, `GoogleDriveService` for private `appDataFolder` sync, reactive `BackupProvider` state management, and `BackupSettingsScreen` adhering strictly to `spec-00002` and Clean Architecture.

## 2. Specs

- **Module:** `ui`
- **Dependencies:** `google_sign_in`, `googleapis`, `crypto`, `path_provider`, `provider`, `sqflite`, `flutter_test`

## 3. Checklist

### 3.1. Phase 1 — CSV Export & JSON Snapshot Integrity Services

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00008
  phase: Phase 1
  language: dart
```

- [x] Implement `CsvExportService` (`ui/lib/services/csv_export_service.dart`) generating RFC 4180-compliant CSV from transactions, accounts, and categories
- [x] Implement `BackupRestoreService` (`ui/lib/services/backup_restore_service.dart`) creating full database JSON snapshots, computing SHA-256 checksums, validating schema version, and restoring data atomically inside a SQLite transaction
- [x] Add unit tests for `CsvExportService` and `BackupRestoreService` (`ui/test/unit/services/backup_services_test.dart`)
- [x] Quality gates passes

### 3.2. Phase 2 — Google Drive Cloud Sync & Reactive Backup Provider

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00008
  phase: Phase 2
  language: dart
```

- [x] Implement `GoogleDriveService` (`ui/lib/services/google_drive_service.dart`) interfacing with `googleapis` Drive API v3 within private `appDataFolder` (`drive.appdata` scope)
- [x] Implement `BackupProvider` (`ui/lib/providers/backup_provider.dart`) orchestrating cloud sync state, account authentication, snapshot creation, and database restore
- [x] Add unit tests for `BackupProvider` (`ui/test/unit/providers/backup_provider_test.dart`)
- [x] Register `BackupProvider` in `ui/lib/main.dart`
- [x] Quality gates passes

### 3.3. Phase 3 — Settings Screen & Cloud Management UI

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00008
  phase: Phase 3
  language: dart
```

- [x] Implement `BackupSettingsScreen` (`ui/lib/presentation/screens/settings/backup_settings_screen.dart`) with Google Account auth card, manual cloud backup trigger, restore backup list modal, and local CSV/JSON export actions
- [x] Add navigation entry point to Settings/Backup from main navigation shell or dashboard app bar
- [x] Quality gates passes

### 3.4. Phase 4 — Widget Testing & Comprehensive Suite Verification

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00008
  phase: Phase 4
  language: dart
```

- [x] Add widget tests for `BackupSettingsScreen` (`ui/test/widget/presentation/settings/backup_settings_screen_test.dart`)
- [x] Verify full test suite passes with 0 warnings/errors (`flutter test` & `flutter analyze`)
- [x] Quality gates passes

### 3.5. Phase Z — Wrap-up

```vector-agent-action
label: Execute Phase in Agent
profile: code
prompt: prompts-00004-execute-task-phase
input:
  task: task 00008
  phase: Phase Z
  language: dart
```

- [x] Move task to `doc/task/done/` and update status to `done`
- [x] Verify Vector documentation validation passes (`validate_fix`)
