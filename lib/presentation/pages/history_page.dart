import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/history/history_bloc.dart';
import '../../domain/entities/payment.dart';
import '../../core/constants/app_constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load success payments by default
    context.read<HistoryBloc>().add(LoadSuccessPaymentsEvent());
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
        title: const Text('History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              context.read<HistoryBloc>().add(LoadSuccessPaymentsEvent());
            } else {
              context.read<HistoryBloc>().add(LoadFailedPaymentsEvent());
            }
          },
          tabs: const [
            Tab(text: 'Success'),
            Tab(text: 'Failed'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(AppConstants.statusSuccess),
          _buildHistoryTab(AppConstants.statusFailed),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(String status) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (status == AppConstants.statusSuccess) {
                      context.read<HistoryBloc>().add(LoadSuccessPaymentsEvent());
                    } else {
                      context.read<HistoryBloc>().add(LoadFailedPaymentsEvent());
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<Payment> payments = [];
        bool hasMore = false;
        bool isLoadingMore = false;

        if (state is HistorySuccessLoaded && status == AppConstants.statusSuccess) {
          payments = state.payments;
          hasMore = state.hasMore;
          isLoadingMore = state.isLoadingMore;
        } else if (state is HistoryFailedLoaded && status == AppConstants.statusFailed) {
          payments = state.payments;
          hasMore = state.hasMore;
          isLoadingMore = state.isLoadingMore;
        }

        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == AppConstants.statusSuccess ? Icons.check_circle : Icons.cancel,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  status == AppConstants.statusSuccess
                    ? 'কোনো successful payment নেই'
                    : 'কোনো failed payment নেই',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length + (hasMore ? 1 : 0), // +1 for load more button if hasMore is true
          itemBuilder: (context, index) {
            if (index == payments.length) {
              // Load more button
              return Container(
                margin: const EdgeInsets.only(top: 16),
                child: Center(
                  child: isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          if (status == AppConstants.statusSuccess) {
                            context.read<HistoryBloc>().add(LoadMoreSuccessPaymentsEvent());
                          } else {
                            context.read<HistoryBloc>().add(LoadMoreFailedPaymentsEvent());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('আরো দেখুন'),
                      ),
                ),
              );
            }

            final payment = payments[index];
            return HistoryPaymentCard(
              payment: payment,
              onDelete: () {
                _showDeleteConfirmDialog(context, payment);
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Payment'),
          content: Text(
            'আপনি কি এই payment (৳${payment.amount.toStringAsFixed(2)}) delete করতে চান?\n\nএটি Firebase থেকেও permanently delete হয়ে যাবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<HistoryBloc>().add(DeletePaymentEvent(payment.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class HistoryPaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onDelete;

  const HistoryPaymentCard({
    super.key,
    required this.payment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = payment.status == AppConstants.statusSuccess;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '৳${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSuccess ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          payment.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Transaction ID: ${payment.trxId}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('Method: ${payment.method.toUpperCase()}'),
              Text('Package: ${payment.packageType}'),
              Text('Quantity: ${payment.quantity}'),
              Text('User ID: ${payment.userId}'),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Long press করে delete করুন',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
