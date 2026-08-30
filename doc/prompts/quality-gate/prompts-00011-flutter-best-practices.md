---
id: prompts-00011-flutter-best-practices
type: prompts
code: "00011"
slug: flutter-best-practices
title: Flutter & Dart Best Practices
description: Governed best-practices guidelines for Flutter and Dart implementation tasks.
category: quality-gate
created: 2026-08-30
updated: 2026-08-30
tags:
  - flutter
  - dart
  - best-practices
---

# Prompt: Flutter & Dart Best Practices

When implementing Dart and Flutter code, you must adhere to the following best practices:

## 1. Widget Performance & Lifecycle
- **Const Constructors:** Always declare and use `const` constructors for widgets with immutable properties to allow Flutter to short-circuit subtree rebuilds.
- **Widget Extraction:** Extract complex UI sections into separate, private `StatelessWidget` classes rather than helper functions returning `Widget`. Helper functions bypass widget lifecycle caching.
- **Selective Rebuilding:** Place `Consumer<T>` widgets as deep in the widget tree as possible to rebuild only the minimal subtree requiring updates.

## 2. State Management with Provider
- **Read vs. Watch:**
  - Use `context.read<T>()` inside button callbacks and user intent handlers (`onTap`, `onPressed`) to trigger actions without binding the widget to rebuild on state changes.
  - Use `context.watch<T>()` or `Consumer<T>` exclusively within the `build()` method where reactive rendering is required.
- **Lifecycle Cleanliness:** Always dispose controllers, stream subscriptions, and change notifiers in `dispose()` lifecycle hooks.

## 3. Financial Data Integrity
- **Exact Money Math:** Always calculate and store monetary values using integer minor units (`int amountCents`). Floating-point arithmetic (`double`, `float`) is strictly prohibited for money calculations.
- **Immutability:** Domain entities must be immutable with `final` fields and provide explicit `copyWith()` methods for updates.

## 4. Null Safety & Code Hygiene
- **No Force Unwrapping:** Avoid the `!` bang operator. Use explicit null checks, default values (`??`), or pattern matching.
- **Typed Errors:** Return typed failures or domain-specific exceptions instead of throwing generic errors.

## 5. Class Size & Responsibility
- **Single Responsibility:** Each class must have one cohesive responsibility. Separate unrelated concerns even when the class is below the size threshold.
- **700-Line Review Threshold:** Any manually maintained class exceeding 700 physical lines, measured from its declaration to its closing brace after formatting, requires a responsibility review before the task is considered complete.
- **Refactoring Requirement:** Identify independent responsibilities and extract cohesive widgets, services, repositories, or domain objects as appropriate. If splitting would reduce clarity or cohesion, document the justification for retaining the class.
- **No Artificial Splitting:** Do not move code into extensions, mixins, or `part` files solely to satisfy the threshold. Do not remove useful comments or compress formatting to reduce line count.
- **Generated Code:** Exclude generated code from this threshold. Never manually refactor generated files.
- **Scope Control:** Apply this review to classes created or modified by the task. Report unrelated oversized classes without expanding the task into a project-wide refactor.

## 6. Architecture & Boundaries
- **Separation of Concerns:** Keep business rules, monetary calculations, persistence, and network access outside widgets.
- **Existing Architecture:** Follow the project's established architecture and naming conventions. Do not introduce competing patterns or dependencies without a concrete need.
- **Dependency Injection:** Pass dependencies explicitly through constructors or the existing injection mechanism.
- **Proportional Abstractions:** Introduce abstractions when they clarify responsibilities, isolate external dependencies, or support meaningful reuse. Avoid speculative layers.

## 7. Async Safety & UI State
- **Build Purity:** Keep `build()` free of side effects. Do not start network requests, mutate application state, or create persistent controllers during rendering.
- **Context Safety:** After an asynchronous gap, verify that the relevant `BuildContext` or `State` is still mounted before accessing it.
- **Stale Results:** Prevent obsolete asynchronous results from overwriting newer state. Cancel work when supported, or ignore outdated responses.
- **Explicit States:** Represent loading, success, empty, and failure states explicitly where applicable.
- **Duplicate Actions:** Prevent accidental duplicate submissions while an operation is in progress.
- **Error Handling:** Do not silently swallow exceptions. Handle expected failures explicitly and preserve stack traces when propagating unexpected errors.

## 8. Financial Precision & Validation
- **Currency-Aware Amounts:** Store monetary amounts with their currency and defined minor-unit scale. Do not assume every currency uses two decimal places.
- **Explicit Rounding:** Define rounding rules for taxes, discounts, allocations, and conversions. Use exact arithmetic for intermediate calculations that require fractional precision.
- **Exact Parsing:** Parse monetary input without converting through `double`.
- **Boundary Validation:** Validate external data at API, persistence, and user-input boundaries before creating domain entities.
- **Deep Immutability:** Do not expose mutable collections from immutable entities. A `final` collection field alone does not make its contents immutable.

## 9. Verification & Completion
- **Formatting & Analysis:** Run `dart format` on changed Dart files and `flutter analyze`. Do not introduce new analyzer issues or suppress warnings merely to pass validation.
- **Behavioral Tests:** Add or update meaningful tests for changed business rules, bug fixes, and critical user interactions.
- **Financial Tests:** Cover rounding boundaries, invalid input, negative values where supported, and conservation of totals when distributing amounts.
- **Regression Safety:** Preserve existing public contracts and behavior unless the task explicitly requires changing them.
- **Honest Reporting:** State which checks were actually executed, their results, and any checks that could not be run.

## 10. Test Coverage & Quality
- **Minimum Coverage:** Maintain at least 80% line coverage for manually maintained production code, excluding generated code and external dependencies.
- **Passing Tests:** All executed tests must pass. Coverage and test success are separate requirements.
- **Automated Enforcement:** Generate coverage using `flutter test --coverage` and configure an automated quality gate to reject changes below the threshold.
- **Meaningful Assertions:** Test actual behavior, edge cases, and error handling. Do not write superficial tests or exclude code solely to meet the coverage target.
- **Critical Logic:** Prioritize business rules and monetary calculations, even when overall coverage already exceeds 80%.