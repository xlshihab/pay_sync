import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              tooltip: themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'সফল'),
              Tab(text: 'ব্যর্থ'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SuccessTab(),
            FailedTab(),
          ],
        ),
      ),
    );
  }
}

class SuccessTab extends ConsumerWidget {
  const SuccessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final successPaymentsAsync = ref.watch(successPaymentsStreamProvider);

    return successPaymentsAsync.when(
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'কোন সফল পেমেন্ট নেই',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  return PaymentCard(
                    payment: payments[index],
                    showActions: false, // No actions for history items
                  );
                },
              ),
            ),
            if (payments.length >= 10) // Show "Show More" button if we have 10 or more items
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement pagination - load more items
                  },
                  child: const Text('আরো দেখুন'),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'ত্রুটি: $error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(successPaymentsStreamProvider),
              child: const Text('পুনরায় চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

class FailedTab extends ConsumerWidget {
  const FailedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failedPaymentsAsync = ref.watch(failedPaymentsStreamProvider);

    return failedPaymentsAsync.when(
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'কোন ব্যর্থ পেমেন্ট নেই',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  return PaymentCard(
                    payment: payments[index],
                    showActions: false, // No actions for history items
                  );
                },
              ),
            ),
            if (payments.length >= 10) // Show "Show More" button if we have 10 or more items
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement pagination - load more items
                  },
                  child: const Text('আরো দেখুন'),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'ত্রুটি: $error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(failedPaymentsStreamProvider),
              child: const Text('পুনরায় চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
