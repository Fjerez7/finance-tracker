---
id: task-00021-implement-hybrid-cloud-backup-firestore-and-drive
type: task
code: "00021"
slug: implement-hybrid-cloud-backup-firestore-and-drive
title: Implement Hybrid Cloud Backup Provider (Firestore and Google Drive)
description: Implement dual-destination cloud backup system in Flutter backing up SQLite snapshots to Cloud Firestore and Google Drive simultaneously with zero server cost.
status: done
category: done
created: 2026-09-13
updated: 2026-09-13
assignees:
  - Antigravity
tags:
  - flutter
  - backup
  - firestore
  - google-drive
  - sqlite
related:
  - "[[spec-00005-hybrid-cloud-backup-firestore-and-drive]]"
  - "[[spec-00004-client-side-gmail-oauth-bank-sync]]"
supersedes: []
superseded_by: null
aliases:
  - "TASK 00021: Implement Hybrid Cloud Backup Provider (Firestore and Google Drive)"
---

# TASK 00021: Implement Hybrid Cloud Backup Provider (Firestore and Google Drive)

## 1. Description

Implement the **Hybrid Dual-Destination Cloud Backup Provider** per `[[spec-00005-hybrid-cloud-backup-firestore-and-drive]]`.

This provides automated and on-demand dual-redundancy backups of local SQLite database snapshots directly to **Cloud Firestore** (`users/{uid}/backups/{id}`) and **Google Drive** (`appDataFolder`), with full SHA-256 integrity checks, selective cloud restoration, and native file sharing.

---

## 2. Checklist

### Phase 1 — Cloud Storage Services & Unified Interfaces
- [x] Create `CloudBackupInfo` model and `CloudBackupDestination` enum.
- [x] Implement `FirestoreBackupService` interfacing with Cloud Firestore collection `users/{uid}/backups`.
- [x] Refactor `GoogleDriveService` and unify under `CloudBackupService` interface.

### Phase 2 — State Management & Auto-Backup Integration
- [x] Update `BackupProvider` to orchestrate parallel dual-destination uploads (Firestore + Drive).
- [x] Implement multi-destination backup listing and single-tap restoration with SHA-256 validation.
- [x] Add automatic background backup triggering on successful Gmail bank ingestion.

### Phase 3 — UI Enhancements & Native File Sharing
- [x] Update `BackupSettingsScreen` to display Firestore and Google Drive backup history.
- [x] Add native file sharing / saving for CSV and JSON exports via `share_plus` / file picker.
- [x] Add local JSON snapshot file import/restore selector.

### Phase 4 — Testing & Quality Gates
- [x] Write unit tests for `FirestoreBackupService` and `CloudBackupService`.
- [x] Write widget tests for updated `BackupSettingsScreen`.
- [x] Run `flutter analyze` and `flutter test` ensuring 0 issues and 100% pass rate.

---

## 3. Verification Criteria

- [x] Creating a backup uploads snapshot to both Firestore and Google Drive.
- [x] Restoring from Firestore or Drive validates SHA-256 checksum and reconstructs SQLite tables cleanly.
- [x] Exporting CSV/JSON triggers native device sharing / file export.
- [x] All unit and widget tests pass with zero regressions.


