---
id: task-00020-implement-client-side-gmail-oauth-bank-ingestion-pipeline
type: task
code: "00020"
slug: implement-client-side-gmail-oauth-bank-ingestion-pipeline
title: Implement Client-Side Gmail OAuth Bank Ingestion Pipeline
description: Implement in-app Google Sign-In, direct Gmail REST API bank email querying, Gemini client-side extraction, and persistent labeling in Flutter.
status: done
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

- [x] Add and configure `google_sign_in: ^6.2.1` and `googleapis: ^15.0.0` (or direct HTTP client) with required scopes (`gmail.readonly`, `gmail.modify`, `gmail.labels`, `drive.appdata`).
- [x] Implement `GmailAuthService` handling interactive sign-in, silent sign-in (`signInSilently`), token refresh, authorization checks, and sign-out.
- [x] Implement `GmailRemoteDataSource` to search unhandled bank emails, fetch message snippets/payloads, and apply `FinanceTracker/Processed` labels.
- [x] Implement `GeminiExtractionService` invoking Gemini 3.6 Flash structured JSON extraction on-device.
- [x] Integrate with `InboxRepositoryImpl` and `InboxSyncProvider` to maintain existing multi-factor subscription detection and atomic SQLite persistence.
- [x] Add a user-facing toggle and status card in `SettingsScreen` and dedicated `GmailSyncSettingsScreen` for "Gmail Bank Synchronization".
- [x] Configure Google Cloud / Firebase Android OAuth Client with SHA-1 / SHA-256 fingerprints and enable Gmail & Google Drive APIs.
- [x] Implement automatic silent session restoration (`checkExistingAuth()`) on cold startup and lifecycle resume (`AppLifecycleState.resumed`).
- [x] Write unit and widget tests covering all auth states, API parsing, and sync triggers.
- [x] Execute `flutter analyze` and `flutter test` to ensure 100% pass rate and 0 issues.

---

## 3. Verification Criteria

- [x] Interactive Google Sign-In prompts for Gmail scopes successfully.
- [x] Silent Google Sign-In session restores automatically on app launch and lifecycle resume.
- [x] Triggering sync fetches live bank notification emails directly from Gmail (Bancolombia, Nu, RappiCard).
- [x] Structured JSON extraction correctly identifies account, amount, merchant, and category.
- [x] Emails receive the `FinanceTracker/Processed` label in Gmail preventing duplicate processing.
- [x] End-to-end verified on physical Android release build (`app-release.apk`).
- [x] All 207 unit/widget tests pass cleanly.
