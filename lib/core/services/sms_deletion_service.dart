import 'package:flutter/services.dart';

class SmsDeletionService {
  static const MethodChannel _channel = MethodChannel('com.example.pay_sync/sms');

  // SMS Deletion methods
  static Future<bool> deleteSms(int messageId) async {
    try {
      final result = await _channel.invokeMethod('deleteSms', {
        'messageId': messageId,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error deleting SMS: $e');
      return false;
    }
  }

  static Future<bool> deleteConversation(int threadId) async {
    try {
      final result = await _channel.invokeMethod('deleteConversation', {
        'threadId': threadId,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }

  // Permission and Default SMS App methods (delegated to PermissionService)
  static Future<bool> isDefaultSmsApp() async {
    try {
      final result = await _channel.invokeMethod('isDefaultSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking default SMS app: $e');
      return false;
    }
  }

  static Future<bool> requestDefaultSmsApp() async {
    try {
      final result = await _channel.invokeMethod('requestDefaultSmsApp');
      return result as bool? ?? false;
    } catch (e) {
      print('Error requesting default SMS app: $e');
      return false;
    }
  }

  static Future<bool> checkSmsPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkSmsPermissions');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking SMS permissions: $e');
      return false;
    }
  }
}
