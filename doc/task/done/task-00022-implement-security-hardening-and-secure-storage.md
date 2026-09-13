---
id: task-00022-implement-security-hardening-and-secure-storage
type: task
code: "00022"
slug: implement-security-hardening-and-secure-storage
title: Implement Security Hardening, Secure Storage, and Privacy Protection
description: Implement hardware-backed Keystore secret storage, backup secret sanitization, authenticated Firestore user routing, ADB backup blocking, and task switcher privacy protection.
status: done
category: active
created: 2026-09-13
updated: 2026-09-13
assignees:
  - Antigravity
tags:
  - security
  - keystore
  - backup
  - privacy
  - firestore
related:
  - "[[spec-00006-security-hardening-and-secure-storage]]"
  - "[[spec-00005-hybrid-cloud-backup-firestore-and-drive]]"
supersedes: []
superseded_by: null
aliases:
  - "TASK 00022: Implement Security Hardening, Secure Storage, and Privacy Protection"
---

# TASK 00022: Implement Security Hardening, Secure Storage, and Privacy Protection

## 1. Description

Implement comprehensive security hardening per `[[spec-00006-security-hardening-and-secure-storage]]`.

This task eliminates 5 critical vulnerability vectors:
1. Sanitizes database backup snapshots in `BackupRestoreService` to guarantee zero leakage of API keys or private credentials.
2. Migrates secret credentials (Gemini API key) to hardware-encrypted storage using `flutter_secure_storage` (Android Keystore / iOS Keychain) with automatic transparent migration from SQLite.
3. Enforces authenticated user ID/email routing in `FirestoreBackupService` under `users/{email}/backups/{id}`.
4. Hardens `AndroidManifest.xml` with `android:allowBackup="false"` to prevent USB/ADB database dumping.
5. Implements task switcher privacy shielding to obscure financial previews in OS multitasking.

---

## 2. Checklist

### Phase 1 — Secrets & Hardware Storage Migration
- [x] Add `flutter_secure_storage: ^9.2.2` to `ui/pubspec.yaml`.
- [x] Update `SettingsProvider` to manage `gemini_api_key` via `FlutterSecureStorage`.
- [x] Implement auto-migration from SQLite `app_settings` to secure storage and purge plaintext key.

### Phase 2 — Backup Secret Sanitization & Cloud Partitioning
- [x] Update `BackupRestoreService.createBackupSnapshot` to filter out any sensitive keys from `app_settings`.
- [x] Update `FirestoreBackupService` and `HybridCloudBackupService` to require authenticated user email as `userId`.
- [x] Update `BackupProvider` to pass active user email dynamically to all cloud backup operations.

### Phase 3 — Android Manifest & Task Switcher Privacy Protection
- [x] Configure `android:allowBackup="false"` and `android:fullBackupContent="false"` in `AndroidManifest.xml`.
- [x] Implement visual privacy protection on app pause / task switcher.

### Phase 4 — Testing & Release Build
- [x] Update unit tests in `backup_services_test.dart` and `settings_provider_test.dart`.
- [x] Run `flutter analyze` and `flutter test` ensuring 0 issues and 100% pass rate.
- [x] Compile release APK `flutter build apk --release`.

---

## 3. Verification Criteria

- [x] `gemini_api_key` is securely stored in Keystore/Keychain and deleted from SQLite.
- [x] Exported `.json` snapshots contain 0 API keys or private secrets.
- [x] Firestore backup paths are strictly isolated under `users/{email}/backups`.
- [x] `flutter analyze` and `flutter test` pass with 0 errors (211/211 passing).
