import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection/injection_container.dart' as di;
import '../bloc/request/request_bloc.dart';
import '../bloc/pending/pending_bloc.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/sms_inbox/sms_inbox_bloc.dart';
import '../bloc/sms_inbox/sms_inbox_event.dart';
import 'request_page.dart';
import 'pending_page.dart';
import 'history_page.dart';
import 'inbox_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BlocProvider(
      create: (context) => di.sl<RequestBloc>()..add(LoadPendingPaymentsEvent()),
      child: const RequestPage(),
    ),
    BlocProvider(
      create: (context) => di.sl<PendingBloc>()
        ..add(StartSmsMonitoringEvent())
        ..add(LoadUnmatchedPaymentsEvent()),
      child: const PendingPage(),
    ),
    BlocProvider(
      create: (context) => di.sl<HistoryBloc>(),
      child: const HistoryPage(),
    ),
    BlocProvider(
      create: (context) => di.sl<SmsInboxBloc>()
        ..add(LoadAllMessagesEvent())
        ..add(StartInboxMonitoringEvent()),
      child: const InboxPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
        ],
      ),
    );
  }
}
