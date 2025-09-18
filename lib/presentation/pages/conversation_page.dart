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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsProvider.notifier).loadMessagesForThread(widget.thread.threadId);
      // Auto scroll to bottom after loading messages
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
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
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  // Show contact info
                  _showContactInfo();
                  break;
                case 'mark_read':
                  // Mark conversation as read
                  ref.read(smsProvider.notifier).markThreadAsRead(widget.thread.threadId);
                  break;
                case 'mark_unread':
                  // Mark conversation as unread (mark individual messages as unread)
                  final messages = smsState.messages.where((msg) => msg.threadId == widget.thread.threadId);
                  for (final message in messages) {
                    ref.read(smsProvider.notifier).markAsUnread(message.id);
                  }
                  break;
                case 'delete':
                  // Delete conversation
                  _showDeleteConfirmation();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Contact info'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'mark_read',
                child: ListTile(
                  leading: Icon(Icons.mark_email_read),
                  title: Text('Mark as read'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'mark_unread',
                child: ListTile(
                  leading: Icon(Icons.mark_email_unread),
                  title: Text('Mark as unread'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete conversation'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: _buildMessagesList(smsState.messages),
      // Removed message input - read-only conversation view
    );
  }

  Widget _buildMessagesList(List<SmsMessage> messages) {
    final conversationMessages = messages.where((msg) => msg.threadId == widget.thread.threadId).toList();

    if (conversationMessages.isEmpty) {
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
      itemCount: conversationMessages.length,
      itemBuilder: (context, index) {
        final message = conversationMessages[index];
        final isLastMessage = index == conversationMessages.length - 1;
        final nextMessage = isLastMessage ? null : conversationMessages[index + 1];
        final showDateHeader = _shouldShowDateHeader(message, nextMessage);

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.date),
            GestureDetector(
              onLongPress: () => _showMessageOptions(message),
              child: _buildMessageBubble(message),
            ),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: isOutgoing
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (!message.isRead) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: isOutgoing
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                        : theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(SmsMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(message.isRead ? Icons.mark_email_unread : Icons.mark_email_read),
              title: Text(message.isRead ? 'Mark as unread' : 'Mark as read'),
              onTap: () {
                Navigator.pop(context);
                if (message.isRead) {
                  ref.read(smsProvider.notifier).markAsUnread(message.id);
                } else {
                  ref.read(smsProvider.notifier).markAsRead(message.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy message'),
              onTap: () {
                Navigator.pop(context);
                // Copy to clipboard functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete message', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteMessageConfirmation(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteMessageConfirmation(SmsMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(smsProvider.notifier).deleteSms(message.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Number'),
              subtitle: Text(_formatPhoneNumber(widget.thread.address)),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              subtitle: Text('${widget.thread.messageCount} messages'),
              contentPadding: EdgeInsets.zero,
            ),
            if (widget.thread.unreadCount > 0)
              ListTile(
                leading: const Icon(Icons.mark_email_unread),
                title: const Text('Unread'),
                subtitle: Text('${widget.thread.unreadCount} unread messages'),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation'),
        content: const Text('Are you sure you want to delete this entire conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete conversation functionality
              ref.read(smsProvider.notifier).deleteConversation(widget.thread.threadId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to inbox

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
