import 'package:equatable/equatable.dart';
import '../../../payments/domain/entities/payment.dart';

abstract class PendingEvent extends Equatable {
  const PendingEvent();

  @override
  List<Object> get props => [];
}

class LoadPendingPayments extends PendingEvent {}

class UpdatePaymentStatus extends PendingEvent {
  final String paymentId;
  final PaymentStatus newStatus;

  const UpdatePaymentStatus(this.paymentId, this.newStatus);

  @override
  List<Object> get props => [paymentId, newStatus];
}

class RefreshPendingPayments extends PendingEvent {}
