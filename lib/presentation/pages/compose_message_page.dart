import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sms_provider.dart';

class ComposeMessagePage extends ConsumerStatefulWidget {
  const ComposeMessagePage({super.key});

  @override
  ConsumerState<ComposeMessagePage> createState() => _ComposeMessagePageState();
}

class _ComposeMessagePageState extends ConsumerState<ComposeMessagePage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _phoneFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _canSend() ? _sendMessage : null,
            child: Text(
              'Send',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _canSend()
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Recipient Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'To:',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    decoration: const InputDecoration(
                      hintText: 'Enter phone number',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      _messageFocus.requestFocus();
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Open contacts picker
                    _showContactPicker();
                  },
                  icon: const Icon(Icons.contacts),
                  tooltip: 'Choose from contacts',
                ),
              ],
            ),
          ),

          // Message Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocus,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Send Button (Bottom)
          Container(
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
              child: SizedBox(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: _canSend() ? _sendMessage : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Send message'),
                  backgroundColor: _canSend()
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSend() {
    return _phoneController.text.trim().isNotEmpty &&
           _messageController.text.trim().isNotEmpty;
  }

  void _sendMessage() {
    if (!_canSend()) return;

    final phoneNumber = _phoneController.text.trim();
    final message = _messageController.text.trim();

    ref.read(smsProvider.notifier).sendSms(phoneNumber, message);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Go back to inbox
    Navigator.pop(context);
  }

  void _showContactPicker() {
    // For now, show a simple dialog
    // In a real app, you'd integrate with the contacts plugin
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacts'),
        content: const Text('Contact picker will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
