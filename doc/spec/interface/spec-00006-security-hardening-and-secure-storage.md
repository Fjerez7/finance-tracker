---
id: spec-00006-security-hardening-and-secure-storage
type: spec
code: "00006"
slug: security-hardening-and-secure-storage
title: Security Hardening, Hardware Keystore Storage, and Privacy Shielding
description: Technical specification for hardware-backed secret storage, backup payload sanitization, authenticated cloud partitioning, ADB backup blocking, and task switcher privacy shielding.
category: interface
created: 2026-09-13
updated: 2026-09-13
authors:
  - Antigravity
tags:
  - security
  - keystore
  - backup
  - privacy
  - firestore
related:
  - "[[spec-00005-hybrid-cloud-backup-firestore-and-drive]]"
  - "[[spec-00004-client-side-gmail-oauth-bank-sync]]"
supersedes: []
superseded_by: null
aliases:
  - "SPEC 00006: Security Hardening, Hardware Keystore Storage, and Privacy Shielding"
---

# SPEC 00006: Security Hardening, Hardware Keystore Storage, and Privacy Shielding

## 1. Purpose

This specification defines the cryptographic security, secret isolation, cloud storage access partitioning, and visual privacy protection contracts for the Finance Tracker application.

It eliminates five critical security vulnerabilities:
1. **Secret Leakage in Backups:** Raw API keys and private tokens must never be exported in `.json` snapshots or uploaded to cloud backup repositories.
2. **Hardware-Backed Secret Storage:** Sensitive credentials (such as Google Gemini API keys) must be stored in Android Keystore / iOS Keychain via AES hardware encryption, rather than plaintext SQLite tables.
3. **Authenticated Cloud Partitioning:** Cloud Firestore backup documents must be strictly routed to authenticated user subcollections (`users/{email}/backups/{id}`), eliminating unpartitioned generic fallbacks.
4. **Physical USB / ADB Backup Blocking:** Operating system application backup flags must be disabled to prevent unauthorized local SQLite dumps via `adb backup`.
5. **Task Switcher Visual Privacy:** The operating system application preview in the multitasking carousel must be masked or obscured to prevent bystander shoulder-surfing of financial balances and accounts.

---

## 2. Technical Definition & Contracts

### 2.1. Secret Sanitization in Database Snapshots (`BackupRestoreService`)

When `BackupRestoreService.createBackupSnapshot(Database db)` serializes the SQLite database:
* All tables (`accounts`, `categories`, `transactions`, `subscriptions`, `budgets`, `savings_goals`, `exchange_rates`) are serialized canonically.
* The `app_settings` table must be sanitized: records matching blacklisted secret keys (`gemini_api_key`, `auth_token`, `refresh_token`, or any private credential) are strictly omitted from `dataPayload['settings']`.
* Restored snapshots (`restoreFromSnapshot`) only populate sanitized, safe preferences (`app_language`, `app_currency`, `bank_senders`, `gmail_sync_enabled`).

### 2.2. Hardware-Backed Storage (`SecureStorageService` / `FlutterSecureStorage`)

* Gemini API Keys and future sensitive credentials must be managed via `FlutterSecureStorage` using `AndroidOptions(encryptedSharedPreferences: true)` and `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`.
* **Automatic One-Time Migration:** Upon application startup, `SettingsProvider` checks if a legacy plaintext key exists in SQLite table `app_settings`. If present, it writes the key to `FlutterSecureStorage` and permanently deletes the record from `app_settings`.

### 2.3. Authenticated User Partitioning in Firestore (`FirestoreBackupService`)

* `FirestoreBackupService` methods (`uploadBackup`, `listBackups`, `downloadBackup`, `deleteBackup`) require an explicit non-empty `userId` representing the authenticated Google account email (or UID).
* If the user is unauthenticated, cloud backup actions must be aborted with an explicit authentication error, forbidding fallback to `'user_default'`.

### 2.4. Operating System Security Flags (`AndroidManifest.xml`)

* The `<application>` manifest node must declare:
  ```xml
  android:allowBackup="false"
  android:fullBackupContent="false"
  ```

### 2.5. Task Switcher Privacy Protection

* Native Android window flags (`FLAG_SECURE`) or application lifecycle overlays must obscure the window surface when the app is paused or navigated away, preventing OS screenshot previews in recent apps.

---

## 3. Invariants

1. `gemini_api_key` must **never** appear in exported `.json` files, `.csv` ledgers, or Firestore/Drive backup payloads.
2. The SQLite table `app_settings` must **never** retain plaintext API keys once migrated.
3. Firestore backups must strictly reside under `users/{authenticated_user_identifier}/backups`.
4. `android:allowBackup` must be set to `false`.

---

## 4. Verification Criteria

- [ ] Unit tests verify that `createBackupSnapshot` excludes `gemini_api_key` from the output dictionary and calculated checksum.
- [ ] Unit tests verify that `SettingsProvider` loads and persists `gemini_api_key` via `FlutterSecureStorage` and purges legacy SQLite records.
- [ ] Integration tests verify that Firestore uploads are addressed to the user's specific email collection.
- [ ] Release APK compiles cleanly with secure storage and manifest hardening.
