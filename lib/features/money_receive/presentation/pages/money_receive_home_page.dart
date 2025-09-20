import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../bloc/money_receive_bloc.dart';
import '../widgets/payment_card.dart';
class MoneyReceiveHomePage extends StatefulWidget {
  const MoneyReceiveHomePage({super.key});

  @override
  State<MoneyReceiveHomePage> createState() => _MoneyReceiveHomePageState();
}

class _MoneyReceiveHomePageState extends State<MoneyReceiveHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MoneyReceiveBloc>().add(LoadUnmatchedPayments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithThemeToggle(title: 'Money Receive'),
      body: BlocBuilder<MoneyReceiveBloc, MoneyReceiveState>(
        builder: (context, state) {
          if (state is MoneyReceiveLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoneyReceiveError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MoneyReceiveBloc>().add(LoadUnmatchedPayments()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MoneyReceiveLoaded || state is PaymentDeleting) {
            final payments = state is MoneyReceiveLoaded
                ? state.payments
                : (state as PaymentDeleting).payments;
            final deletingId = state is PaymentDeleting ? state.deletingId : null;

            if (payments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No unmatched payments found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MoneyReceiveBloc>().add(LoadUnmatchedPayments());
              },
              child: ListView.builder(
                itemCount: payments.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  final isDeleting = deletingId == payment.id;

                  return PaymentCard(
                    payment: payment,
                    isDeleting: isDeleting,
                    onDelete: () {
                      context.read<MoneyReceiveBloc>().add(DeletePayment(payment.id));
                    },
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Welcome to Money Receive'),
          );
        },
      ),
    );
  }
}
