import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sms_inbox/sms_inbox_bloc.dart';
import '../bloc/sms_inbox/sms_inbox_state.dart';
import '../bloc/sms_inbox/sms_inbox_event.dart';
import '../../domain/entities/sms_message.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<SmsInboxBloc, SmsInboxState>(
        builder: (context, state) {
          if (state is SmsInboxLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SmsInboxError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SmsInboxBloc>().add(LoadAllMessagesEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SmsInboxLoaded) {
            if (state.messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No messages found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Messages will appear here when received',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SmsInboxBloc>().add(LoadAllMessagesEvent());
              },
              child: ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return _buildMessageTile(context, message);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SmsInboxBloc>().add(LoadAllMessagesEvent()),
        tooltip: 'Refresh Messages',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMessageTile(BuildContext context, SmsMessage message) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yy');
    final now = DateTime.now();
    final isToday = DateFormat('yyyy-MM-dd').format(message.timestamp) ==
                   DateFormat('yyyy-MM-dd').format(now);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: message.isPaymentMessage
              ? Colors.green[100]
              : Colors.grey[200],
          child: Icon(
            message.isPaymentMessage
                ? Icons.payment
                : Icons.message,
            color: message.isPaymentMessage
                ? Colors.green[700]
                : Colors.grey[600],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.sender,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (message.isPaymentMessage && message.paymentInfo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tk ${message.paymentInfo!.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            if (message.isPaymentMessage && message.paymentInfo != null)
              _buildPaymentInfo(message.paymentInfo!),
          ],
        ),
        trailing: Text(
          isToday
              ? timeFormat.format(message.timestamp)
              : dateFormat.format(message.timestamp),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        onTap: () => _showMessageDetails(context, message),
      ),
    );
  }

  Widget _buildPaymentInfo(PaymentInfo paymentInfo) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (paymentInfo.senderPhone != null)
            Text(
              'From: ${paymentInfo.senderPhone}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          if (paymentInfo.transactionId != null)
            Text(
              'TxnID: ${paymentInfo.transactionId}',
              style: const TextStyle(fontSize: 12),
            ),
          if (paymentInfo.balance != null)
            Text(
              'Balance: Tk ${paymentInfo.balance!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  void _showMessageDetails(BuildContext context, SmsMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              message.isPaymentMessage ? Icons.payment : Icons.message,
              color: message.isPaymentMessage ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.sender,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time: ${DateFormat('dd/MM/yyyy HH:mm').format(message.timestamp)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message.body),
            ),
            if (message.isPaymentMessage && message.paymentInfo != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Payment Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailedPaymentInfo(message.paymentInfo!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPaymentInfo(PaymentInfo paymentInfo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Amount', 'Tk ${paymentInfo.amount.toStringAsFixed(2)}'),
          if (paymentInfo.senderPhone != null)
            _buildInfoRow('From', paymentInfo.senderPhone!),
          if (paymentInfo.transactionId != null)
            _buildInfoRow('Transaction ID', paymentInfo.transactionId!),
          if (paymentInfo.reference != null)
            _buildInfoRow('Reference', paymentInfo.reference!),
          if (paymentInfo.fee != null)
            _buildInfoRow('Fee', 'Tk ${paymentInfo.fee!.toStringAsFixed(2)}'),
          if (paymentInfo.balance != null)
            _buildInfoRow('Balance', 'Tk ${paymentInfo.balance!.toStringAsFixed(2)}'),
          _buildInfoRow('Type', paymentInfo.type.name.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Messages'),
              onTap: () {
                Navigator.pop(context);
                context.read<SmsInboxBloc>().add(LoadAllMessagesEvent());
              },
            ),
            ListTile(
              title: const Text('Payment Messages Only'),
              onTap: () {
                Navigator.pop(context);
                context.read<SmsInboxBloc>().add(LoadPaymentMessagesEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
