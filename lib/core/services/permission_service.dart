import 'package:flutter/services.dart';

enum PermissionStatus {
  smsPermissionDenied,
  notDefaultApp,
  allGranted,
}

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.example.pay_sync/sms');

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
      return PermissionStatus.notDefaultApp;
    }

    return PermissionStatus.allGranted;
  }
}
