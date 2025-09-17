import 'dart:async';
import 'dart:developer';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../entities/sms_message.dart' as app;
import '../usecases/sms_message_usecases.dart';
import '../../core/services/sms_parser_service.dart';

class SmsInboxService {
  static SmsInboxService? _instance;
  static SmsInboxService get instance => _instance ??= SmsInboxService._();
  SmsInboxService._();

  final Telephony _telephony = Telephony.instance;
  final SmsParserService _parser = SmsParserService.instance;

  late SaveSmsMessage _saveSmsMessage;
  StreamSubscription<SmsMessage>? _smsSubscription;
  bool _isMonitoring = false;

  // Initialize with use cases
  void initialize({required SaveSmsMessage saveSmsMessage}) {
    _saveSmsMessage = saveSmsMessage;
  }

  /// Start monitoring SMS messages for inbox
  Future<bool> startInboxMonitoring() async {
    try {
      if (_isMonitoring) {
        log('SMS inbox monitoring is already running');
        return true;
      }

      // Check SMS permission
      final smsPermission = await Permission.sms.status;
      if (!smsPermission.isGranted) {
        log('SMS permission not granted');
        return false;
      }

      // Listen for incoming SMS
      _telephony.listenIncomingSms(
        onNewMessage: _handleNewSms,
        onBackgroundMessage: _handleBackgroundSms,
        listenInBackground: true,
      );

      _isMonitoring = true;
      log('SMS inbox monitoring started successfully');

      // Load existing SMS messages from phone
      await _loadExistingSmsMessages();

      return true;
    } catch (e) {
      log('Failed to start SMS inbox monitoring: $e');
      return false;
    }
  }

  /// Stop monitoring SMS messages
  Future<void> stopInboxMonitoring() async {
    try {
      await _smsSubscription?.cancel();
      _smsSubscription = null;
      _isMonitoring = false;
      log('SMS inbox monitoring stopped');
    } catch (e) {
      log('Error stopping SMS inbox monitoring: $e');
    }
  }

  /// Handle new SMS message
  void _handleNewSms(SmsMessage smsMessage) {
    _processSmsMessage(smsMessage);
  }

  /// Handle background SMS message
  static void _handleBackgroundSms(SmsMessage smsMessage) {
    // This will be handled by background service
    log('Background SMS received for inbox: ${smsMessage.body}');
  }

  /// Process and save SMS message to inbox
  Future<void> _processSmsMessage(SmsMessage telephonySms) async {
    try {
      // Parse the SMS message
      final timestamp = telephonySms.date != null
          ? DateTime.fromMillisecondsSinceEpoch(telephonySms.date!)
          : DateTime.now();

      final parsedMessage = _parser.parseMessage(
        id: '${telephonySms.address}_${timestamp.millisecondsSinceEpoch}',
        sender: telephonySms.address ?? 'Unknown',
        body: telephonySms.body ?? '',
        timestamp: timestamp,
      );

      // Save to local database
      final result = await _saveSmsMessage(parsedMessage);
      result.fold(
        (failure) => log('Failed to save SMS to inbox: ${failure.message}'),
        (_) {
          log('SMS saved to inbox successfully');
          if (parsedMessage.isPaymentMessage) {
            log('Payment SMS detected: Amount ${parsedMessage.paymentInfo?.amount}');
          }
        },
      );
    } catch (e) {
      log('Error processing SMS for inbox: $e');
    }
  }

  /// Load existing SMS messages from phone
  Future<void> _loadExistingSmsMessages() async {
    try {
      log('Loading existing SMS messages from phone for inbox...');

      // Get all SMS messages from phone
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      log('Found ${messages.length} SMS messages on phone');

      int processedCount = 0;
      int paymentCount = 0;

      // Process each SMS message (limit to recent 100 to avoid overload)
      final recentMessages = messages.take(100);

      for (final sms in recentMessages) {
        try {
          final timestamp = sms.date != null
              ? DateTime.fromMillisecondsSinceEpoch(sms.date!)
              : DateTime.now();

          final parsedMessage = _parser.parseMessage(
            id: '${sms.address}_${timestamp.millisecondsSinceEpoch}',
            sender: sms.address ?? 'Unknown',
            body: sms.body ?? '',
            timestamp: timestamp,
          );

          // Save to local database
          final result = await _saveSmsMessage(parsedMessage);
          result.fold(
            (failure) => log('Failed to save existing SMS: ${failure.message}'),
            (_) {
              processedCount++;
              if (parsedMessage.isPaymentMessage) {
                paymentCount++;
              }
            },
          );
        } catch (e) {
          log('Error processing existing SMS: $e');
        }
      }

      log('Processed $processedCount SMS messages for inbox, found $paymentCount payment messages');
    } catch (e) {
      log('Error loading existing SMS messages: $e');
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Get monitoring status
  Map<String, dynamic> getStatus() {
    return {
      'isMonitoring': _isMonitoring,
      'hasSubscription': _smsSubscription != null,
    };
  }
}
