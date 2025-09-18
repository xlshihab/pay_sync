import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:another_telephony/telephony.dart' as tel;
import 'package:flutter/material.dart';
import '../../core/services/sms_deletion_service.dart';
import '../../data/models/sms_message.dart';

// Telephony instance
final telephonyProvider = Provider<tel.Telephony>((ref) => tel.Telephony.instance);

// SMS messages state
class SmsState {
  final List<SmsThread> threads;
  final List<SmsMessage> messages;
  final bool isLoading;
  final String? error;
  final bool hasPermissions;
  final Set<int> selectedThreadIds;
  final bool isSelectionMode;
  final String searchQuery;

  SmsState({
    this.threads = const [],
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.hasPermissions = false,
    this.selectedThreadIds = const {},
    this.isSelectionMode = false,
    this.searchQuery = '',
  });

  SmsState copyWith({
    List<SmsThread>? threads,
    List<SmsMessage>? messages,
    bool? isLoading,
    String? error,
    bool? hasPermissions,
    Set<int>? selectedThreadIds,
    bool? isSelectionMode,
    String? searchQuery,
  }) {
    return SmsState(
      threads: threads ?? this.threads,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      selectedThreadIds: selectedThreadIds ?? this.selectedThreadIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Filtered threads based on search query
  List<SmsThread> get filteredThreads {
    if (searchQuery.isEmpty) return threads;

    return threads.where((thread) {
      final query = searchQuery.toLowerCase();
      return thread.address.toLowerCase().contains(query) ||
             (thread.contactName?.toLowerCase().contains(query) ?? false) ||
             thread.lastMessage.body.toLowerCase().contains(query);
    }).toList();
  }
}

// SMS Provider - Simplified without permission checking since PermissionGatePage handles it
class SmsNotifier extends StateNotifier<SmsState> {
  final tel.Telephony _telephony;

  SmsNotifier(this._telephony) : super(SmsState()) {
    // Don't auto-initialize - wait for explicit call from HomePage
  }

  // Initialize SMS functionality (called from HomePage after permissions are granted)
  Future<void> initializeSms() async {
    state = state.copyWith(isLoading: true);
    debugPrint('🔄 Initializing SMS functionality...');

    try {
      // Load SMS threads
      await loadSmsThreads();

      // Listen for incoming SMS
      _telephony.listenIncomingSms(
        onNewMessage: (tel.SmsMessage message) {
          _handleNewSms(message);
        },
        listenInBackground: false,
      );

      state = state.copyWith(
        isLoading: false,
        hasPermissions: true,
        error: null,
      );
      debugPrint('✅ SMS initialization completed successfully!');

    } catch (e, stackTrace) {
      debugPrint('💥 Error initializing SMS: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize SMS: $e',
      );
    }
  }

  Future<void> loadSmsThreads() async {
    try {
      state = state.copyWith(isLoading: true);
      debugPrint('📥 Loading SMS threads...');

      final conversations = await _telephony.getConversations();
      debugPrint('💬 Found ${conversations.length} conversations');

      final threads = <SmsThread>[];

      // Performance improvement: Get all messages at once
      final allInboxMessages = await _telephony.getInboxSms(
        sortOrder: [tel.OrderBy(tel.SmsColumn.DATE, sort: tel.Sort.DESC)],
      );
      debugPrint('📥 Found ${allInboxMessages.length} inbox messages');

      final allSentMessages = await _telephony.getSentSms(
        sortOrder: [tel.OrderBy(tel.SmsColumn.DATE, sort: tel.Sort.DESC)],
      );
      debugPrint('📤 Found ${allSentMessages.length} sent messages');

      // Group messages by thread ID
      final messagesByThread = <int, List<tel.SmsMessage>>{};

      for (final message in [...allInboxMessages, ...allSentMessages]) {
        final threadId = message.threadId ?? 0;
        if (threadId > 0) {
          if (!messagesByThread.containsKey(threadId)) {
            messagesByThread[threadId] = [];
          }
          messagesByThread[threadId]!.add(message);
        }
      }

      debugPrint('📊 Grouped messages into ${messagesByThread.length} threads');

      for (final conv in conversations) {
        final threadId = conv.threadId ?? 0;
        final threadMessages = messagesByThread[threadId] ?? [];

        if (threadMessages.isNotEmpty) {
          // Sort messages by date to get the latest one
          threadMessages.sort((a, b) {
            final aDate = a.date ?? 0;
            final bDate = b.date ?? 0;
            return bDate.compareTo(aDate);
          });

          final lastMessage = _convertToSmsMessage(threadMessages.first);
          final unreadCount = threadMessages.where((m) => m.read == false).length;

          // Get proper address from the last message instead of conversation snippet
          final address = lastMessage.address.isNotEmpty ? lastMessage.address : (conv.snippet ?? '');

          threads.add(SmsThread(
            threadId: threadId,
            address: address,
            contactName: null,
            lastMessage: lastMessage,
            messageCount: conv.messageCount ?? threadMessages.length,
            unreadCount: unreadCount,
          ));

          debugPrint('✅ Created thread: $address (${threadMessages.length} messages)');
        }
      }

      threads.sort((a, b) => b.lastMessage.date.compareTo(a.lastMessage.date));
      debugPrint('🎯 Final result: ${threads.length} threads created');

      state = state.copyWith(
        threads: threads,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      debugPrint('💥 Error loading SMS threads: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load SMS threads: $e',
      );
    }
  }

  Future<void> loadMessagesForThread(int threadId) async {
    try {
      final messages = await _telephony.getInboxSms(
        filter: tel.SmsFilter.where(tel.SmsColumn.THREAD_ID).equals(threadId.toString()),
        sortOrder: [tel.OrderBy(tel.SmsColumn.DATE, sort: tel.Sort.ASC)],
      );

      final sentMessages = await _telephony.getSentSms(
        filter: tel.SmsFilter.where(tel.SmsColumn.THREAD_ID).equals(threadId.toString()),
        sortOrder: [tel.OrderBy(tel.SmsColumn.DATE, sort: tel.Sort.ASC)],
      );

      final allMessages = [...messages, ...sentMessages];

      allMessages.sort((a, b) {
        try {
          DateTime aDate, bDate;

          if (a.date == null) {
            aDate = DateTime.fromMillisecondsSinceEpoch(0);
          } else if (a.date is int) {
            aDate = DateTime.fromMillisecondsSinceEpoch(a.date as int);
          } else if (a.date is DateTime) {
            aDate = a.date as DateTime;
          } else {
            aDate = DateTime.now();
          }

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
          return 0;
        }
      });

      final convertedMessages = allMessages.map(_convertToSmsMessage).toList();

      state = state.copyWith(messages: convertedMessages);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load messages: $e');
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // Mark as read/unread functionality
  Future<void> markAsRead(int messageId) async {
    try {
      debugPrint('Marking message $messageId as read');
      await loadSmsThreads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark as read: $e');
    }
  }

  Future<void> markAsUnread(int messageId) async {
    try {
      debugPrint('Marking message $messageId as unread');
      await loadSmsThreads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark as unread: $e');
    }
  }

  Future<void> markThreadAsRead(int threadId) async {
    try {
      final threadMessages = state.messages.where((msg) => msg.threadId == threadId);
      for (final message in threadMessages) {
        await markAsRead(message.id);
      }
      await loadSmsThreads();
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark thread as read: $e');
    }
  }

  // Delete functionality
  Future<void> deleteSms(int messageId) async {
    try {
      final deleted = await SmsDeletionService.deleteSms(messageId);
      if (deleted) {
        await loadSmsThreads();
      } else {
        state = state.copyWith(error: 'Failed to delete message');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete SMS: $e');
    }
  }

  Future<void> deleteConversation(int threadId) async {
    try {
      final deleted = await SmsDeletionService.deleteConversation(threadId);
      if (deleted) {
        await loadSmsThreads();
      } else {
        state = state.copyWith(error: 'Failed to delete conversation');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete conversation: $e');
    }
  }

  void _handleNewSms(tel.SmsMessage sms) {
    _showSmsNotification(sms);
    loadSmsThreads();
  }

  void _showSmsNotification(tel.SmsMessage sms) {
    try {
      final sender = sms.address ?? 'Unknown';
      final body = sms.body ?? '';
      debugPrint('New SMS from $sender: $body');
    } catch (e) {
      debugPrint('Failed to show SMS notification: $e');
    }
  }

  SmsMessage _convertToSmsMessage(tel.SmsMessage sms) {
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

    bool isSent = false;
    if (sms.type != null) {
      if (sms.type.toString().contains('2') || sms.type.toString().contains('SENT')) {
        isSent = true;
      }
    }

    return SmsMessage(
      id: sms.id ?? 0,
      address: sms.address ?? '',
      body: sms.body ?? '',
      date: messageDate,
      isRead: sms.read ?? false,
      isSent: isSent,
      threadId: sms.threadId ?? 0,
    );
  }

  // Selection mode methods
  void startSelectionMode(int threadId) {
    state = state.copyWith(
      isSelectionMode: true,
      selectedThreadIds: {threadId},
    );
  }

  void exitSelectionMode() {
    state = state.copyWith(
      isSelectionMode: false,
      selectedThreadIds: <int>{},
    );
  }

  void toggleSelection(int threadId) {
    final selectedIds = Set<int>.from(state.selectedThreadIds);
    if (selectedIds.contains(threadId)) {
      selectedIds.remove(threadId);
    } else {
      selectedIds.add(threadId);
    }

    state = state.copyWith(
      selectedThreadIds: selectedIds,
      isSelectionMode: selectedIds.isNotEmpty,
    );
  }

  void selectAllThreads() {
    final allThreadIds = state.filteredThreads.map((thread) => thread.threadId).toSet();
    state = state.copyWith(
      selectedThreadIds: allThreadIds,
      isSelectionMode: true,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedThreadIds: <int>{},
      isSelectionMode: false,
    );
  }

  Future<void> deleteSelectedThreads() async {
    try {
      state = state.copyWith(isLoading: true);

      for (final threadId in state.selectedThreadIds) {
        await deleteConversation(threadId);
      }

      await loadSmsThreads();

      state = state.copyWith(
        isSelectionMode: false,
        selectedThreadIds: <int>{},
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete conversations: $e',
        isLoading: false,
      );
    }
  }
}

final smsProvider = StateNotifierProvider<SmsNotifier, SmsState>((ref) {
  final telephony = ref.watch(telephonyProvider);
  return SmsNotifier(telephony);
});
