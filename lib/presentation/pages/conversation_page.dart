import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/sms_message.dart';
import '../providers/sms_provider.dart';

class ConversationPage extends ConsumerStatefulWidget {
  final SmsThread thread;

  const ConversationPage({super.key, required this.thread});

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsProvider.notifier).loadMessagesForThread(widget.thread.threadId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smsState = ref.watch(smsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.thread.contactName ?? _formatPhoneNumber(widget.thread.address),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (widget.thread.contactName != null)
              Text(
                _formatPhoneNumber(widget.thread.address),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Call functionality
            },
            icon: const Icon(Icons.call),
            tooltip: 'Call',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  // Show contact info
                  break;
                case 'delete':
                  // Delete conversation
                  break;
                case 'block':
                  // Block contact
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Contact info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Delete conversation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block),
                    SizedBox(width: 8),
                    Text('Block contact'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(smsState.messages),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<SmsMessage> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages in this conversation',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastMessage = index == messages.length - 1;
        final nextMessage = isLastMessage ? null : messages[index + 1];
        final showDateHeader = _shouldShowDateHeader(message, nextMessage);

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.date),
            _buildMessageBubble(message),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        _formatDateHeader(date),
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageBubble(SmsMessage message) {
    final theme = Theme.of(context);
    final isOutgoing = message.isSent;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOutgoing ? 48 : 0,
          right: isOutgoing ? 0 : 48,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isOutgoing
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.body,
              style: TextStyle(
                fontSize: 16,
                color: isOutgoing
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(message.date),
              style: TextStyle(
                fontSize: 11,
                color: isOutgoing
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(smsProvider.notifier).sendSms(widget.thread.address, message);
      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool _shouldShowDateHeader(SmsMessage current, SmsMessage? next) {
    if (next == null) return true;

    final currentDate = DateTime(current.date.year, current.date.month, current.date.day);
    final nextDate = DateTime(next.date.year, next.date.month, next.date.day);

    return !currentDate.isAtSameMomentAs(nextDate);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('MMMM d').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length == 11 && cleanNumber.startsWith('1')) {
      return '+1 (${cleanNumber.substring(1, 4)}) ${cleanNumber.substring(4, 7)}-${cleanNumber.substring(7)}';
    } else if (cleanNumber.length == 10) {
      return '(${cleanNumber.substring(0, 3)}) ${cleanNumber.substring(3, 6)}-${cleanNumber.substring(6)}';
    } else if (cleanNumber.length == 11 && cleanNumber.startsWith('88')) {
      return '+88 ${cleanNumber.substring(2, 7)}-${cleanNumber.substring(7)}';
    }

    return phoneNumber;
  }
}
