import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static const _appId = String.fromEnvironment('ONESIGNAL_APP_ID');
  static Future<void>? _initialization;

  static Future<void> initializeForUser(String userId) async {
    if (_appId.isEmpty || userId.isEmpty) return;
    try {
      await (_initialization ??= OneSignal.initialize(_appId));
      await OneSignal.login(userId);
    } catch (error) {
      _initialization = null;
      debugPrint('OneSignal initialization failed: $error');
    }
  }

  static Future<bool> requestPermission() async {
    if (_appId.isEmpty) return false;
    try {
      await (_initialization ??= OneSignal.initialize(_appId));
      return await OneSignal.Notifications.requestPermission(false);
    } catch (error) {
      _initialization = null;
      debugPrint('OneSignal permission request failed: $error');
      return false;
    }
  }

  static Future<void> logout() async {
    if (_appId.isEmpty || _initialization == null) return;
    try {
      await _initialization;
      await OneSignal.logout();
    } catch (error) {
      debugPrint('OneSignal logout failed: $error');
    }
  }
}
