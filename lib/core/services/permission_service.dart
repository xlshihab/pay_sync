import 'package:flutter/services.dart';
import 'dart:async';

enum PermissionStatus {
  smsPermissionDenied,
  notDefaultApp,
  allGranted,
  smsGrantedButNotDefault, // New status for SMS permissions granted but not default app
}

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.example.pay_sync/sms');

  // Create a stream controller for SMS default app changes
  static final _defaultSmsAppStatusController = StreamController<bool>.broadcast();
  static Stream<bool> get defaultSmsAppStatus => _defaultSmsAppStatusController.stream;

  static void initialize() {
    // Listen for method calls from native side
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'defaultSmsAppResult') {
        final isDefault = call.arguments as bool? ?? false;
        _defaultSmsAppStatusController.add(isDefault);
        return null;
      }
      return null;
    });
  }

  // Check if all SMS permissions are granted
  static Future<bool> checkSmsPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkSmsPermissions');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // Request SMS permissions
  static Future<bool> requestSmsPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestSmsPermissions');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // Check if app is default SMS app
  static Future<bool> isDefaultSmsApp() async {
    try {
      final result = await _channel.invokeMethod('isDefaultSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // Request to be default SMS app
  static Future<bool> requestDefaultSmsApp() async {
    try {
      final result = await _channel.invokeMethod('requestDefaultSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // Check all permissions and default app status
  static Future<PermissionStatus> checkAllPermissions() async {
    final smsPermissions = await checkSmsPermissions();

    if (!smsPermissions) {
      return PermissionStatus.smsPermissionDenied;
    }

    final isDefault = await isDefaultSmsApp();

    if (!isDefault) {
      // Still allow app to continue without being default SMS app
      return PermissionStatus.smsGrantedButNotDefault;
    }

    return PermissionStatus.allGranted;
  }

  // Dispose resources
  static void dispose() {
    _defaultSmsAppStatusController.close();
  }
}
