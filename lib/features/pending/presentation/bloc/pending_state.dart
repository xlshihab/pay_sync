import 'package:equatable/equatable.dart';
import '../../../payments/domain/entities/payment.dart';

abstract class PendingState extends Equatable {
  const PendingState();

  @override
  List<Object> get props => [];
}

class PendingInitial extends PendingState {}

class PendingLoading extends PendingState {}

class PendingLoaded extends PendingState {
  final List<Payment> pendingPayments;
  final bool isUpdating;

  const PendingLoaded({
    required this.pendingPayments,
    this.isUpdating = false,
  });

  PendingLoaded copyWith({
    List<Payment>? pendingPayments,
    bool? isUpdating,
  }) {
    return PendingLoaded(
      pendingPayments: pendingPayments ?? this.pendingPayments,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object> get props => [pendingPayments, isUpdating];
}

class PendingError extends PendingState {
  final String message;

  const PendingError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentStatusUpdated extends PendingState {
  final String message;

  const PaymentStatusUpdated(this.message);

  @override
  List<Object> get props => [message];
}
