---
id: rfc-00001-arquitectura-base-de-finance-tracker
type: rfc
code: "00001"
slug: arquitectura-base-de-finance-tracker
title: Local-First Architecture with Google Drive Backup
description: Establishes the foundational v1 architecture for Finance Tracker as a privacy-focused, local-first Flutter mobile application using SQLite, Provider, and automated encrypted backups to Google Drive.
status: accepted
created: 2026-08-30
updated: 2026-08-30
authors: []
tags:
  - architecture
  - flutter
  - sqlite
  - provider
  - local-first
  - google-drive
  - backup
  - mobile
related:
  - research-00001-evaluacion-de-arquitectura-y-stack-tecnologico
supersedes: []
superseded_by: null
aliases:
  - "RFC 00001: Local-First Architecture with Google Drive Backup"
---

# RFC 00001: Local-First Architecture with Google Drive Backup

## 1. Problem

Personal finance users require a fast, private, and frictionless mobile application to log expenses, track budgets, and inspect financial balances without relying on a persistent internet connection or external server availability:
- **Zero Latency & Offline Independence:** Expense logging must happen in real time (< 100ms) anywhere, with zero dependency on cellular network status or third-party server uptime.
- **Privacy & Ownership:** Financial data belongs strictly to the user and should not be hosted on centralized third-party servers unless explicitly chosen.
- **Data Loss Prevention (Backups):** Because the app is local-first, device loss or hardware upgrades require a seamless, automated cloud backup mechanism connected to the user's personal cloud storage (Google Drive).
- **Extensibility:** The codebase must maintain clean architectural boundaries (Repository Pattern) so that a central multi-user backend (e.g., Spring Boot) can be connected in future milestones (v2) without refactoring UI or domain logic.

---

## 2. Proposal

We propose a **Local-First Mobile Architecture** for Finance Tracker v1:
1. **Frontend & Runtime:** **Flutter (Dart 3.x)** targeting mobile (Android & iOS).
2. **State Management:** **Provider** (`ChangeNotifierProvider`, `Consumer`) for clean, reactive separation between UI and financial calculations.
3. **Local Database:** Embedded **SQLite** database (via `sqflite` or `drift`) providing ACID transactional guarantees and instant query execution.
4. **Cloud Backup Engine:** Seamless integration with **Google Drive API** (utilizing the hidden, secure `appDataFolder` scope via `google_sign_in` and `googleapis`) for one-tap and scheduled cloud backups and restores.

```
+-------------------------------------------------------------------------------+
|                       Finance Tracker Mobile App (Flutter)                    |
|                                                                               |
|   +-----------------------------------------------------------------------+   |
|   |                         UI / Presentation Layer                       |   |
|   |         - Dashboard, Transaction Forms, Budget & Category Views       |   |
|   +-----------------------------------+-----------------------------------+   |
|                                       |                                       |
|   +-----------------------------------v-----------------------------------+   |
|   |                       Provider State Management                       |   |
|   |           - TransactionProvider, BudgetProvider, AccountProvider       |   |
|   +-----------------------------------+-----------------------------------+   |
|                                       |                                       |
|   +-----------------------------------v-----------------------------------+   |
|   |                   Domain & Repository Abstraction                     |   |
|   |                  - TransactionRepository (Interface)                  |   |
|   +-------------------+-------------------------------+-------------------+   |
|                       |                               |                       |
|   +-------------------v---------------+   +-----------v-------------------+   |
|   |     Local SQLite Persistence      |   |    Google Drive Backup Engine |   |
|   |   - SQLite Database (sqflite)     |   |   - google_sign_in            |   |
|   |   - Accounts, Transactions, Budgets|  |   - googleapis (appDataFolder)|   |
|   +-----------------------------------+   +---------------+---------------+   |
+-----------------------------------------------------------|-------------------+
                                                            |
                                            +---------------v---------------+
                                            |   User's Google Drive Account |
                                            |   (Encrypted AppData Backup)  |
                                            +-------------------------------+
```

### 2.1. Layering Pattern (Clean Architecture)

- **Presentation Layer (`lib/presentation/`):**
  - Declarative Material Design 3 widgets observing providers via `Consumer` / `context.watch`.
  - Reusable financial components (currency input fields, category pickers, transaction list tiles, expense charts via `fl_chart`).
- **Application / State Layer (`lib/providers/`):**
  - `ChangeNotifier` classes encapsulating state mutations, derived balance summaries, and filter logic.
- **Domain Layer (`lib/domain/`):**
  - Pure Dart immutable entities (`Account`, `Transaction`, `Category`, `Budget`).
  - Abstract repository interfaces (`FinanceRepository`, `BackupRepository`).
- **Data Layer (`lib/data/`):**
  - `SqliteFinanceRepository`: Concrete implementation executing typed SQL queries against local SQLite.
  - `GoogleDriveBackupService`: Handles OAuth2 authorization, snapshot serialization, and Google Drive `appDataFolder` sync.

### 2.2. Data Persistence & Precision

- **Storage Engine:** SQLite embedded via `sqflite` (or `drift` for typed queries).
- **Financial Precision Invariant:** All monetary amounts are stored as exact integer values (cents / minor units) or using a dedicated `Decimal` package. Zero IEEE-754 floating-point numbers (`double`/`float`) for money math.
- **Audit Fields:** Every entity schema includes `id` (UUIDv4 string), `created_at` (ISO8601 UTC timestamp), `updated_at`, and `deleted_at` (soft delete support).

### 2.3. Google Drive Cloud Backup & Restore Workflow

1. **Authentication:** User signs in with their existing Google Account using `google_sign_in`.
2. **Private AppData Storage:** Backups are stored in Google Drive's hidden `appDataFolder` (`https://www.googleapis.com/auth/drive.appdata`). This folder is strictly private to the application and cannot be accidentally deleted or tampered with from the user's standard Drive file list.
3. **Backup Payload:**
   - Database snapshot serialized into structured, versioned JSON (`finance_tracker_backup_v1_<timestamp>.json`) containing accounts, categories, transactions, and budgets.
4. **Restore Flow:**
   - The app lists available backup snapshots from the user's Drive, displays backup metadata (date, total transactions), and provides a single-click restore process that verifies data integrity before applying.

---

## 3. Alternatives Considered

- **Alternative A: Fullstack Monorepo with Spring Boot Backend in v1**
  - *Discarded for v1:* Introduces unnecessary hosting costs, server maintenance, JWT expiration friction, and deployment complexity for a single-user personal mobile application.
- **Alternative B: Firebase Cloud Firestore / Supabase Backend**
  - *Discarded:* Centralizes personal financial data on third-party cloud database servers, requires ongoing paid quotas, and compromises the core privacy-first guarantee.
- **Alternative C: Unsynced Local-Only Storage (No Backup Engine)**
  - *Discarded:* Puts the user at risk of permanent data loss upon phone damage, loss, or OS reset. Google Drive AppData integration delivers the perfect balance of zero hosting cost and reliable backup security.

---

## 4. Tradeoffs

| Pro | Con |
|-----|-----|
| True local-first architecture: instantaneous UI updates (< 1ms) and 100% offline usability | Multi-device simultaneous live collaboration is deferred to v2 |
| Zero server hosting costs and zero backend maintenance overhead | Backup requires user to authorize Google Drive permissions |
| Maximum user privacy: financial data never leaves the device except to the user's own Drive | Google Drive integration requires configuring Google Cloud Console OAuth Client ID |
| Clean Repository pattern ensures trivial connection to a Spring Boot backend in v2 | Dual codebase preparation requires strict adherence to domain interfaces |

---

## 5. Acceptance Criteria

- [ ] Flutter application structured under `ui/` with Clean Architecture (`presentation`, `providers`, `domain`, `data`).
- [ ] SQLite database initialized with tables for `accounts`, `categories`, `transactions`, and `budgets` using UUID primary keys.
- [ ] Financial domain entities implemented with exact decimal/integer precision rules.
- [ ] Provider state management configured for real-time balance calculations, budget monitoring, and transaction filtering.
- [ ] Google Sign-In integration configured with Google Cloud OAuth Client ID for Android/iOS.
- [ ] Google Drive Backup Service implemented with:
  - Export database snapshot to `appDataFolder`.
  - List available cloud backup files with timestamps.
  - Import / Restore database from cloud snapshot with integrity validation.
- [ ] Unit and widget test suite configured for SQLite repository and balance calculation domain logic.

---

## 6. Resolved Decisions

- **Backup Frequency:** v1 will feature manual "Backup Now" and "Restore" buttons in the Settings screen, with a configurable toggle for automated weekly backups when connected to Wi-Fi.
- **Local Export Formats:** A simple "Export to CSV" utility will be included in the Settings screen alongside Google Drive backups to give users raw local access to their data.
