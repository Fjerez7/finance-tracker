import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/services/screen_security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScreenSecurityService service;
  const channel = MethodChannel(ScreenSecurityService.defaultChannelName);
  final List<MethodCall> methodCalls = [];
  bool shouldThrow = false;

  setUp(() {
    methodCalls.clear();
    shouldThrow = false;
    service = ScreenSecurityService(channel: channel);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      if (shouldThrow) {
        throw PlatformException(code: 'ERROR', message: 'Platform error');
      }
      if (methodCall.method == 'setScreenSecurity') {
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ScreenSecurityService Unit Tests', () {
    test('setScreenSecurity(true) invokes channel with enabled: true', () async {
      final result = await service.setScreenSecurity(true);
      expect(result, isTrue);
      expect(methodCalls.length, 1);
      expect(methodCalls.first.method, 'setScreenSecurity');
      expect(methodCalls.first.arguments, {'enabled': true});
    });

    test('setScreenSecurity(false) invokes channel with enabled: false', () async {
      final result = await service.setScreenSecurity(false);
      expect(result, isTrue);
      expect(methodCalls.length, 1);
      expect(methodCalls.first.method, 'setScreenSecurity');
      expect(methodCalls.first.arguments, {'enabled': false});
    });

    test('setScreenSecurity returns false when exception is caught', () async {
      shouldThrow = true;
      final result = await service.setScreenSecurity(true);
      expect(result, isFalse);
    });
  });
}
