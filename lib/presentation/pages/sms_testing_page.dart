import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection/injection_container.dart' as di;
import '../../domain/usecases/sms_usecases.dart';
import '../../data/datasources/sms_local_datasource.dart';
import '../bloc/pending/pending_bloc.dart';

class SmsTestingPage extends StatefulWidget {
  const SmsTestingPage({super.key});

  @override
  State<SmsTestingPage> createState() => _SmsTestingPageState();
}

class _SmsTestingPageState extends State<SmsTestingPage> {
  final _messageController = TextEditingController();
  final _senderController = TextEditingController();
  final _parseSmsMessage = di.sl<ParseSmsMessage>();
  final _smsDataSource = di.sl<SmsLocalDataSource>();

  // Sample SMS messages for testing
  final List<Map<String, String>> sampleMessages = [
    {
      'sender': 'bKash',
      'message': 'You have received Tk 735.00 from 01954880349.Ref wifi. Fee Tk 0.00. Balance Tk 762.57. TrxID CHI8MADSNW at 18/08/2025 23:47'
    },
    {
      'sender': 'NAGAD',
      'message': 'Money Received.\nAmount: Tk 500.00\nSender: 01737067174\nRef: N/A\nTxnID: 747FUXJZ\nBalance: Tk 500.78\n30/07/2025 11:54'
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  void _loadSampleMessage(Map<String, String> sample) {
    _senderController.text = sample['sender']!;
    _messageController.text = sample['message']!;
  }

  void _testSmsMessage() async {
    final message = _messageController.text.trim();
    final sender = _senderController.text.trim();

    if (message.isEmpty || sender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both message and sender')),
      );
      return;
    }

    final result = await _parseSmsMessage(message, sender);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parsing failed: ${failure.message}')),
        );
      },
      (payment) {
        if (payment != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment detected: Tk ${payment.amount} from ${payment.senderNumber} (${payment.method})',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No payment detected in this SMS'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  void _simulateIncomingSms() {
    final message = _messageController.text.trim();
    final sender = _senderController.text.trim();

    if (message.isEmpty || sender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both message and sender')),
      );
      return;
    }

    // Simulate incoming SMS by directly calling the test method
    if (_smsDataSource is SmsLocalDataSourceImpl) {
      (_smsDataSource as SmsLocalDataSourceImpl).addTestSms(message, sender);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test SMS simulated! Check the pending payments.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Real-time SMS Integration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Using another_telephony package for real-time SMS listening',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Sample messages
            const Text('Sample Messages:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...sampleMessages.map((sample) => Card(
              child: ListTile(
                title: Text(sample['sender']!),
                subtitle: Text(
                  sample['message']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => _loadSampleMessage(sample),
              ),
            )),

            const SizedBox(height: 24),

            // Manual input
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender',
                border: OutlineInputBorder(),
                hintText: 'e.g., bKash, NAGAD',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'SMS Message',
                border: OutlineInputBorder(),
                hintText: 'Enter the complete SMS message here...',
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testSmsMessage,
                    child: const Text('Test Parsing'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _simulateIncomingSms,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Simulate SMS'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SMS Monitoring Status
            BlocBuilder<PendingBloc, PendingState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Real-time SMS Monitoring Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (state is PendingLoaded)
                          Text(
                            state.smsMonitoringActive ? 'Active ✅ (Real-time listening)' : 'Inactive ❌',
                            style: TextStyle(
                              color: state.smsMonitoringActive ? Colors.green : Colors.red,
                            ),
                          )
                        else
                          const Text('Status: Unknown'),
                        const SizedBox(height: 8),
                        const Text(
                          'When active, the app will automatically detect Bkash/Nagad payment SMS in real-time.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<PendingBloc>().add(StartSmsMonitoringEvent());
                              },
                              child: const Text('Start Monitoring'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PendingBloc>().add(StopSmsMonitoringEvent());
                              },
                              child: const Text('Stop Monitoring'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
