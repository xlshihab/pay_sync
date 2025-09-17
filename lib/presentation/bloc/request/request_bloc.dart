import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/usecases/watch_payments_by_status.dart';
import '../../../domain/usecases/update_payment_status.dart';
import '../../../core/constants/app_constants.dart';

// Events
abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object> get props => [];
}

class LoadPendingPaymentsEvent extends RequestEvent {}

class UpdatePaymentStatusEvent extends RequestEvent {
  final String paymentId;
  final String status;

  const UpdatePaymentStatusEvent(this.paymentId, this.status);

  @override
  List<Object> get props => [paymentId, status];
}

// States
abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestLoaded extends RequestState {
  final List<Payment> payments;

  const RequestLoaded(this.payments);

  @override
  List<Object> get props => [payments];
}

class RequestError extends RequestState {
  final String message;

  const RequestError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentStatusUpdating extends RequestState {}

class PaymentStatusUpdated extends RequestState {}

// BLoC
class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final WatchPaymentsByStatus watchPayments;
  final UpdatePaymentStatus updateStatus;

  RequestBloc({
    required this.watchPayments,
    required this.updateStatus,
  }) : super(RequestInitial()) {
    on<LoadPendingPaymentsEvent>(_onLoadPendingPayments);
    on<UpdatePaymentStatusEvent>(_onUpdatePaymentStatus);
  }

  Future<void> _onLoadPendingPayments(
    LoadPendingPaymentsEvent event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());

    await emit.forEach(
      watchPayments(AppConstants.statusPending),
      onData: (result) {
        return result.fold(
          (failure) => RequestError(failure.message),
          (payments) => RequestLoaded(payments),
        );
      },
      onError: (error, stackTrace) => RequestError(error.toString()),
    );
  }

  Future<void> _onUpdatePaymentStatus(
    UpdatePaymentStatusEvent event,
    Emitter<RequestState> emit,
  ) async {
    emit(PaymentStatusUpdating());

    final result = await updateStatus(event.paymentId, event.status);
    result.fold(
      (failure) => emit(RequestError(failure.message)),
      (_) => emit(PaymentStatusUpdated()),
    );
  }
}
