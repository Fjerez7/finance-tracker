---
id: task-00015-database-migration-v3-and-exchange-rate-repository
type: task
code: "00015"
slug: database-migration-v3-and-exchange-rate-repository
title: Database Migration v3 and Exchange Rate Repository
description: Upgrade SQLite database schema to version 3 with exchange_rates cache table, add multi-currency fields to transactions and subscriptions, and implement ExchangeRateRepository.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - database
  - sqlite
  - migration
  - repository
related:
  - plan-00003-multi-currency-transactions-plan
  - rfc-00003-multi-currency-transactions-exchange-rates
supersedes: []
superseded_by: null
---

# Task 00015: Database Migration v3 and Exchange Rate Repository

## 1. Prime Directive

> [!Prime Directive]
> Upgrade SQLite schema to version 3 with an `exchange_rates` caching table, extend `transactions` and `subscriptions` with `original_currency`, `original_amount_cents`, and `exchange_rate`, and implement the SQLite `ExchangeRateRepository`.

## 2. Specs

- **Module:** `ui/lib/data/datasources/local`, `ui/lib/data/models`, `ui/lib/domain/repositories`
- **Dependencies:** `sqflite`, `DatabaseHelper`

## 3. Checklist

### 3.1. Phase A — Schema Migration & Models

- [x] Update `DatabaseConstants` with `tableExchangeRates`, column constants, and bump `databaseVersion` to 3.
- [x] Add `_onUpgrade` migration in `DatabaseHelper` creating `tableExchangeRates` and adding columns to `tableTransactions` and `tableSubscriptions` if not existing.
- [x] Update `TransactionModel` and `Transaction` entity to serialize/deserialize `originalCurrency`, `originalAmountCents`, and `exchangeRate`.
- [x] Update `SubscriptionModel` and `Subscription` entity to support `currency` and multi-currency properties.

### 3.2. Phase B — Exchange Rate Repository & Tests

- [x] Create `ExchangeRateRepository` interface in `lib/domain/repositories/exchange_rate_repository.dart`.
- [x] Implement `SqliteExchangeRateRepository` in `lib/data/repositories/sqlite_exchange_rate_repository.dart` with `getCachedRates(String baseCurrency)` and `saveRates(String baseCurrency, Map<String, double> rates)`.
- [x] Update and expand unit tests for `DatabaseHelper` and `TransactionModel`.

