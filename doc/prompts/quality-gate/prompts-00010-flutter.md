---
id: prompts-00010-flutter
type: prompts
code: "00010"
slug: flutter
title: Flutter & Dart Quality Gate
description: Quality-gate prompt for Dart and Flutter work that must be completed after implementation.
category: quality-gate
created: 2026-08-30
updated: 2026-08-30
tags:
  - flutter
  - dart
  - quality-gate
---

# Prompt: Flutter & Dart Quality Gate

After completing any Flutter / Dart task implementation in `ui/`, run the following quality gates in this order from within the `ui/` directory:

1. Run `dart format --output=none --set-exit-if-changed .`.
   Ensure all Dart files adhere strictly to standard Dart formatting conventions. If formatting differences exist, run `dart format .` and verify.
2. Run `flutter analyze`.
   Fix every reported error, warning, and lint hint before continuing.
3. Run `flutter test`.
   All unit and widget tests must pass completely before finishing the task.

If any check fails, fix the issue and rerun the failed command until all quality gates pass with zero issues.
