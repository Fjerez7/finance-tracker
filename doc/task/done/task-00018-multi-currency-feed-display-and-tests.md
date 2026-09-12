---
id: task-00018-multi-currency-feed-display-and-tests
type: task
code: "00018"
slug: multi-currency-feed-display-and-tests
title: Multi-Currency Feed Display and Tests
description: Update transaction tiles and detail screens for multi-currency display, update subscription payment execution with conversions, and write comprehensive test suite.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - tests
  - feed
  - widgets
  - quality-gate
related:
  - plan-00003-multi-currency-transactions-plan
  - rfc-00003-multi-currency-transactions-exchange-rates
supersedes: []
superseded_by: null
---

# Task 00018: Multi-Currency Feed Display and Tests

## 1. Prime Directive

> [!Prime Directive]
> Display foreign and converted amount pairs in `TransactionListTile` and `TransactionDetailScreen`, integrate live exchange rate conversion when executing subscription payments, and deliver 100% passing automated test coverage.

## 2. Specs

- **Module:** `ui/lib/presentation/widgets`, `ui/lib/presentation/screens`, `ui/test`
- **Dependencies:** `TransactionsProvider`, `SubscriptionsProvider`, `ExchangeRateProvider`

## 3. Checklist

### 3.1. Phase A — Feeds & Subscription Payments

- [x] Update `TransactionListTile` to display the primary foreign amount and secondary converted account amount subtitle when `originalCurrency` is present.
- [x] Update `TransactionDetailScreen` to show original amount, applied exchange rate, and canonical debited amount.
- [x] Update `SubscriptionsProvider.paySubscription` to convert foreign amounts into the account currency before recording transactions.

### 3.2. Phase B — Comprehensive Testing & Verification

- [x] Write widget tests for `CurrencyConversionCard` verifying live rate display, manual TRM editing, and math calculations.
- [x] Write widget tests for `TransactionListTile` and `QuickTransactionScreen` with multi-currency data.
- [x] Run `flutter analyze` ensuring 0 warnings and `flutter test` ensuring 100% pass rate.
