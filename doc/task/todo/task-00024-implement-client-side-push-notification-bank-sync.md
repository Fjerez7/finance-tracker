---
id: task-00024-implement-client-side-push-notification-bank-sync
type: task
code: "00024"
slug: implement-client-side-push-notification-bank-sync
title: Implement Client-Side Push Notification Bank Sync
description: Implement Android NotificationListenerService, dynamic multi-bank package whitelist, local SQLite buffering, and Gemini-powered transaction ingestion for Nubank and future neobanks.
status: todo
category: todo
created: 2026-09-14
updated: 2026-09-14
assignees:
  - Antigravity
tags:
  - notification
  - sync
  - android
  - nubank
  - gemini
  - client-side
related:
  - "[[spec-00008-client-side-push-notification-bank-sync]]"
  - "[[spec-00004-client-side-gmail-oauth-bank-sync]]"
supersedes: []
superseded_by: null
aliases:
  - "TASK 00024: Implement Client-Side Push Notification Bank Sync"
---

# TASK 00024: Implement Client-Side Push Notification Bank Sync

## 1. Description

Implement client-side banking push notification synchronization per `[[spec-00008-client-side-push-notification-bank-sync]]`.

This task introduces:
1. Native Android `BankNotificationListenerService` capturing push notifications in real time.
2. Dynamic package whitelist registry (`monitored_bank_apps`) pre-seeded with Nubank (`com.nu.production`) and extensible for any neobank.
3. Offline-resilient SQLite buffer table `pending_bank_notifications`.
4. Reactive `NotificationSyncProvider` managing permission status, package toggles, and Gemini extraction orchestration.
5. Dedicated `NotificationSyncSettingsScreen` in Settings allowing users to grant Android Notification Access, enable/disable banks, and register custom packages.

---

## 2. Checklist

### Phase 1 — Native Android Notification Listener & Manifest
- [ ] Implement `BankNotificationListenerService.kt` in `ui/android/app/src/main/kotlin/...` extending `NotificationListenerService`.
- [ ] Configure `BIND_NOTIFICATION_LISTENER_SERVICE` in `AndroidManifest.xml`.
- [ ] Implement native fast-drop filter checking active package whitelist in `SharedPreferences`.
- [ ] Implement MethodChannel handlers in `MainActivity.kt` to check notification access permission, open system settings, and update native package whitelist.

### Phase 2 — Database Schema & Data Models
- [ ] Add `monitored_bank_apps` and `pending_bank_notifications` table definitions in `DatabaseHelper`.
- [ ] Pre-seed `monitored_bank_apps` with Nubank (`id: nubank`, `package_name: com.nu.production`, `display_name: Nubank`).
- [ ] Create `MonitoredBankApp` model with serialization/deserialization.
- [ ] Create `PendingBankNotification` model.

### Phase 3 — Service & State Layer
- [ ] Create `NotificationListenerBridgeService` encapsulating platform channel calls.
- [ ] Create `NotificationSyncProvider` managing permission state, active package whitelist, manual/auto synchronization, and Gemini extraction.
- [ ] Connect `NotificationSyncProvider` with `GeminiExtractionService` and `TransactionRepository` for atomic transaction persistence.
- [ ] Register `NotificationSyncProvider` in `MultiProvider` tree in `main.dart`.

### Phase 4 — UI & Settings Integration
- [ ] Create `NotificationSyncSettingsScreen` with permission banner, bank switch list, custom package addition dialog, and manual "Sync Notifications" action.
- [ ] Add entry navigation tile in `SettingsScreen` under "Data & Storage".
- [ ] Add English and Spanish translations in `app_en.arb` and `app_es.arb`.

### Phase 5 — Testing & Quality Gates
- [ ] Unit tests for `MonitoredBankApp` model and SQLite operations.
- [ ] Unit tests for `NotificationSyncProvider` state transitions, idempotency, and error handling.
- [ ] Widget tests for `NotificationSyncSettingsScreen` and `SettingsScreen` tile.
- [ ] Run full test suite with `flutter test` to ensure 100% pass rate.
