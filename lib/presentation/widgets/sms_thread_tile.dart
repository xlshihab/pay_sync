import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/sms_message.dart';

class SmsThreadTile extends StatelessWidget {
  final SmsThread thread;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  const SmsThreadTile({
    super.key,
    required this.thread,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = thread.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            // Selection indicator or Contact Avatar
            if (isSelectionMode)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    _getContactInitial(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Contact Name/Number
                      Expanded(
                        child: Text(
                          thread.contactName ?? _formatPhoneNumber(thread.address),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Time
                      Text(
                        _formatTime(thread.lastMessage.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      // Message Preview
                      Expanded(
                        child: Text(
                          thread.lastMessage.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnread
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread Count Badge
                      if (isUnread && !isSelectionMode) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            thread.unreadCount.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getContactInitial() {
    if (thread.contactName != null && thread.contactName!.isNotEmpty) {
      return thread.contactName!.substring(0, 1).toUpperCase();
    }

    // Use first digit of phone number if no contact name
    final cleanNumber = thread.address.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.isNotEmpty) {
      return cleanNumber.substring(cleanNumber.length - 1);
    }

    return '?';
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Simple phone number formatting
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length == 11 && cleanNumber.startsWith('1')) {
      // US format: +1 (XXX) XXX-XXXX
      return '+1 (${cleanNumber.substring(1, 4)}) ${cleanNumber.substring(4, 7)}-${cleanNumber.substring(7)}';
    } else if (cleanNumber.length == 10) {
      // US format without country code: (XXX) XXX-XXXX
      return '(${cleanNumber.substring(0, 3)}) ${cleanNumber.substring(3, 6)}-${cleanNumber.substring(6)}';
    } else if (cleanNumber.length == 11 && cleanNumber.startsWith('88')) {
      // Bangladesh format: +88 01XXX-XXXXXX
      return '+88 ${cleanNumber.substring(2, 7)}-${cleanNumber.substring(7)}';
    }

    return phoneNumber; // Return original if no pattern matches
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      // This week - show day name
      return DateFormat('EEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      // This year - show month and day
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Other years - show month, day, year
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
