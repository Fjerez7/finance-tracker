---
id: rfc-00002-i18n-currency-settings
type: rfc
code: "00002"
slug: i18n-currency-settings
title: Internationalization, Multi-Currency Formatting, and Settings Architecture
description: Proposes standard Flutter localization (gen-l10n with ARB), decoupled currency formatting (COP and USD), persistent SettingsProvider backed by SQLite, and a dedicated Settings module.
status: accepted
created: 2026-09-06
updated: 2026-09-06
authors: []
tags:
  - i18n
  - localization
  - currency
  - settings
  - flutter
  - sqlite
  - provider
related:
  - rfc-00001-arquitectura-base-de-finance-tracker
supersedes: []
superseded_by: null
aliases:
  - "RFC 00002: Internationalization, Multi-Currency Formatting, and Settings Architecture"
---

# RFC 00002: Internationalization, Multi-Currency Formatting, and Settings Architecture

## 1. Problem

The initial version (v1) of Finance Tracker has solid core financial tracking capabilities but exhibits several architectural gaps regarding internationalization, financial regionalization, and user configuration:

- **Hardcoded English UI Strings:** All presentation screens, dialogs, form validation errors, bottom navigation labels, and charts contain hardcoded English strings, preventing Spanish-speaking users from interacting comfortably with the application.
- **Coupled & Inflexible Currency Formatting:** `CurrencyFormatter` currently assumes USD formatting (`$12.50`) and hardcodes `en_US` locale. Users in other regions—specifically Colombia (`COP`)—require thousand separators and zero-decimal formatting for standard everyday amounts (e.g., `$50.000`), while maintaining zero-float integer storage in SQLite.
- **Absence of Centralized Settings Management:** There is no dedicated Settings screen or unified state provider for user preferences (language, currency, theme mode, and cloud backup navigation).
- **Static Default Categories in Database:** System categories (`Groceries`, `Salary`, `Dining`, etc.) are seeded as static English strings in SQLite, creating inconsistency when switching UI languages.

---

## 2. Proposal

We propose an architectural enhancement encompassing four core pillars:

```
+-----------------------------------------------------------------------------------+
|                                  Flutter UI Shell                                 |
|                                                                                   |
|  +---------------------+   +---------------------+   +-------------------------+  |
|  |   Settings Screen   |   |   Dashboard/Screens |   |   MaterialApp Router    |  |
|  +----------+----------+   +----------+----------+   +------------+------------+  |
+-------------|-------------------------|---------------------------|---------------+
              |                         |                           |
              v                         v                           v
+-----------------------------------------------------------------------------------+
|                               State Management Layer                              |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                              SettingsProvider                               |  |
|  |  - locale: Locale? (null = System, 'es', 'en')                              |  |
|  |  - currency: AppCurrency (usd, cop)                                         |  |
|  |  - setLocale(Locale?), setCurrency(AppCurrency)                             |  |
|  +-------------------------------------+---------------------------------------+  |
+----------------------------------------|------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                         Core Utilities & Storage Layer                            |
|                                                                                   |
|  +-------------------------+   +-------------------------+   +-----------------+  |
|  |    AppLocalizations     |   |    CurrencyFormatter    |   | SQLite Database |  |
|  |   (gen-l10n / ARB)      |   |  (Decoupled Formatting) |   | (app_settings)  |  |
|  +-------------------------+   +-------------------------+   +-----------------+  |
+-----------------------------------------------------------------------------------+
```

### 2.1. Native Flutter Internationalization (`gen-l10n` + ARB)
- Integrate official `flutter_localizations` SDK package and `intl`.
- Configure `l10n.yaml` in project root with synthetic package output.
- Author localized resource bundles:
  - `lib/l10n/app_en.arb` (English reference bundle).
  - `lib/l10n/app_es.arb` (Spanish translation bundle).
- Provide type-safe string lookup across widgets using `AppLocalizations.of(context)!`.

### 2.2. Decoupled Currency Model (`AppCurrency`)
Financial currency must remain decoupled from UI language (e.g., an English speaker tracking expenses in Colombia in COP, or a Spanish speaker in the US using USD).
- Define `AppCurrency` enum:
  - `usd`: Code `'USD'`, Symbol `'\$'`, Decimals `2`, Name `'US Dollar'`.
  - `cop`: Code `'COP'`, Symbol `'\$'`, Decimals `0`, Name `'Colombian Peso'`.
- Update `CurrencyFormatter` to format amounts based on the selected `AppCurrency` and active locale while keeping underlying SQLite records stored consistently in integer cents.

### 2.3. Unified Settings State & Persistence (`SettingsProvider`)
- Create `SettingsProvider` (`ChangeNotifier`) to expose reactive state:
  - `Locale? locale` (`null` represents device system default).
  - `AppCurrency currency` (defaults to USD or detected region).
- Persist settings in an `app_settings` key-value table within the existing SQLite database (`database_helper.dart`), avoiding extra third-party plugins.

### 2.4. Dedicated Settings Module (`SettingsScreen`)
- Add an AppBar action icon (⚙️) on Dashboard and main navigation screens.
- Provide a clean Material 3 Settings UI with sections:
  - **Preferences:** Language selector dialog/sheet (`System Default`, `Español`, `English`), Currency selector (`USD`, `COP`).
  - **Data & Storage:** Cloud Backup tile linking directly to `BackupSettingsScreen`.
  - **About:** App version, build info, and architecture notes.

### 2.5. Default Category Localization
- Maintain immutable category keys (`groceries`, `salary`, `transport`, etc.) for seeded system categories.
- UI layer maps system category keys to `AppLocalizations` strings, while custom user-created categories display their stored custom titles.

---

## 3. Alternatives Considered

- **Alternative A: Third-Party Packages (`easy_localization`, `slang`):**
  - *Discarded:* Adds external dependency bloat and non-standard build pipelines. Flutter's official `gen-l10n` with ARB files is mature, natively supported, and ensures long-term framework compatibility.
- **Alternative B: `shared_preferences` for Settings Persistence:**
  - *Discarded:* Introducing an additional plugin is unnecessary when SQLite already handles all local persistence reliably with zero additional native dependencies.
- **Alternative C: Binding Currency directly to Language/Locale:**
  - *Discarded:* Violates financial domain modeling. Language is a display preference, whereas Currency is an economic dimension.

---

## 4. Tradeoffs

| Pro | Con |
|-----|-----|
| Full bilingual support (Spanish & English) matching standard Flutter practices | Requires extracting and refactoring existing hardcoded strings across all screens |
| Decoupled currency system supporting COP (zero decimals) and USD (two decimals) | Formatting logic must handle currency-specific decimal rules and parsing |
| Zero new external package dependencies (uses SDK localizations & existing SQLite) | Requires initial SQLite migration/table creation for `app_settings` |
| Instant hot-reloading language and currency switches | State providers must be registered at root `MultiProvider` level |

---

## 5. Acceptance Criteria

- [ ] `l10n.yaml`, `app_en.arb`, and `app_es.arb` created and integrated with `MaterialApp`.
- [ ] All UI screens (Dashboard, Transactions, Budgets, Subscriptions, Accounts, Backup) localized in English and Spanish.
- [ ] `SettingsProvider` created and integrated into root `MultiProvider`.
- [ ] Key-value `app_settings` table implemented in SQLite `DatabaseHelper` with auto-migration.
- [ ] `AppCurrency` enum implemented supporting `USD` and `COP`.
- [ ] `CurrencyFormatter` formats USD with 2 decimals and COP with 0 decimals appropriately.
- [ ] `SettingsScreen` created with language selector, currency selector, and link to `BackupSettingsScreen`.
- [ ] Language changes take effect immediately across all widgets without app restart.
- [ ] All unit and widget tests pass without regressions.

---

## 6. Open Questions

- None at present. All architectural decisions validated and aligned.
