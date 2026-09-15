import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:finance_tracker/providers/app_lock_provider.dart';
import 'package:finance_tracker/services/biometric_auth_service.dart';
import 'package:finance_tracker/services/screen_security_service.dart';

class FakeLocalAuthentication extends LocalAuthentication {
  bool supported = true;
  bool canCheck = true;
  bool authenticateResult = true;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [BiometricType.fingerprint];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => authenticateResult;
}

class FakeScreenSecurityService extends ScreenSecurityService {
  bool lastEnabled = true;
  int callCount = 0;

  @override
  Future<bool> setScreenSecurity(bool enabled) async {
    lastEnabled = enabled;
    callCount++;
    return true;
  }
}

void main() {
  late FakeLocalAuthentication fakeLocalAuth;
  late BiometricAuthService authService;
  late FlutterSecureStorage secureStorage;
  late FakeScreenSecurityService screenSecurityService;
  late AppLockProvider provider;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    fakeLocalAuth = FakeLocalAuthentication();
    authService = BiometricAuthService(auth: fakeLocalAuth);
    secureStorage = const FlutterSecureStorage();
    screenSecurityService = FakeScreenSecurityService();
    provider = AppLockProvider(
      authService: authService,
      secureStorage: secureStorage,
      screenSecurityService: screenSecurityService,
    );
  });

  group('AppLockProvider Unit Tests', () {
    test('initial state is uninitialized, unlocked, and disabled by default', () {
      expect(provider.isInitialized, isFalse);
      expect(provider.isBiometricEnabled, isFalse);
      expect(provider.isAppLocked, isFalse);
      expect(provider.lockTimeoutSeconds, 0);
    });

    test('initialize loads disabled state on fresh boot without locking', () async {
      await provider.initialize();
      expect(provider.isInitialized, isTrue);
      expect(provider.isBiometricEnabled, isFalse);
      expect(provider.isAppLocked, isFalse);
    });

    test('initialize loads enabled state from secure storage and locks on cold boot', () async {
      await secureStorage.write(key: AppLockProvider.keyBiometricEnabled, value: 'true');
      await secureStorage.write(key: AppLockProvider.keyLockTimeoutSeconds, value: '60');

      await provider.initialize();

      expect(provider.isInitialized, isTrue);
      expect(provider.isBiometricEnabled, isTrue);
      expect(provider.lockTimeoutSeconds, 60);
      expect(provider.isAppLocked, isTrue);
    });

    test('setBiometricEnabled requires passing challenge before enabling', () async {
      await provider.initialize();

      // Simulate challenge failure
      fakeLocalAuth.authenticateResult = false;
      final failResult = await provider.setBiometricEnabled(true, challengeReason: 'Verify identity');
      expect(failResult, isFalse);
      expect(provider.isBiometricEnabled, isFalse);

      // Simulate challenge success
      fakeLocalAuth.authenticateResult = true;
      final successResult = await provider.setBiometricEnabled(true, challengeReason: 'Verify identity');
      expect(successResult, isTrue);
      expect(provider.isBiometricEnabled, isTrue);

      final storedVal = await secureStorage.read(key: AppLockProvider.keyBiometricEnabled);
      expect(storedVal, 'true');
    });

    test('handleAppLifecycleState locks app when elapsed background time exceeds timeout', () async {
      fakeLocalAuth.authenticateResult = true;
      await provider.initialize();
      await provider.setBiometricEnabled(true, challengeReason: 'Verify');
      await provider.setLockTimeout(0); // immediate lock

      // Simulate app backgrounding
      provider.handleAppLifecycleState(AppLifecycleState.paused);

      fakeLocalAuth.authenticateResult = false; // auth fails on background resume so it stays locked
      // Wait a tick and resume
      provider.handleAppLifecycleState(AppLifecycleState.resumed);

      expect(provider.isAppLocked, isTrue);

      // Now authenticate successfully
      fakeLocalAuth.authenticateResult = true;
      final unlocked = await provider.authenticateAndUnlock();
      expect(unlocked, isTrue);
      expect(provider.isAppLocked, isFalse);
    });

    test('screen protection is enabled by default and synced on initialize', () async {
      expect(provider.isScreenProtectionEnabled, isTrue);
      await provider.initialize();
      expect(provider.isScreenProtectionEnabled, isTrue);
      expect(screenSecurityService.callCount, 1);
      expect(screenSecurityService.lastEnabled, isTrue);
    });

    test('setScreenProtectionEnabled toggles value, invokes service, and persists to storage', () async {
      await provider.initialize();
      expect(screenSecurityService.callCount, 1);

      await provider.setScreenProtectionEnabled(false);
      expect(provider.isScreenProtectionEnabled, isFalse);
      expect(screenSecurityService.callCount, 2);
      expect(screenSecurityService.lastEnabled, isFalse);

      final storedVal = await secureStorage.read(key: AppLockProvider.keyScreenProtectionEnabled);
      expect(storedVal, 'false');

      // Re-enable
      await provider.setScreenProtectionEnabled(true);
      expect(provider.isScreenProtectionEnabled, isTrue);
      expect(screenSecurityService.callCount, 3);
      expect(screenSecurityService.lastEnabled, isTrue);
    });

    test('initialize respects stored screen protection value', () async {
      await secureStorage.write(key: AppLockProvider.keyScreenProtectionEnabled, value: 'false');
      await provider.initialize();
      expect(provider.isScreenProtectionEnabled, isFalse);
      expect(screenSecurityService.lastEnabled, isFalse);
    });
  });
}
