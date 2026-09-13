---
id: task-00019-implement-bank-email-ingestion-and-firestore-sync-in-flutter
type: task
code: "00019"
slug: implement-bank-email-ingestion-and-firestore-sync-in-flutter
title: Implement Bank Email Ingestion and Firestore Sync in Flutter
description: Implement Firebase Firestore data layer, account and category matching engine, SQLite atomic persistence, and UI sync hooks for bank email transaction ingestion.
status: done
created: 2026-09-13
updated: 2026-09-13
tags:
  - automation
  - firestore
  - sync
  - sqlite
  - flutter
related:
  - spec-00003-bank-email-transaction-sync-pipeline
supersedes: []
superseded_by: null
---

# Task 00019: Implement Bank Email Ingestion and Firestore Sync in Flutter

## 1. Prime Directive

> [!Prime Directive]
> Connect the Flutter client to Cloud Firestore, fetch staged bank transactions (`status: PENDING`), match them against SQLite accounts and categories, persist them atomically updating account balances, and acknowledge ingestion to Firestore with zero duplicate records.

## 2. Specs

- **Specification:** `doc/spec/interface/spec-00003-bank-email-transaction-sync-pipeline.md`
- **Module:** `ui/lib/data/datasources/remote`, `ui/lib/data/models`, `ui/lib/data/repositories`, `ui/lib/domain/usecases`, `ui/lib/presentation/providers`
- **Dependencies:** `firebase_core`, `cloud_firestore`, `sqflite`, `provider`

## 3. Checklist

### 3.1. Phase A — Firebase Setup & Remote Data Layer

- [x] Add `firebase_core` and `cloud_firestore` dependencies to `ui/pubspec.yaml`.
- [x] Create `InboxTransaction` domain entity in `ui/lib/domain/entities/inbox_transaction.dart`.
- [x] Implement `InboxTransactionModel` with `fromFirestore` and `toMap` in `ui/lib/data/models/inbox_transaction_model.dart`.
- [x] Implement `InboxRemoteDataSource` interface and concrete implementation in `ui/lib/data/datasources/remote/inbox_remote_datasource.dart` to query `PENDING` documents and acknowledge with `SYNCED`.

### 3.2. Phase B — Repository, Matching Engine & SQLite Persistence

- [x] Define `InboxRepository` in `ui/lib/domain/repositories/inbox_repository.dart`.
- [x] Implement `InboxRepositoryImpl` in `ui/lib/data/repositories/inbox_repository_impl.dart` with smart account matching (`bank_name`, `account_type`, `account_mask`) and category matching against SQLite tables.
- [x] Implement `SyncInboxTransactionsUseCase` executing atomic SQLite insertions and account balance updates (`balance_cents`).
- [x] Implement fallback to default account and default categories for unmapped metadata.

### 3.3. Phase C — Provider, UI Sync Hooks & Verification

- [x] Implement `InboxSyncProvider` managing sync lifecycle, loading state, and notification badges.
- [x] Wire automatic synchronization on app initialization and implement pull-to-refresh sync in transaction feed.
- [x] Write unit tests for `InboxTransactionModel`, `AccountMatcher`, and `SyncInboxTransactionsUseCase`.
- [x] Run `flutter analyze` and verify all tests pass with 0 warnings.
