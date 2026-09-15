---
id: task-00023-implement-biometric-security-and-app-lock-authentication
type: task
code: "00023"
slug: implement-biometric-security-and-app-lock-authentication
title: Implement Biometric Security and App Lock Authentication
description: Integrate local_auth to provide biometric (Fingerprint/Face ID) and device PIN locking with automatic lifecycle timeout protection.
status: done
category: done
created: 2026-09-13
updated: 2026-09-13
assignees:
  - Antigravity
tags:
  - security
  - biometrics
  - app-lock
  - local-auth
related:
  - "[[spec-00007-biometric-security-and-app-lock-authentication]]"
  - "[[spec-00006-security-hardening-and-secure-storage]]"
supersedes: []
superseded_by: null
aliases:
  - "TASK 00023: Implement Biometric Security and App Lock Authentication"
---

# TASK 00023: Implement Biometric Security and App Lock Authentication

## 1. Description

Implement biometric authentication and automatic app locking per `[[spec-00007-biometric-security-and-app-lock-authentication]]`.

This task introduces:
1. Native hardware biometric challenge (Fingerprint / Face ID / StrongBiometrics) with OS device passcode fallback using `local_auth`.
2. Reactive `AppLockProvider` tracking cold boot and background inactivity timeout locks.
3. Impenetrable `AppLockScreen` overlay shielding financial ledger data until authenticated.
4. Settings screen controls to toggle biometric lock with instant ownership challenge and auto-lock timeout preferences.
5. Android fragment support in `MainActivity.kt` (`FlutterFragmentActivity`) and biometric permissions in `AndroidManifest.xml`.

---

## 2. Checklist

### Phase 1 — Dependencies & Android Manifest
- [x] Add `local_auth: ^2.3.0` to `ui/pubspec.yaml`.
- [x] Update `MainActivity.kt` to extend `FlutterFragmentActivity` while preserving `FLAG_SECURE`.
- [x] Add `USE_BIOMETRIC` permission declaration in `AndroidManifest.xml`.

### Phase 2 — Service & State Layer
- [x] Create `BiometricAuthService` implementing hardware checks, enrollment verification, and authentication prompts.
- [x] Create `AppLockProvider` managing `isAppLocked`, auto-lock timeouts, and persisting preferences in `FlutterSecureStorage`.
- [x] Register `AppLockProvider` in `MultiProvider` tree in `main.dart`.

### Phase 3 — UI & Lifecycle Integration
- [x] Create `AppLockScreen` overlay with app logo, status indicators, and biometric unlock actions.
- [x] Implement `WidgetsBindingObserver` in root app shell to track pause/resume lifecycle and trigger auto-lock on timeout.
- [x] Add Biometric App Lock toggle and timeout selector tile in `SettingsScreen`.
- [x] Add English and Spanish localization strings in `app_en.arb` and `app_es.arb`.

### Phase 4 — Testing & Release Build
- [x] Create unit tests in `test/unit/services/biometric_auth_service_test.dart` and `test/unit/providers/app_lock_provider_test.dart`.
- [x] Create widget tests in `test/widget/presentation/security/app_lock_screen_test.dart`.
- [x] Run `flutter analyze` and `flutter test` ensuring 0 issues and 100% pass rate.
- [x] Compile release APK `flutter build apk --release`.

---

## 3. Verification Criteria

- [x] App prompts for fingerprint / Face ID / PIN when enabled on cold start and background resume.
- [x] Toggling biometric lock in Settings requires instant biometric validation.
- [x] `flutter analyze` and `flutter test` pass with 0 errors.
- [x] Release APK compiles successfully.
