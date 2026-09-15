---
id: spec-00008-client-side-push-notification-bank-sync
type: spec
code: "00008"
slug: client-side-push-notification-bank-sync
title: Client-Side Push Notification Bank Sync Pipeline
description: Technical specification for Android NotificationListenerService interception, extensible dynamic multi-bank package whitelist, local SQLite buffering, on-device Gemini parsing, and atomic transaction reconciliation.
category: interface
created: 2026-09-14
updated: 2026-09-14
authors:
  - Antigravity
tags:
  - notification
  - sync
  - android
  - gemini
  - nubank
  - client-side
related:
  - "[[spec-00003-bank-email-transaction-sync-pipeline]]"
  - "[[spec-00004-client-side-gmail-oauth-bank-sync]]"
supersedes: []
superseded_by: null
aliases:
  - "SPEC 00008: Client-Side Push Notification Bank Sync Pipeline"
---

# SPEC 00008: Client-Side Push Notification Bank Sync Pipeline

## 1. Purpose

This specification defines the client-side architecture and data contracts for intercepting, filtering, buffering, and parsing push notifications emitted by banking and fintech applications (such as Nubank, Nequi, and future neobanks) entirely on the Android device.

It resolves the financial coverage gap where neobanks emit real-time push notifications rather than transactional emails for purchases and transfers, providing automated, zero-latency transaction ingestion while maintaining strict zero-knowledge local privacy.

---

## 2. Technical Definition & Contracts

### 2.1. Native Android Service (`BankNotificationListenerService`)

The native Android layer extends `android.service.notification.NotificationListenerService` and registers the OS permission `android.permission.BIND_NOTIFICATION_LISTENER_SERVICE` in `AndroidManifest.xml`.

```
[Android OS Notification Event]
           │
           ▼
[BankNotificationListenerService.onNotificationPosted(sbn)]
           │
           ├─► 1. Check sbn.packageName against Active Whitelist
           │      └─► Not in Whitelist? ──► Instant Drop (< 0.1ms)
           │
           ├─► 2. Extract Title, Text, BigText, PostTime, Key
           │
           ├─► 3. Buffer into SQLite table `pending_bank_notifications`
           │
           └─► 4. If Flutter Engine is active ──► Stream via EventChannel
```

#### Native Interception Contract:
* `sbn.packageName`: String identifier (e.g., `com.nu.production`).
* `sbn.notification.extras`:
  * `Notification.EXTRA_TITLE`: Notification title header.
  * `Notification.EXTRA_TEXT`: Main body message.
  * `Notification.EXTRA_BIG_TEXT`: Expanded body content when present.
* `sbn.postTime`: Unix epoch timestamp in milliseconds.
* `sbn.key` / `sbn.id`: Unique notification identifier from Android OS.

### 2.2. Dynamic Multi-Bank Package Whitelist Registry

The application must not hardcode banking packages in business logic. Instead, it manages a dynamic package registry persisted in SQLite and cached in native `SharedPreferences`.

#### SQLite Schema (`monitored_bank_apps`):
```sql
CREATE TABLE IF NOT EXISTS monitored_bank_apps (
  id TEXT PRIMARY KEY,
  package_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  is_enabled INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL
);
```

#### Initial Seed Data:
| ID | Package Name | Display Name | Is Enabled |
| :--- | :--- | :--- | :--- |
| `nubank` | `com.nu.production` | Nubank | `1` |

Users can enable, disable, or register additional package names (e.g. `com.nequi.MobileApp`, `co.lulo.lulobank`) via the Settings UI at runtime.

### 2.3. SQLite Pending Buffer Table (`pending_bank_notifications`)

To guarantee zero data loss when the app is closed or terminated, the native listener buffers intercepted notifications directly into SQLite:

```sql
CREATE TABLE IF NOT EXISTS pending_bank_notifications (
  id TEXT PRIMARY KEY,
  package_name TEXT NOT NULL,
  notification_key TEXT NOT NULL UNIQUE,
  title TEXT,
  body TEXT NOT NULL,
  post_time INTEGER NOT NULL,
  is_processed INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL
);
```

### 2.4. Processing Pipeline (`NotificationSyncProvider` & `InboxRepository`)

When the application is in foreground or awakened by lifecycle resume:
1. `NotificationSyncProvider` queries unparsed records (`is_processed = 0`) from `pending_bank_notifications`.
2. For each record, the payload is constructed and passed to `GeminiExtractionService.extractTransaction()`:
   * `emailBody` $\leftarrow$ `body` (or combined `title` + `body`).
   * `emailSubject` $\leftarrow$ `title`.
   * `sender` $\leftarrow$ `package_name` (e.g., `com.nu.production`).
   * `emailDate` $\leftarrow$ ISO-8601 representation of `post_time`.
   * `messageId` $\leftarrow$ `notification_key`.
3. The extracted `InboxTransactionModel` is matched against local `Account` entities (matching account mask or default neobank account), `Category` entities, and active `Subscription` entities.
4. An atomic SQLite transaction inserts the record into `transactions`, adjusts account balance, and marks `is_processed = 1` in `pending_bank_notifications`.

---

## 3. Invariants

1. **Strict Whitelist Isolation:** The native `NotificationListenerService` must discard notifications from non-whitelisted packages immediately in native memory. Under no circumstance may private messages (e.g. WhatsApp, SMS, personal email) be persisted or sent to the AI extraction pipeline.
2. **Idempotency Guarantee:** Duplicate notification deliveries with the same `notification_key` or `(package_name, post_time, body)` hash must not produce duplicate transactions in SQLite.
3. **100% Client-Side Execution:** Notification interception, storage, Gemini API calls, and transaction persistence must execute entirely on-device without any intermediary proxy backend.
4. **Resilient Offline Buffering:** If Gemini API is unreachable (e.g. offline device), the notification remains stored in `pending_bank_notifications` with `is_processed = 0` to be re-processed upon network recovery.

---

## 4. Examples

### 4.1. Raw Nubank Notification Payload
```json
{
  "packageName": "com.nu.production",
  "title": "Compra aprobada",
  "body": "Compra por $ 45.000 en EXITO CALLE 80 con tu tarjeta débito terminada en 1234",
  "postTime": 1726359000000,
  "notificationKey": "0|com.nu.production|1001|null|10234"
}
```

### 4.2. Extracted Structured Transaction
```json
{
  "id": "tx_notif_0_com_nu_production_1001_null_10234",
  "amount": 4500000,
  "currency": "COP",
  "type": "expense",
  "merchant": "EXITO CALLE 80",
  "category": "Groceries",
  "accountMask": "1234",
  "date": "2026-09-14T20:30:00.000Z",
  "confidenceScore": 0.98
}
```

---

## 5. Verification Plan

- [ ] Unit tests verify `BankNotificationRule` / `MonitoredBankApp` model serialization and dynamic whitelist updates.
- [ ] Unit tests verify `NotificationSyncProvider` parses buffered notifications and handles duplicate prevention.
- [ ] Integration tests verify that `GeminiExtractionService` successfully extracts transaction amounts and merchants from Nubank push notification text formats.
- [ ] Android native compilation verified with `NotificationListenerService` declared in `AndroidManifest.xml`.
