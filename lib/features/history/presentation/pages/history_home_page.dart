import 'package:flutter/material.dart';
import '../../../../core/widgets/main_navigation.dart';

class HistoryHomePage extends StatelessWidget {
  const HistoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWithThemeToggle(title: 'History'),
      body: Center(
        child: Text(
          'Transaction History Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
