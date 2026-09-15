import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/services/notification_bridge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(NotificationBridgeService.defaultChannelName);
  late NotificationBridgeService service;
  final List<MethodCall> calls = [];
  bool isGrantedMock = true;
  List<Map<String, dynamic>> bufferedMock = [];

  setUp(() {
    calls.clear();
    isGrantedMock = true;
    bufferedMock = [
      {
        'packageName': 'com.nu.production',
        'notificationKey': 'com_nu_production_123',
        'title': 'Compra aprobada',
        'body': 'Compra de \$20.000 en Exito',
        'postTime': 1726359000000,
      }
    ];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      calls.add(methodCall);
      switch (methodCall.method) {
        case 'isNotificationAccessGranted':
          return isGrantedMock;
        case 'requestNotificationAccess':
          return true;
        case 'syncMonitoredPackages':
          return true;
        case 'getBufferedNotifications':
          return bufferedMock;
        default:
          return null;
      }
    });

    service = NotificationBridgeService(channel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NotificationBridgeService Unit Tests', () {
    test('isNotificationAccessGranted returns channel response', () async {
      expect(await service.isNotificationAccessGranted(), isTrue);
      isGrantedMock = false;
      expect(await service.isNotificationAccessGranted(), isFalse);
    });

    test('requestNotificationAccess invokes method on channel', () async {
      final success = await service.requestNotificationAccess();
      expect(success, isTrue);
      expect(calls.any((c) => c.method == 'requestNotificationAccess'), isTrue);
    });

    test('syncMonitoredPackages sends packages list', () async {
      final success = await service.syncMonitoredPackages(['com.nu.production', 'com.nequi.MobileApp']);
      expect(success, isTrue);
      final syncCall = calls.firstWhere((c) => c.method == 'syncMonitoredPackages');
      expect(syncCall.arguments, {'packages': ['com.nu.production', 'com.nequi.MobileApp']});
    });

    test('getBufferedNotifications returns mapped list', () async {
      final list = await service.getBufferedNotifications();
      expect(list.length, 1);
      expect(list.first['packageName'], 'com.nu.production');
      expect(list.first['title'], 'Compra aprobada');
    });
  });
}
