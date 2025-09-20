import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../../../payments/presentation/widgets/payment_card.dart';
import '../../../payments/domain/entities/payment.dart';
import '../bloc/pending_bloc.dart';
import '../bloc/pending_event.dart';
import '../bloc/pending_state.dart';

class PendingHomePage extends StatefulWidget {
  const PendingHomePage({super.key});

  @override
  State<PendingHomePage> createState() => _PendingHomePageState();
}

class _PendingHomePageState extends State<PendingHomePage> {
  @override
  void initState() {
    super.initState();
    // Load pending payments after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PendingBloc>().add(LoadPendingPayments());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithThemeToggle(
        title: 'Pending Payments',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PendingBloc>().add(RefreshPendingPayments());
            },
          ),
        ],
      ),
      body: BlocListener<PendingBloc, PendingState>(
        listener: (context, state) {
          if (state is PaymentStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is PendingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<PendingBloc, PendingState>(
          builder: (context, state) {
            if (state is PendingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PendingError) {
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
                      'Error loading pending payments',
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
                        context.read<PendingBloc>().add(RefreshPendingPayments());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PendingLoaded) {
              if (state.pendingPayments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending payments',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All payments have been processed',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      context.read<PendingBloc>().add(RefreshPendingPayments());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.pendingPayments.length,
                      itemBuilder: (context, index) {
                        final payment = state.pendingPayments[index];
                        return PaymentCard(
                          payment: payment,
                          onTap: () {
                            // TODO: Navigate to payment details
                          },
                          onLongPress: () {
                            _showStatusUpdateDialog(context, payment);
                          },
                        );
                      },
                    ),
                  ),
                  if (state.isUpdating)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            }

            return const Center(child: Text('Welcome to Pending Payments'));
          },
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, Payment payment) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Payment Status',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Transaction ID: ${payment.trxId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Amount: ৳${payment.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<PendingBloc>().add(
                              UpdatePaymentStatus(payment.id, PaymentStatus.success),
                            );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Success'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<PendingBloc>().add(
                              UpdatePaymentStatus(payment.id, PaymentStatus.failed),
                            );
                      },
                      icon: const Icon(Icons.error),
                      label: const Text('Mark as Failed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}
