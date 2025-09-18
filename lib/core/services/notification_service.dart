import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('sms_notifications');

  static Future<void> showSmsNotification({
    required String sender,
    required String message,
    required int id,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'id': id,
        'title': sender,
        'body': message,
        'channelId': 'sms_channel',
        'channelName': 'SMS Messages',
        'importance': 'high',
      });
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  static Future<void> createNotificationChannel() async {
    try {
      await _channel.invokeMethod('createChannel', {
        'channelId': 'sms_channel',
        'channelName': 'SMS Messages',
        'channelDescription': 'Notifications for incoming SMS messages',
        'importance': 'high',
      });
    } catch (e) {
      debugPrint('Failed to create notification channel: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': id});
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }
}
