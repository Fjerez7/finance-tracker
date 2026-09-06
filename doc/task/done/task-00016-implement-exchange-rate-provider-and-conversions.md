---
id: task-00016-implement-exchange-rate-provider-and-conversions
type: task
code: "00016"
slug: implement-exchange-rate-provider-and-conversions
title: Implement Exchange Rate Provider and Conversions
description: Implement ExchangeRateProvider managing network fetching, 24h caching, fallback, currency conversion calculations, and MultiProvider registration.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - state-management
  - provider
  - exchange-rate
  - calculations
related:
  - plan-00003-multi-currency-transactions-plan
  - rfc-00003-multi-currency-transactions-exchange-rates
supersedes: []
superseded_by: null
---

# Task 00016: Implement Exchange Rate Provider and Conversions

## 1. Prime Directive

> [!Prime Directive]
> Implement `ExchangeRateProvider` to orchestrate live network fetching with `ExchangeRateService`, SQLite caching with `ExchangeRateRepository`, and exact integer cents conversion math with decimal scale adjustments between USD and COP.

## 2. Specs

- **Module:** `ui/lib/providers`, `ui/lib/core/utils`
- **Dependencies:** `ExchangeRateService`, `ExchangeRateRepository`

## 3. Checklist

### 3.1. Phase A — Exchange Rate Provider & Conversion Engine

- [x] Implement `ExchangeRateProvider` (`ChangeNotifier`) with `fetchRates({bool force = false})`, `getRate(String from, String to)`, and `convertAmount(int amountCents, String fromCurrency, String toCurrency, {double? customRate})`.
- [x] Implement unit precision normalization: correctly convert between 2-decimal currencies (USD) and 0-decimal currencies (COP) without fractional rounding loss.
- [x] Register `ExchangeRateProvider` in `MultiProvider` in `main.dart`.

### 3.2. Phase B — Unit Tests & Quality Gate

- [x] Create `test/unit/providers/exchange_rate_provider_test.dart` validating cache hits, network updates, manual override conversions, and precision edge cases.
- [x] Ensure all unit tests pass with 0 errors.

