---
id: task-00020-implement-client-side-gmail-oauth-bank-ingestion-pipeline
type: task
code: "00020"
slug: implement-client-side-gmail-oauth-bank-ingestion-pipeline
title: Implement Client-Side Gmail OAuth Bank Ingestion Pipeline
description: Implement in-app Google Sign-In, direct Gmail REST API bank email querying, Gemini client-side extraction, and persistent labeling in Flutter.
status: todo
category: active
created: 2026-09-13
updated: 2026-09-13
assignees:
  - Antigravity
tags:
  - flutter
  - gmail
  - oauth2
  - gemini
  - sync
related:
  - "[[spec-00004-client-side-gmail-oauth-bank-sync]]"
  - "[[spec-00003-bank-email-transaction-sync-pipeline]]"
supersedes: []
superseded_by: null
aliases:
  - "TASK 00020: Implement Client-Side Gmail OAuth Bank Ingestion Pipeline"
---

# TASK 00020: Implement Client-Side Gmail OAuth Bank Ingestion Pipeline

## 1. Description

Implement the **v2 zero-backend bank email synchronization pipeline** directly within the Flutter application per `[[spec-00004-client-side-gmail-oauth-bank-sync]]`.

This eliminates the need for external Google Apps Scripts by enabling users to authenticate with Google Sign-In inside the app, retrieve bank transaction emails directly via the Gmail REST API, extract structured transaction payloads using Gemini Flash, and commit them atomically to local SQLite storage.

---

## 2. Checklist

- [ ] Add and configure `google_sign_in: ^6.2.1` and `googleapis: ^13.2.0` (or direct HTTP client) with required scopes (`gmail.readonly`, `gmail.modify`, `gmail.labels`).
- [ ] Implement `GmailAuthService` handling interactive sign-in, token refresh, authorization checks, and sign-out.
- [ ] Implement `GmailRemoteDataSource` to search unhandled bank emails, fetch message snippets/payloads, and apply `FinanceTracker/Processed` labels.
- [ ] Implement `GeminiExtractionService` invoking Gemini 2.5/3.6 Flash structured JSON extraction on-device.
- [ ] Integrate with `InboxRepositoryImpl` and `InboxSyncProvider` to maintain existing multi-factor subscription detection and atomic SQLite persistence.
- [ ] Add a user-facing toggle and status card in `SettingsScreen` for "Gmail Bank Synchronization".
- [ ] Write unit and widget tests covering all auth states, API parsing, and sync triggers.
- [ ] Execute `flutter analyze` and `flutter test` to ensure 100% pass rate and 0 issues.

---

## 3. Verification Criteria

- [ ] Interactive Google Sign-In prompts for Gmail scopes successfully.
- [ ] Triggering sync fetches live bank notification emails directly from Gmail.
- [ ] Structured JSON extraction correctly identifies account, amount, merchant, and category.
- [ ] Emails receive the `FinanceTracker/Processed` label in Gmail preventing duplicate processing.
- [ ] All 197+ unit/widget tests pass cleanly.
