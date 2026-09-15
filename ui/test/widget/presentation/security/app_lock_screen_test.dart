import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';
import 'package:finance_tracker/presentation/screens/security/app_lock_screen.dart';
import 'package:finance_tracker/providers/app_lock_provider.dart';
import 'package:finance_tracker/services/biometric_auth_service.dart';

class FakeLocalAuthentication extends LocalAuthentication {
  bool authenticateResult = false;

  @override
  Future<bool> isDeviceSupported() async => true;
  @override
  Future<bool> get canCheckBiometrics async => true;
  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [BiometricType.fingerprint];
  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => authenticateResult;
}

void main() {
  late FakeLocalAuthentication fakeAuth;
  late AppLockProvider provider;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    fakeAuth = FakeLocalAuthentication();
    provider = AppLockProvider(
      authService: BiometricAuthService(auth: fakeAuth),
      secureStorage: const FlutterSecureStorage(),
    );
  });

  Widget buildTestableWidget() {
    return ChangeNotifierProvider<AppLockProvider>.value(
      value: provider,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppLockScreen(),
      ),
    );
  }

  group('AppLockScreen Widget Tests', () {
    testWidgets('renders lock icon, title, subtitle and unlock button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Finance Tracker Locked'), findsOneWidget);
      expect(find.text('Authenticate to access your financial records'), findsOneWidget);
      expect(find.text('Unlock App'), findsOneWidget);
    });

    testWidgets('tapping unlock button triggers authenticateAndUnlock', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      fakeAuth.authenticateResult = true;
      await tester.tap(find.text('Unlock App'));
      await tester.pumpAndSettle();

      expect(provider.isAppLocked, isFalse);
    });
  });
}
