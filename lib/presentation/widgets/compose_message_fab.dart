import 'package:flutter/material.dart';

class ComposeMessageFab extends StatelessWidget {
  const ComposeMessageFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to compose message screen
        Navigator.pushNamed(context, '/compose');
      },
      tooltip: 'Compose message',
      child: const Icon(Icons.edit),
    );
  }
}
