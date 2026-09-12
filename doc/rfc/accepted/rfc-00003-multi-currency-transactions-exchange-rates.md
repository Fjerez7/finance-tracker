---
id: rfc-00003-multi-currency-transactions-exchange-rates
type: rfc
code: "00003"
slug: multi-currency-transactions-exchange-rates
title: Multi-Currency Transactions and Real-Time Exchange Rate Conversion
description: Architecture for recording transactions and subscriptions in foreign currencies with real-time exchange rates from open.er-api.com, local SQLite caching, manual override, and zero-float account debiting.
status: accepted
created: 2026-09-06
updated: 2026-09-06
authors: []
tags:
  - multi-currency
  - exchange-rate
  - transactions
  - subscriptions
  - offline-first
  - sqlite
related:
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
  - rfc-00001-arquitectura-base-de-finance-tracker
  - rfc-00002-i18n-currency-settings
supersedes: []
superseded_by: null
aliases:
  - "RFC 00003: Multi-Currency Transactions and Real-Time Exchange Rate Conversion"
---

# RFC 00003: Multi-Currency Transactions and Real-Time Exchange Rate Conversion

## 1. Problem

Currently, Finance Tracker assumes that all transactions and recurring subscriptions debited against an account share the exact same currency as that account or the global display currency. 

In real-world financial management, users frequently make purchases or pay recurring subscriptions billed in a foreign currency (e.g. paying $15.99 USD for Netflix or an online purchase on an international website) while their underlying payment source (bank account or credit card) is denominated in local currency (e.g. COP - Colombian Peso).

Without multi-currency transaction logging and automated currency conversion:
1. Users must manually calculate foreign exchange conversions outside the application.
2. The application loses traceability of the original foreign amount and the applied exchange rate.
3. Subscriptions billed in USD linked to COP accounts cannot be accurately tracked and automated.

## 2. Proposal

We propose adding full **Multi-Currency Transaction and Subscription Support** with live exchange rate resolution, resilient local caching, and custom bank rate overrides:

### 2.1 — External Exchange Rate Service (`open.er-api.com`)
- Integrate a lightweight `ExchangeRateService` consuming `https://open.er-api.com/v6/latest/{CURRENCY}`.
- Free, open-access, zero-authentication endpoint supporting 160+ fiat currencies (including USD, COP, EUR, MXN, BRL, etc.) with native CORS support for Flutter Web.
- Periodic background refresh (24-hour TTL) with a manual on-demand refresh trigger (🔄) in transaction/subscription forms.

### 2.2 — Offline-First SQLite Cache (`exchange_rates` Table)
- Add a new SQLite table `exchange_rates` in database schema version 3:
  ```sql
  CREATE TABLE exchange_rates (
    base_currency TEXT NOT NULL,
    target_currency TEXT NOT NULL,
    rate REAL NOT NULL,
    last_updated TEXT NOT NULL,
    PRIMARY KEY (base_currency, target_currency)
  );
  ```
- When online, the latest rates are persisted into SQLite.
- When offline or upon network failure, the application seamlessly retrieves the latest cached rate without blocking UI or throwing errors.

### 2.3 — Zero-Float Mathematical Integrity in Financial Records
- All accounts continue to store balances in **integer cents** in their native currency.
- `Transaction` entity is extended with nullable multi-currency fields:
  - `originalCurrency` (`TEXT?`): ISO 4217 code (e.g. `'USD'`).
  - `originalAmountCents` (`INTEGER?`): Amount in foreign currency cents (e.g. `1500` for $15.00 USD).
  - `exchangeRate` (`REAL?`): Conversion rate applied at record time (e.g. `4150.0`).
  - `amountCents` (`INTEGER`): Canonical amount debited from or credited to the account in the account's native currency (e.g. `62250` COP).
- `Subscription` entity is similarly extended with `currency` and `amountCents` to allow registering subscriptions in foreign currency while associating them with any account. When a subscription payment is logged, the current exchange rate is used to create the account transaction.

### 2.4 — Interactive UI / UX in Quick Transaction & Subscription Screens
- Add a currency selector widget next to the amount input field.
- If the selected transaction currency differs from the selected account currency:
  - Display an animated **Currency Conversion Card** displaying:
    1. Foreign amount formatted in the selected currency (e.g. `$ 15.00 USD`).
    2. Live/cached exchange rate indicator (e.g. `1 USD = $ 4,150.00 COP`) with a refresh button (🔄) and an editable rate input (allowing manual override for specific bank spreads/TRMs).
    3. Live calculated equivalent amount debited from account (e.g. `~$ 62,250 COP`).
- In transaction feeds and detail views:
  - Display primary foreign amount alongside secondary converted account amount: `$ 15.00 USD (~$ 62,250 COP)`.

## 3. Alternatives Considered

- **Alternative A: Strict 100% Manual Exchange Rate (No API)**
  - *Discarded:* Forces users to manually look up exchange rates on external websites for every foreign expense, creating significant friction.
- **Alternative B: Frankfurter API (`api.frankfurter.dev`)**
  - *Discarded:* Does not support Colombian Peso (COP) or most Latin American currencies as it is limited to European Central Bank data.
- **Alternative C: Socrata Colombia TRM (`datos.gov.co`)**
  - *Discarded:* Limited strictly to USD-to-COP conversion and does not support EUR or other global currencies.
- **Alternative D: Proprietary API (Fixer.io, OpenExchangeRates, CurrencyAPI)**
  - *Discarded:* Requires developer registration, API key management, secret management in client bundles, and imposes strict request quotas.

## 4. Tradeoffs

| Pro | Con |
|-----|-----|
| Seamless real-time foreign currency conversions with zero manual math. | Adds external HTTP network dependency (mitigated by local SQLite caching). |
| Offline-first resilience ensures the app operates smoothly without network connectivity. | Schema migration v3 required in `DatabaseHelper`. |
| Users can override bank-specific exchange rates and fees. | Transaction creation UI requires an expandable conversion card component. |
| Zero-float integer balance arithmetic is 100% preserved in SQLite. | Slight increase in transaction entity fields. |

## 5. Acceptance Criteria

- [x] `ExchangeRateService` fetches daily rates from `open.er-api.com` and parses JSON into strongly typed rate maps.
- [x] `DatabaseHelper` schema upgraded to version 3 with `exchange_rates` table and extended columns on `transactions` and `subscriptions`.
- [x] `ExchangeRateProvider` manages in-memory and SQLite caching, background refresh, and rate conversions.
- [x] `QuickTransactionScreen` and transaction dialogs allow selecting foreign currency, display the dynamic conversion card, and allow manual exchange rate adjustment.
- [x] `Subscription` creation allows setting foreign currency and generates transactions with converted account amounts.
- [x] `TransactionListTile` and `TransactionDetailScreen` render foreign currency and converted amount pairs.
- [x] All new logic, models, services, providers, and UI components are covered by unit and widget tests.
- [x] Static analysis (`flutter analyze`) reports 0 issues.

## 6. Open Questions

- None. Architecture, external API endpoint (`open.er-api.com`), offline caching strategy, and manual override capabilities are fully validated with the user.
