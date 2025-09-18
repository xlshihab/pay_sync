import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../providers/sms_provider.dart';
import '../widgets/sms_thread_tile.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final smsState = ref.watch(smsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: smsState.isSelectionMode
          ? _buildSelectionAppBar(smsState)
          : (_isSearching ? _buildSearchAppBar() : _buildNormalAppBar(themeMode)),
      body: _buildBody(context, smsState),
      // Removed floatingActionButton - no compose functionality
    );
  }

  PreferredSizeWidget _buildNormalAppBar(ThemeMode themeMode) {
    return AppBar(
      title: const Text(
        'Messages',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search messages',
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              // Removed 'default_app' option since we're read-only now
              case 'refresh':
                ref.read(smsProvider.notifier).loadSmsThreads();
                break;
              case 'theme':
                ref.read(themeModeProvider.notifier).toggleTheme();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh_rounded),
                title: Text('Refresh'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'theme',
              child: ListTile(
                leading: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                title: Text(themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            ref.read(smsProvider.notifier).clearSearch();
          });
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search messages...',
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 18),
        ),
        style: const TextStyle(fontSize: 18),
        onChanged: (value) {
          ref.read(smsProvider.notifier).updateSearchQuery(value);
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _searchController.clear();
              ref.read(smsProvider.notifier).clearSearch();
            },
            icon: const Icon(Icons.clear_rounded),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SmsState smsState) {
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
              'Grant SMS permissions to view messages',
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
              'Messages will appear here when you receive them',
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

    // Use filteredThreads from SMS provider instead of manual filtering
    final filteredThreads = smsState.filteredThreads;

    if (filteredThreads.isEmpty && smsState.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
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
        itemCount: filteredThreads.length,
        itemBuilder: (context, index) {
          final thread = filteredThreads[index];
          final isSelected = smsState.selectedThreadIds.contains(thread.threadId);

          return SmsThreadTile(
            thread: thread,
            isSelected: isSelected,
            isSelectionMode: smsState.isSelectionMode,
            onTap: () {
              if (smsState.isSelectionMode) {
                // Toggle selection in selection mode
                ref.read(smsProvider.notifier).toggleSelection(thread.threadId);
              } else {
                // Navigate to conversation
                Navigator.pushNamed(
                  context,
                  '/conversation',
                  arguments: thread,
                );
              }
            },
            onLongPress: () {
              // Start selection mode
              if (!smsState.isSelectionMode) {
                ref.read(smsProvider.notifier).startSelectionMode(thread.threadId);
              }
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(SmsState smsState) {
    return AppBar(
      title: Text('${smsState.selectedThreadIds.length} selected'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      leading: IconButton(
        onPressed: () {
          ref.read(smsProvider.notifier).exitSelectionMode();
        },
        icon: const Icon(Icons.close),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(smsProvider.notifier).selectAllThreads();
          },
          icon: const Icon(Icons.select_all),
          tooltip: 'Select all',
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'mark_read':
                // Mark selected threads as read
                for (final threadId in smsState.selectedThreadIds) {
                  await ref.read(smsProvider.notifier).markThreadAsRead(threadId);
                }
                ref.read(smsProvider.notifier).exitSelectionMode();
                break;
              case 'delete':
                _showDeleteSelectedConfirmation(smsState.selectedThreadIds.length);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_read',
              child: ListTile(
                leading: Icon(Icons.mark_email_read),
                title: Text('Mark as read'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  void _showDeleteSelectedConfirmation(int count) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete selected messages'),
          content: Text('Are you sure you want to delete $count selected conversation(s)?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(smsProvider.notifier).deleteSelectedThreads();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
