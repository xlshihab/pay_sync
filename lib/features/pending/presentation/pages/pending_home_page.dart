import 'package:flutter/material.dart';
import '../../../../core/widgets/main_navigation.dart';

class PendingHomePage extends StatelessWidget {
  const PendingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWithThemeToggle(title: 'Pending'),
      body: Center(
        child: Text(
          'Pending Transactions Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
