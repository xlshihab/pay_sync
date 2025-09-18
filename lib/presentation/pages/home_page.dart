import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sms_provider.dart';
import 'pending_page.dart';
import 'money_receive_page.dart';
import 'history_page.dart';
import 'inbox_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 3; // Start with Inbox tab since we're an SMS app
  bool _smsInitialized = false;

  final List<Widget> _pages = [
    const PendingPage(),
    const MoneyReceivePage(),
    const HistoryPage(),
    const InboxPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize SMS functionality after permissions are granted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSmsIfNeeded();
    });
  }

  Future<void> _initializeSmsIfNeeded() async {
    if (!_smsInitialized) {
      await ref.read(smsProvider.notifier).initializeSms();
      setState(() {
        _smsInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Money Receive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}
