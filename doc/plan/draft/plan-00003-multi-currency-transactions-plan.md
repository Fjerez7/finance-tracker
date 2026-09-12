---
id: plan-00003-multi-currency-transactions-plan
type: plan
code: "00003"
slug: multi-currency-transactions-plan
title: Multi-Currency Transactions and Exchange Rate Plan
description: Master execution plan for implementing real-time exchange rates (open.er-api.com), SQLite caching, multi-currency transaction/subscription recording, and UI conversion widgets.
category: plan
status: draft
created: 2026-09-06
updated: 2026-09-06
authors: []
tags:
  - multi-currency
  - exchange-rate
  - transactions
  - subscriptions
  - offline-first
  - plan
related:
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - rfc-00001-arquitectura-base-de-finance-tracker
  - rfc-00002-i18n-currency-settings
  - rfc-00003-multi-currency-transactions-exchange-rates
supersedes: []
superseded_by: null
aliases:
  - "PLAN 00003: Multi-Currency Transactions and Exchange Rate Plan"
---

# PLAN 00003: Multi-Currency Transactions and Exchange Rate Plan

## 1. Purpose

This plan defines the end-to-end execution roadmap for adding multi-currency transaction and subscription recording with real-time exchange rate conversion in Finance Tracker. It fulfills the architecture specified in [[rfc-00003-multi-currency-transactions-exchange-rates]].

The implementation enables users to log expenses, incomes, transfers, and recurring subscriptions in foreign currencies (e.g. USD, EUR) against accounts denominated in another currency (e.g. COP), computing debited amounts automatically via `open.er-api.com`, storing rates offline in SQLite, and providing manual exchange rate adjustment controls.

---

## 2. Design Prerequisites

### 2.1 — Multi-Currency Architecture & Exchange Rate Resolution
**RFC:** [[rfc-00003-multi-currency-transactions-exchange-rates]] — Accepted  
**Module:** `core/services`, `data/datasources`, `domain/entities`, `providers`, `presentation`

Ensures zero-float integer arithmetic remains preserved in SQLite accounts while providing full foreign exchange conversion transparency and offline resilience.

---

## 3. Implementation Phases

### Phase 1 — Exchange Rate Service & API Client

**Goal:** Implement HTTP client for `open.er-api.com` with data models and error handling.

**RFC:** [[rfc-00003-multi-currency-transactions-exchange-rates]]  
**Tasks:**
- [[task-00014-implement-exchange-rate-service-and-models]]

**Input:** Existing core networking and HTTP libraries.  
**Output:** Tested `ExchangeRateService` providing live rates for any base currency.

- Create `ExchangeRate` model and JSON deserializer for `open.er-api.com`.
- Implement `ExchangeRateService` with timeout, status code verification, and error handling.
- Add unit tests with mock responses.

### Phase 2 — Database Schema v3 & Offline Cache Repository

**Goal:** Add SQLite `exchange_rates` cache table and extend `transactions` and `subscriptions` schemas.

**RFC:** [[rfc-00003-multi-currency-transactions-exchange-rates]]  
**Tasks:**
- [[task-00015-database-migration-v3-and-exchange-rate-repository]]

**Input:** `DatabaseHelper` schema v2.  
**Output:** Schema v3 with migration support and `ExchangeRateRepository` interface and SQLite implementation.

- Add SQLite migration in `DatabaseHelper` creating `exchange_rates` and altering `transactions` and `subscriptions`.
- Update `TransactionModel` and `SubscriptionModel` with `originalCurrency`, `originalAmountCents`, and `exchangeRate`.
- Implement `ExchangeRateRepository` with `getCachedRates` and `saveRates`.

### Phase 3 — Exchange Rate State Management & Conversion Engine

**Goal:** Implement `ExchangeRateProvider` to manage caching, live fetches, and conversion math.

**RFC:** [[rfc-00003-multi-currency-transactions-exchange-rates]]  
**Tasks:**
- [[task-00016-implement-exchange-rate-provider-and-conversions]]

**Input:** Repository and service from Phases 1 & 2.  
**Output:** Reactive `ExchangeRateProvider` integrated into `MultiProvider`.

- Implement `ExchangeRateProvider` (`ChangeNotifier`) with auto-fetch (24h TTL) and cache fallback.
- Implement conversion helpers converting foreign integer cents to local integer cents with rounding safety.
- Register `ExchangeRateProvider` in `main.dart`.

### Phase 4 — Dynamic Currency Conversion UI Components

**Goal:** Integrate currency selector and conversion card into transaction and subscription screens.

**RFC:** [[rfc-00003-multi-currency-transactions-exchange-rates]]  
**Tasks:**
- [[task-00017-build-currency-conversion-ui-and-transaction-forms]]

**Input:** Providers and localization bundles.  
**Output:** `QuickTransactionScreen` and `AddEditSubscriptionScreen` with multi-currency support and manual rate overrides.

- Build `CurrencyConversionCard` displaying foreign amount, live rate, refresh button, editable TRM, and debited amount.
- Integrate currency selector chips in `QuickTransactionScreen` and `AddEditTransactionDialog`.
- Integrate foreign currency support into `AddEditSubscriptionScreen`.

### Phase 5 — Feed Presentation, Payment Execution & Quality Gate

**Goal:** Update transaction feeds, details, subscription payment execution, and comprehensive test suite.

**RFC:** [[rfc-00003-multi-currency-transactions-exchange-rates]]  
**Tasks:**
- [[task-00018-multi-currency-feed-display-and-tests]]

**Input:** Completed UI forms and state management.  
**Output:** End-to-end multi-currency tracking verified by tests.

- Update `TransactionListTile` and `TransactionDetailScreen` to display foreign and converted amounts.
- Update `SubscriptionsProvider.paySubscription` to use dynamic exchange rates when logging payments.
- Add widget tests for `CurrencyConversionCard`, `QuickTransactionScreen`, and `TransactionListTile`.
- Run `flutter analyze` and `flutter test`.

---

## 4. Invariants

- Canonical account balance debits and credits MUST always be stored in integer cents of the account's currency.
- Foreign currency transactions must record the historical `exchangeRate` and `originalAmountCents`.
- Network errors or offline mode must NEVER block transaction logging; cached rates or manual rates are used.
- All code, identifiers, comments, and documentation must be written in English.

---

## 5. Staff Engineer Review

### On the Overall Plan

**Gaps that still need RFC coverage:** None. Covered in [[rfc-00003-multi-currency-transactions-exchange-rates]].

**Flaws to watch:**
- Handle currency decimal precision differences correctly (e.g. COP has 0 decimals for whole units, USD has 2 decimals). Conversion arithmetic between cents must correctly normalize decimal scaling factors.
- Ensure SQLite schema migration handles existing records with `NULL` for foreign fields seamlessly.

**Tradeoffs accepted by this plan:**
- Background rate updates are cached with a 24-hour TTL; immediate market shifts within the same day rely on manual refresh or manual rate adjustment.

---

## 6. Open Questions

- None. Requirements and scope fully validated with user.
