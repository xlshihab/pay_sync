import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:another_telephony/telephony.dart' as telephony;
import 'package:flutter/material.dart';
import '../../data/models/sms_message.dart' as models;

// Telephony instance
final telephonyProvider = Provider<telephony.Telephony>((ref) => telephony.Telephony.instance);

// SMS messages state
class SmsState {
  final List<models.SmsThread> threads;
  final List<models.SmsMessage> messages;
  final bool isLoading;
  final String? error;
  final bool hasPermissions;

  SmsState({
    this.threads = const [],
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.hasPermissions = false,
  });

  SmsState copyWith({
    List<models.SmsThread>? threads,
    List<models.SmsMessage>? messages,
    bool? isLoading,
    String? error,
    bool? hasPermissions,
  }) {
    return SmsState(
      threads: threads ?? this.threads,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPermissions: hasPermissions ?? this.hasPermissions,
    );
  }
}

// SMS Provider
class SmsNotifier extends StateNotifier<SmsState> {
  final telephony.Telephony _telephony;

  SmsNotifier(this._telephony) : super(SmsState()) {
    _initializeSms();
  }

  Future<void> _initializeSms() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check permissions
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        state = state.copyWith(
          isLoading: false,
          hasPermissions: false,
          error: 'SMS permissions required',
        );
        return;
      }

      // Load SMS threads
      await loadSmsThreads();

      // Listen for incoming SMS without background processing for now
      _telephony.listenIncomingSms(
        onNewMessage: (telephony.SmsMessage message) {
          _handleNewSms(message);
        },
        listenInBackground: false, // Set to false to avoid background handler requirement
      );

      state = state.copyWith(
        isLoading: false,
        hasPermissions: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize SMS: $e',
      );
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      final permissions = await _telephony.requestPhoneAndSmsPermissions;
      return permissions ?? false;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  Future<void> requestDefaultSmsApp() async {
    try {
      final isDefault = await _telephony.isSmsCapable;
      if (isDefault != null && !isDefault) {
        debugPrint('App is not SMS capable or not default SMS app');
      }
    } catch (e) {
      debugPrint('Default SMS app error: $e');
    }
  }

  Future<void> loadSmsThreads() async {
    try {
      state = state.copyWith(isLoading: true);

      final conversations = await _telephony.getConversations();
      final threads = <models.SmsThread>[];

      for (final conv in conversations) {
        final messages = await _telephony.getInboxSms(
          filter: telephony.SmsFilter.where(telephony.SmsColumn.THREAD_ID).equals(conv.threadId.toString()),
          sortOrder: [telephony.OrderBy(telephony.SmsColumn.DATE, sort: telephony.Sort.DESC)],
        );

        if (messages.isNotEmpty) {
          final lastMessage = _convertToSmsMessage(messages.first);
          final unreadCount = messages.where((m) => m.read == false).length;

          threads.add(models.SmsThread(
            threadId: conv.threadId ?? 0,
            address: conv.snippet ?? '',
            contactName: null,
            lastMessage: lastMessage,
            messageCount: conv.messageCount ?? 0,
            unreadCount: unreadCount,
          ));
        }
      }

      threads.sort((a, b) => b.lastMessage.date.compareTo(a.lastMessage.date));

      state = state.copyWith(
        threads: threads,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load SMS threads: $e',
      );
    }
  }

  Future<void> loadMessagesForThread(int threadId) async {
    try {
      final messages = await _telephony.getInboxSms(
        filter: telephony.SmsFilter.where(telephony.SmsColumn.THREAD_ID).equals(threadId.toString()),
        sortOrder: [telephony.OrderBy(telephony.SmsColumn.DATE, sort: telephony.Sort.ASC)],
      );

      final sentMessages = await _telephony.getSentSms(
        filter: telephony.SmsFilter.where(telephony.SmsColumn.THREAD_ID).equals(threadId.toString()),
        sortOrder: [telephony.OrderBy(telephony.SmsColumn.DATE, sort: telephony.Sort.ASC)],
      );

      final allMessages = [...messages, ...sentMessages];

      // Sort by date safely - handle both int and DateTime types
      allMessages.sort((a, b) {
        try {
          DateTime aDate, bDate;

          // Convert a.date
          if (a.date == null) {
            aDate = DateTime.fromMillisecondsSinceEpoch(0);
          } else if (a.date is int) {
            aDate = DateTime.fromMillisecondsSinceEpoch(a.date as int);
          } else if (a.date is DateTime) {
            aDate = a.date as DateTime;
          } else {
            aDate = DateTime.now();
          }

          // Convert b.date
          if (b.date == null) {
            bDate = DateTime.fromMillisecondsSinceEpoch(0);
          } else if (b.date is int) {
            bDate = DateTime.fromMillisecondsSinceEpoch(b.date as int);
          } else if (b.date is DateTime) {
            bDate = b.date as DateTime;
          } else {
            bDate = DateTime.now();
          }

          return aDate.compareTo(bDate);
        } catch (e) {
          return 0; // If any error, consider them equal
        }
      });

      final convertedMessages = allMessages.map(_convertToSmsMessage).toList();

      state = state.copyWith(messages: convertedMessages);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load messages: $e');
    }
  }

  Future<void> sendSms(String address, String message) async {
    try {
      await _telephony.sendSms(
        to: address,
        message: message,
      );

      await loadSmsThreads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to send SMS: $e');
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      await loadSmsThreads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark as read: $e');
    }
  }

  Future<void> deleteSms(int messageId) async {
    try {
      await loadSmsThreads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete SMS: $e');
    }
  }

  void _handleNewSms(telephony.SmsMessage sms) {
    loadSmsThreads();
  }

  models.SmsMessage _convertToSmsMessage(telephony.SmsMessage sms) {
    // Handle date conversion properly - it comes as int milliseconds
    DateTime messageDate;
    try {
      if (sms.date != null) {
        if (sms.date is int) {
          messageDate = DateTime.fromMillisecondsSinceEpoch(sms.date as int);
        } else if (sms.date is DateTime) {
          messageDate = sms.date as DateTime;
        } else {
          messageDate = DateTime.now();
        }
      } else {
        messageDate = DateTime.now();
      }
    } catch (e) {
      messageDate = DateTime.now();
    }

    return models.SmsMessage(
      id: sms.id ?? 0,
      address: sms.address ?? '',
      body: sms.body ?? '',
      date: messageDate,
      isRead: sms.read ?? false,
      isSent: sms.type == 2, // 2 = SENT, 1 = RECEIVED
      threadId: sms.threadId ?? 0,
    );
  }
}

final smsProvider = StateNotifierProvider<SmsNotifier, SmsState>((ref) {
  final telephony = ref.watch(telephonyProvider);
  return SmsNotifier(telephony);
});
