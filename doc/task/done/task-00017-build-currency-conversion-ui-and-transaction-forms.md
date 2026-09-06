---
id: task-00017-build-currency-conversion-ui-and-transaction-forms
type: task
code: "00017"
slug: build-currency-conversion-ui-and-transaction-forms
title: Build Currency Conversion UI and Transaction Forms
description: Build CurrencyConversionCard and integrate multi-currency selector and conversion controls into QuickTransactionScreen and AddEditSubscriptionScreen.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - ui
  - widgets
  - forms
  - currency-conversion
related:
  - plan-00003-multi-currency-transactions-plan
  - rfc-00003-multi-currency-transactions-exchange-rates
supersedes: []
superseded_by: null
---

# Task 00017: Build Currency Conversion UI and Transaction Forms

## 1. Prime Directive

> [!Prime Directive]
> Build the `CurrencyConversionCard` component displaying foreign amounts, live/cached exchange rates, manual TRM editing dialog, and integrate it into `QuickTransactionScreen` and `AddEditSubscriptionScreen`.

## 2. Specs

- **Module:** `ui/lib/presentation/widgets`, `ui/lib/presentation/screens`
- **Dependencies:** `ExchangeRateProvider`, `SettingsProvider`, `AppLocalizations`

## 3. Checklist

### 3.1. Phase A — Currency Conversion Card Widget

- [x] Create `CurrencyConversionCard` in `lib/presentation/widgets/cards/currency_conversion_card.dart` showing foreign amount, live rate with refresh icon button, edit rate button, and converted debited amount.
- [x] Add ARB localization strings for exchange rate labels, conversion hints, and rate edit dialog in `app_en.arb` and `app_es.arb`.

### 3.2. Phase B — Integration in Transaction & Subscription Screens

- [x] Add currency selector chip next to the amount input in `QuickTransactionScreen` and `AddEditTransactionDialog`.
- [x] Conditionally display `CurrencyConversionCard` when the selected transaction currency differs from the selected account currency.
- [x] Add currency selector and conversion preview in `AddEditSubscriptionScreen`.
- [x] Pass `originalCurrency`, `originalAmountCents`, and `exchangeRate` when saving transactions.
