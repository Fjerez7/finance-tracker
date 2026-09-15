import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform bridge service communicating with Android native notification listener and permission APIs.
class NotificationBridgeService {
  static const String defaultChannelName = 'com.example.financetracker/notifications';

  final MethodChannel _channel;
  void Function(Map<String, dynamic> notification)? _onNotificationReceived;

  NotificationBridgeService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(defaultChannelName) {
    try {
      _channel.setMethodCallHandler(_handleMethodCall);
    } catch (e) {
      debugPrint('NotificationBridgeService setMethodCallHandler: $e');
    }
  }

  /// Sets a callback for real-time notifications received while Flutter is in foreground.
  void setNotificationReceivedHandler(void Function(Map<String, dynamic> notification)? handler) {
    _onNotificationReceived = handler;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onNotificationReceived') {
      try {
        final Map<dynamic, dynamic>? rawMap = call.arguments as Map<dynamic, dynamic>?;
        if (rawMap != null) {
          final map = rawMap.map((k, v) => MapEntry(k.toString(), v));
          _onNotificationReceived?.call(map);
        }
      } catch (e) {
        debugPrint('NotificationBridgeService onNotificationReceived error: $e');
      }
    }
  }

  /// Checks if the Android operating system has granted Notification Access permission to the app.
  Future<bool> isNotificationAccessGranted() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('isNotificationAccessGranted');
      return granted ?? false;
    } on MissingPluginException {
      // In test or non-Android environments, gracefully return false
      return false;
    } catch (e) {
      debugPrint('NotificationBridgeService isNotificationAccessGranted error: $e');
      return false;
    }
  }

  /// Launches the native Android "Notification Access" settings screen.
  Future<bool> requestNotificationAccess() async {
    try {
      final bool? launched = await _channel.invokeMethod<bool>('requestNotificationAccess');
      return launched ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('NotificationBridgeService requestNotificationAccess error: $e');
      return false;
    }
  }

  /// Synchronizes the active list of monitored package names to native SharedPreferences for instant drops.
  Future<bool> syncMonitoredPackages(List<String> packages) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>(
        'syncMonitoredPackages',
        {'packages': packages},
      );
      return success ?? true;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('NotificationBridgeService syncMonitoredPackages error: $e');
      return false;
    }
  }

  /// Retrieves and clears notifications buffered in native storage during cold start or background.
  Future<List<Map<String, dynamic>>> getBufferedNotifications() async {
    try {
      final List<dynamic>? rawList = await _channel.invokeListMethod<dynamic>('getBufferedNotifications');
      if (rawList == null) return [];

      return rawList.map((item) {
        final Map<dynamic, dynamic> map = item as Map<dynamic, dynamic>;
        return map.map((k, v) => MapEntry(k.toString(), v));
      }).toList();
    } on MissingPluginException {
      return [];
    } catch (e) {
      debugPrint('NotificationBridgeService getBufferedNotifications error: $e');
      return [];
    }
  }
}
