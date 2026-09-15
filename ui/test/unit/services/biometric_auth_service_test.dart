import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:finance_tracker/services/biometric_auth_service.dart';

class FakeLocalAuthentication extends LocalAuthentication {
  bool supported = true;
  bool canCheck = true;
  bool authenticateResult = true;
  List<BiometricType> biometrics = [BiometricType.fingerprint, BiometricType.strong];

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => biometrics;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => authenticateResult;

  @override
  Future<bool> stopAuthentication() async => true;
}

void main() {
  late FakeLocalAuthentication fakeAuth;
  late BiometricAuthService service;

  setUp(() {
    fakeAuth = FakeLocalAuthentication();
    service = BiometricAuthService(auth: fakeAuth);
  });

  group('BiometricAuthService', () {
    test('isDeviceSupported returns underlying auth value', () async {
      expect(await service.isDeviceSupported(), isTrue);
      fakeAuth.supported = false;
      expect(await service.isDeviceSupported(), isFalse);
    });

    test('canCheckBiometrics returns underlying auth value', () async {
      expect(await service.canCheckBiometrics(), isTrue);
      fakeAuth.canCheck = false;
      expect(await service.canCheckBiometrics(), isFalse);
    });

    test('getAvailableBiometrics returns configured biometrics', () async {
      final list = await service.getAvailableBiometrics();
      expect(list, contains(BiometricType.fingerprint));
      expect(list, contains(BiometricType.strong));
    });

    test('authenticate succeeds when device is supported and auth passes', () async {
      final success = await service.authenticate(localizedReason: 'Test Unlock');
      expect(success, isTrue);
    });

    test('authenticate returns false when device is not supported', () async {
      fakeAuth.supported = false;
      final success = await service.authenticate(localizedReason: 'Test Unlock');
      expect(success, isFalse);
    });
  });
}
