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
      print('Error checking SMS permissions: $e');
      return false;
    }
  }

  // Request SMS permissions
  static Future<bool> requestSmsPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestSmsPermissions');
      return result as bool? ?? false;
    } catch (e) {
      print('Error requesting SMS permissions: $e');
      return false;
    }
  }

  // Check if app is default SMS app
  static Future<bool> isDefaultSmsApp() async {
    try {
      final result = await _channel.invokeMethod('isDefaultSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking default SMS app: $e');
      return false;
    }
  }

  // Request to be default SMS app
  static Future<bool> requestDefaultSmsApp() async {
    try {
      final result = await _channel.invokeMethod('requestDefaultSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      print('Error requesting default SMS app: $e');
      return false;
    }
  }

  // Diagnose SMS app issues
  static Future<bool> diagnoseSmsApp() async {
    try {
      final result = await _channel.invokeMethod('diagnoseSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      print('Error diagnosing SMS app: $e');
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
