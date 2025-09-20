import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../payments/presentation/widgets/payment_card.dart';
import '../../../payments/domain/entities/payment.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../../../core/theme/theme_cubit.dart';

class HistoryHomePage extends StatefulWidget {
  const HistoryHomePage({super.key});

  @override
  State<HistoryHomePage> createState() => _HistoryHomePageState();
}

class _HistoryHomePageState extends State<HistoryHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryBloc>().add(LoadSuccessPayments());
        context.read<HistoryBloc>().add(LoadFailedPayments());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
                icon: Icon(
                  state is ThemeLight ? Icons.dark_mode : Icons.light_mode,
                ),
                tooltip: state is ThemeLight ? 'Dark Mode' : 'Light Mode',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Success',
            ),
            Tab(
              icon: Icon(Icons.error),
              text: 'Failed',
            ),
          ],
        ),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryError) {
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
                    'Error loading payments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HistoryBloc>().add(RefreshPayments());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HistoryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentsList(
                  payments: state.successPayments,
                  emptyMessage: 'No successful payments found',
                  isLoadingMore: state.isLoadingMoreSuccess,
                  onLoadMore: () {
                    context.read<HistoryBloc>().add(LoadMoreSuccessPayments());
                  },
                ),
                _buildPaymentsList(
                  payments: state.failedPayments,
                  emptyMessage: 'No failed payments found',
                  isLoadingMore: state.isLoadingMoreFailed,
                  onLoadMore: () {
                    context.read<HistoryBloc>().add(LoadMoreFailedPayments());
                  },
                ),
              ],
            );
          }

          return const Center(child: Text('Welcome to Transaction History'));
        },
      ),
    );
  }

  Widget _buildPaymentsList({
    required List<Payment> payments,
    required String emptyMessage,
    required bool isLoadingMore,
    required VoidCallback onLoadMore,
  }) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(RefreshPayments());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: payments.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == payments.length) {
            // Loading indicator for pagination
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final payment = payments[index];
          return PaymentCard(
            payment: payment,
            onTap: () {
              // TODO: Navigate to payment details
            },
          );
        },
      ),
    );
  }
}
