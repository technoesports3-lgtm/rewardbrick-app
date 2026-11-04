import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class NotificationService {
  static const _configuredAppId = String.fromEnvironment('ONESIGNAL_APP_ID');
  static Future<String?>? _appIdLookup;
  static Future<void>? _initialization;

  static Future<String?> _resolveAppId() {
    if (_configuredAppId.isNotEmpty) {
      return Future.value(_configuredAppId);
    }
    return _appIdLookup ??= () async {
      try {
        final response = await Dio().get(
          '${ApiService.baseUrl}/dashboard/notification-config',
          options: Options(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );
        final data = response.data;
        final appId = data is Map ? data['app_id'] : null;
        return appId is String && appId.isNotEmpty ? appId : null;
      } catch (error) {
        debugPrint('OneSignal app configuration could not be loaded: $error');
        _appIdLookup = null;
        return null;
      }
    }();
  }

  static Future<bool> _ensureInitialized() async {
    try {
      if (_initialization != null) {
        await _initialization;
        return true;
      }
      final appId = await _resolveAppId();
      if (appId == null) return false;
      _initialization = OneSignal.initialize(appId);
      await _initialization;
      return true;
    } catch (error) {
      _initialization = null;
      debugPrint('OneSignal initialization failed: $error');
      return false;
    }
  }

  static Future<void> initializeForUser(String userId) async {
    if (userId.isEmpty || !await _ensureInitialized()) return;
    try {
      await OneSignal.login(userId);
    } catch (error) {
      debugPrint('OneSignal user registration failed: $error');
    }
  }

  static Future<bool> requestPermission() async {
    if (!await _ensureInitialized()) return false;
    try {
      return await OneSignal.Notifications.requestPermission(false);
    } catch (error) {
      debugPrint('OneSignal permission request failed: $error');
      return false;
    }
  }

  static Future<void> registerAndRequestPermission(String userId) async {
    if (userId.isEmpty) return;
    await initializeForUser(userId);
    if (_initialization == null) return;

    final preferences = await SharedPreferences.getInstance();
    const promptedKey = 'onesignal_permission_prompted';
    if (preferences.getBool(promptedKey) ?? false) return;

    await preferences.setBool(promptedKey, true);
    await requestPermission();
  }

  static Future<void> logout() async {
    if (_initialization == null) return;
    try {
      await _initialization;
      await OneSignal.logout();
    } catch (error) {
      debugPrint('OneSignal logout failed: $error');
    }
  }
}
