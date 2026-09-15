import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform bridge service to toggle window screen security (e.g., FLAG_SECURE on Android).
class ScreenSecurityService {
  static const String defaultChannelName = 'com.example.financetracker/security';

  final MethodChannel _channel;

  ScreenSecurityService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(defaultChannelName);

  /// Dynamically enables or disables native screen security.
  /// When enabled, screenshots, screen recordings, and video call shares are obscured.
  Future<bool> setScreenSecurity(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setScreenSecurity', {'enabled': enabled});
      return result ?? true;
    } on PlatformException catch (e) {
      debugPrint('ScreenSecurityService PlatformException: $e');
      return false;
    } on MissingPluginException catch (e) {
      debugPrint('ScreenSecurityService MissingPluginException: $e');
      return false;
    } catch (e) {
      debugPrint('ScreenSecurityService unexpected error: $e');
      return false;
    }
  }
}
