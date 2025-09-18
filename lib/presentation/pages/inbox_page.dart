import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../providers/sms_provider.dart';
import '../widgets/sms_thread_tile.dart';
import '../widgets/compose_message_fab.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final smsState = ref.watch(smsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(smsProvider.notifier).loadSmsThreads();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () {
              // Open search
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'default_app':
                  ref.read(smsProvider.notifier).requestDefaultSmsApp();
                  break;
                case 'settings':
                  // Open settings
                  break;
                case 'theme':
                  ref.read(themeModeProvider.notifier).toggleTheme();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'default_app',
                child: Row(
                  children: [
                    Icon(Icons.sms),
                    SizedBox(width: 8),
                    Text('Set as default SMS app'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    const SizedBox(width: 8),
                    Text(themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, ref, smsState),
      floatingActionButton: const ComposeMessageFab(),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, SmsState smsState) {
    if (smsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (smsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              smsState.error!,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(smsProvider.notifier).loadSmsThreads();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!smsState.hasPermissions) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sms_failed,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'SMS permissions required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant SMS permissions to view and send messages',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(smsProvider.notifier).loadSmsThreads();
              },
              child: const Text('Grant Permissions'),
            ),
          ],
        ),
      );
    }

    if (smsState.threads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation by tapping the compose button',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(smsProvider.notifier).loadSmsThreads(),
      child: ListView.builder(
        itemCount: smsState.threads.length,
        itemBuilder: (context, index) {
          final thread = smsState.threads[index];
          return SmsThreadTile(
            thread: thread,
            onTap: () {
              // Navigate to conversation
              Navigator.pushNamed(
                context,
                '/conversation',
                arguments: thread,
              );
            },
          );
        },
      ),
    );
  }
}
