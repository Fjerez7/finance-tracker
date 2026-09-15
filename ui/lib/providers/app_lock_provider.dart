import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_auth_service.dart';
import '../services/screen_security_service.dart';

/// Reactive provider managing biometric security, screen protection, app lock status, and background timeout triggers.
class AppLockProvider extends ChangeNotifier {
  static const String keyBiometricEnabled = 'biometric_app_lock_enabled';
  static const String keyLockTimeoutSeconds = 'biometric_lock_timeout_seconds';
  static const String keyScreenProtectionEnabled = 'screen_protection_enabled';

  final BiometricAuthService _authService;
  final FlutterSecureStorage _secureStorage;
  final ScreenSecurityService _screenSecurityService;

  bool _isInitialized = false;
  bool _isBiometricEnabled = false;
  bool _isScreenProtectionEnabled = true;
  bool _isAppLocked = false;
  bool _isAuthenticating = false;
  int _lockTimeoutSeconds = 0; // 0 = immediately, 30 = 30s, 60 = 1m, 300 = 5m
  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  DateTime? _lastPausedTimestamp;

  AppLockProvider({
    BiometricAuthService? authService,
    FlutterSecureStorage? secureStorage,
    ScreenSecurityService? screenSecurityService,
  })  : _authService = authService ?? BiometricAuthService(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _screenSecurityService = screenSecurityService ?? ScreenSecurityService();

  bool get isInitialized => _isInitialized;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isScreenProtectionEnabled => _isScreenProtectionEnabled;
  bool get isAppLocked => _isAppLocked;
  bool get isAuthenticating => _isAuthenticating;
  int get lockTimeoutSeconds => _lockTimeoutSeconds;
  bool get isDeviceSupported => _isDeviceSupported;
  bool get canCheckBiometrics => _canCheckBiometrics;
  List<BiometricType> get availableBiometrics => List.unmodifiable(_availableBiometrics);

  /// Initializes hardware capabilities and restores saved biometric preferences.
  Future<void> initialize() async {
    try {
      _isDeviceSupported = await _authService.isDeviceSupported();
      _canCheckBiometrics = await _authService.canCheckBiometrics();
      _availableBiometrics = await _authService.getAvailableBiometrics();

      final String? enabledVal = await _secureStorage.read(key: keyBiometricEnabled);
      _isBiometricEnabled = enabledVal == 'true';

      final String? timeoutVal = await _secureStorage.read(key: keyLockTimeoutSeconds);
      if (timeoutVal != null) {
        _lockTimeoutSeconds = int.tryParse(timeoutVal) ?? 0;
      }

      final String? screenProtVal = await _secureStorage.read(key: keyScreenProtectionEnabled);
      _isScreenProtectionEnabled = screenProtVal == null || screenProtVal == 'true';
      await _screenSecurityService.setScreenSecurity(_isScreenProtectionEnabled);

      // If biometric lock is enabled, lock immediately on cold startup
      if (_isBiometricEnabled) {
        _isAppLocked = true;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AppLockProvider.initialize error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Prompts the biometric challenge and unlocks the app upon success.
  Future<bool> authenticateAndUnlock({String? localizedReason}) async {
    if (!_isBiometricEnabled) {
      _isAppLocked = false;
      notifyListeners();
      return true;
    }

    if (_isAuthenticating) return false;

    _isAuthenticating = true;
    _lastPausedTimestamp = null;
    notifyListeners();

    try {
      final success = await _authService.authenticate(
        localizedReason: localizedReason ?? 'Authenticate to unlock Finance Tracker',
      );

      if (success) {
        _isAppLocked = false;
      }
      return success;
    } catch (_) {
      return false;
    } finally {
      _isAuthenticating = false;
      _lastPausedTimestamp = null;
      notifyListeners();
    }
  }

  /// Toggles the biometric lock preference, requiring an immediate biometric verification challenge to enable.
  Future<bool> setBiometricEnabled(bool enable, {required String challengeReason}) async {
    if (enable == _isBiometricEnabled) return true;

    if (enable) {
      _isAuthenticating = true;
      _lastPausedTimestamp = null;
      try {
        final challengePassed = await _authService.authenticate(
          localizedReason: challengeReason,
        );
        if (!challengePassed) {
          return false;
        }
      } finally {
        _isAuthenticating = false;
        _lastPausedTimestamp = null;
      }
    }

    _isBiometricEnabled = enable;
    if (!enable) {
      _isAppLocked = false;
    }

    await _secureStorage.write(
      key: keyBiometricEnabled,
      value: enable.toString(),
    );

    notifyListeners();
    return true;
  }

  /// Updates the inactivity timeout threshold before locking.
  Future<void> setLockTimeout(int seconds) async {
    _lockTimeoutSeconds = seconds;
    await _secureStorage.write(
      key: keyLockTimeoutSeconds,
      value: seconds.toString(),
    );
    notifyListeners();
  }

  /// Toggles the screen protection (FLAG_SECURE) preference and updates native window flags immediately.
  Future<void> setScreenProtectionEnabled(bool enable) async {
    if (enable == _isScreenProtectionEnabled) return;

    _isScreenProtectionEnabled = enable;
    await _screenSecurityService.setScreenSecurity(enable);
    await _secureStorage.write(
      key: keyScreenProtectionEnabled,
      value: enable.toString(),
    );
    notifyListeners();
  }

  /// Handles OS app lifecycle transitions (pause, inactive, resumed).
  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Do not record pause timestamp if pause was caused by the OS Biometric modal itself
      if (!_isAuthenticating) {
        _lastPausedTimestamp = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      // If returning from an active biometric prompt, ignore this resume event
      if (_isAuthenticating) {
        _lastPausedTimestamp = null;
        return;
      }

      if (_isBiometricEnabled && !_isAppLocked && _lastPausedTimestamp != null) {
        final elapsedSeconds = DateTime.now().difference(_lastPausedTimestamp!).inSeconds;
        if (elapsedSeconds >= _lockTimeoutSeconds) {
          _isAppLocked = true;
          notifyListeners();
        }
      }
      _lastPausedTimestamp = null;
    }
  }
}
