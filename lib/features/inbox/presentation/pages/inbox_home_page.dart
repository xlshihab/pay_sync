import 'package:flutter/material.dart';
import '../../../../core/widgets/main_navigation.dart';

class InboxHomePage extends StatelessWidget {
  const InboxHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWithThemeToggle(title: 'Inbox'),
      body: Center(
        child: Text(
          'Inbox Home Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
