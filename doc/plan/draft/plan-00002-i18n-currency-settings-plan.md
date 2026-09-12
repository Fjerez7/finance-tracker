---
id: plan-00002-i18n-currency-settings-plan
type: plan
code: "00002"
slug: i18n-currency-settings-plan
title: Internationalization Multi-Currency and Settings Implementation
description: Comprehensive implementation roadmap for Flutter localization (ES/EN), decoupled currency formatting (COP/USD), persistent SettingsProvider, and Settings UI module.
category: plan
status: draft
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
  - rfc-00002-i18n-currency-settings
supersedes: []
superseded_by: null
aliases:
  - "PLAN 00002: Internationalization Multi-Currency and Settings Implementation"
---

# PLAN 00002: Internationalization Multi-Currency and Settings Implementation

## 1. Purpose

This plan defines the end-to-end execution roadmap to implement full internationalization (Spanish and English), multi-currency formatting (US Dollar `USD` and Colombian Peso `COP`), a persistent `SettingsProvider` backed by SQLite, and a dedicated Material 3 `SettingsScreen` in the Finance Tracker application.

This plan executes the architecture approved in [[rfc-00002-i18n-currency-settings]].

---

## 2. Design Prerequisites

### 2.1 — Internationalization and Multi-Currency Architecture

**RFC:** [[rfc-00002-i18n-currency-settings]] — Accepted  
**Module:** `core/localization`, `core/utils`, `presentation/screens/settings`, `providers`

The design establishes Flutter's native `gen-l10n` ARB bundle architecture, decoupled currency formatting via `AppCurrency`, zero-float integer storage in SQLite, and reactive settings management via `SettingsProvider`.

---

## 3. Implementation Phases

### Phase 1 — Core Localization Infrastructure & ARB Bundles

**Goal:** Configure Flutter's native localization tooling and create comprehensive English and Spanish ARB translation bundles.

**RFC:** [[rfc-00002-i18n-currency-settings]]  
**Tasks:**
- [[task-00009-setup-flutter-localization-and-arb-bundles]]

**Input:** Existing codebase with hardcoded English strings.  
**Output:** Working `l10n.yaml`, generated `AppLocalizations`, `app_en.arb`, and `app_es.arb`.

- Add `flutter_localizations` to `pubspec.yaml` and configure `l10n.yaml` in `ui/`.
- Create `lib/l10n/app_en.arb` with all UI strings, placeholders, error messages, and category names.
- Create `lib/l10n/app_es.arb` with accurate Spanish translations.
- Configure `MaterialApp` with `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales`.

### Phase 2 — Settings Persistence, Currency Model & State Management

**Goal:** Implement SQLite settings persistence, `AppCurrency` enum, `SettingsProvider`, and enhanced `CurrencyFormatter`.

**RFC:** [[rfc-00002-i18n-currency-settings]]  
**Tasks:**
- [[task-00010-implement-settings-persistence-and-currency-provider]]

**Input:** Localization infrastructure from Phase 1.  
**Output:** Reactive `SettingsProvider` supporting dynamic locale and currency switches.

- Add `app_settings` key-value table migration in `DatabaseHelper`.
- Implement `AppCurrency` enum supporting `usd` (2 decimals, `$`) and `cop` (0 decimals, `$`).
- Update `CurrencyFormatter` to format financial amounts dynamically based on the active `AppCurrency` and locale.
- Implement `SettingsProvider` (`ChangeNotifier`) and register in `main.dart` `MultiProvider`.

### Phase 3 — Settings Screen & Navigation Integration

**Goal:** Build the dedicated Settings module UI and connect entry points from main navigation.

**RFC:** [[rfc-00002-i18n-currency-settings]]  
**Tasks:**
- [[task-00011-build-settings-screen-and-navigation]]

**Input:** `SettingsProvider` and localized bundles.  
**Output:** Functional `SettingsScreen` with language and currency dialogs and cloud backup integration.

- Implement `SettingsScreen` with Preferences (Language, Currency), Data & Storage (Cloud Backup tile linking to `BackupSettingsScreen`), and About section.
- Add Settings icon button (⚙️) to AppBar in `DashboardScreen` and main navigation shell.
- Verify hot language and currency switching without app reload.

### Phase 4 — Comprehensive UI Screen Localization

**Goal:** Refactor all screens, widgets, dialogs, and default categories to consume `AppLocalizations`.

**RFC:** [[rfc-00002-i18n-currency-settings]]  
**Tasks:**
- [[task-00012-localize-all-ui-screens-and-categories]]

**Input:** Working localization setup and settings screen.  
**Output:** 100% localized UI in Spanish and English across all tabs and components.

- Localize `DashboardScreen`, `AccountsScreen`, `AddEditAccountScreen`, `AccountDetailScreen`.
- Localize `TransactionListScreen`, `QuickTransactionScreen`, `TransactionDetailScreen`.
- Localize `BudgetsScreen`, `AddEditBudgetScreen`, `SavingsGoalsScreen`, `AddEditSavingsGoalScreen`.
- Localize `SubscriptionsScreen`, `AddEditSubscriptionScreen`, `AnalyticsScreen`, `BackupSettingsScreen`.
- Localize bottom navigation labels and system default categories.

### Phase 5 — Testing, Verification & Quality Gate

**Goal:** Verify regression-free execution through unit and widget tests.

**RFC:** [[rfc-00002-i18n-currency-settings]]  
**Tasks:**
- [[task-00013-verify-localization-and-currency-tests]]

**Input:** Fully localized and configurable application.  
**Output:** Clean test suite and verified localized builds.

- Add unit tests for `CurrencyFormatter` with both `USD` and `COP`.
- Add unit tests for `SettingsProvider` and SQLite settings persistence.
- Add widget tests verifying locale switching and translated text rendering.
- Run `flutter analyze` and `flutter test`.

---

## 4. Invariants

- All monetary values must remain stored as zero-float integer cents in SQLite.
- Currency choice must remain independent of UI language selection.
- All code, comments, identifiers, and documentation must be written in English.
- Custom user-created category names must be preserved verbatim without overriding.

---

## 5. Staff Engineer Review

### On the Overall Plan

**Gaps that still need RFC coverage:** None. Architectural decisions are covered by [[rfc-00002-i18n-currency-settings]].

**Flaws to watch:**
- Form input parsing for COP must accept plain integers or comma/dot thousands separators without forcing 2 decimals.
- Ensure category lookup uses immutable keys rather than display titles to avoid breaking transaction categorizations on locale changes.

**Tradeoffs accepted by this plan:**
- UI strings are extracted across all screens in Phase 4, resulting in a broad refactoring surface that requires careful widget test validation.

---

## 6. Open Questions

- None. Requirements and scope fully validated with user.