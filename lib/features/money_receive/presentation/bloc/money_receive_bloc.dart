import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../domain/entities/unmatched_payment.dart';
import '../../domain/usecases/get_unmatched_payments_use_case.dart';
import '../../domain/usecases/delete_unmatched_payment_use_case.dart';

// Events
abstract class MoneyReceiveEvent extends Equatable {
  const MoneyReceiveEvent();

  @override
  List<Object> get props => [];
}

class LoadUnmatchedPayments extends MoneyReceiveEvent {}

class DeletePayment extends MoneyReceiveEvent {
  final String id;

  const DeletePayment(this.id);

  @override
  List<Object> get props => [id];
}

class PaymentsUpdated extends MoneyReceiveEvent {
  final List<UnmatchedPayment> payments;

  const PaymentsUpdated(this.payments);

  @override
  List<Object> get props => [payments];
}

// States
abstract class MoneyReceiveState extends Equatable {
  const MoneyReceiveState();

  @override
  List<Object> get props => [];
}

class MoneyReceiveInitial extends MoneyReceiveState {}

class MoneyReceiveLoading extends MoneyReceiveState {}

class MoneyReceiveLoaded extends MoneyReceiveState {
  final List<UnmatchedPayment> payments;

  const MoneyReceiveLoaded(this.payments);

  @override
  List<Object> get props => [payments];
}

class MoneyReceiveError extends MoneyReceiveState {
  final String message;

  const MoneyReceiveError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentDeleting extends MoneyReceiveState {
  final List<UnmatchedPayment> payments;
  final String deletingId;

  const PaymentDeleting(this.payments, this.deletingId);

  @override
  List<Object> get props => [payments, deletingId];
}

// Bloc
class MoneyReceiveBloc extends Bloc<MoneyReceiveEvent, MoneyReceiveState> {
  final GetUnmatchedPaymentsUseCase getUnmatchedPaymentsUseCase;
  final DeleteUnmatchedPaymentUseCase deleteUnmatchedPaymentUseCase;

  StreamSubscription<List<UnmatchedPayment>>? _paymentsSubscription;

  MoneyReceiveBloc({
    required this.getUnmatchedPaymentsUseCase,
    required this.deleteUnmatchedPaymentUseCase,
  }) : super(MoneyReceiveInitial()) {
    on<LoadUnmatchedPayments>(_onLoadUnmatchedPayments);
    on<DeletePayment>(_onDeletePayment);
    on<PaymentsUpdated>(_onPaymentsUpdated);
  }

  void _onLoadUnmatchedPayments(
    LoadUnmatchedPayments event,
    Emitter<MoneyReceiveState> emit,
  ) async {
    emit(MoneyReceiveLoading());

    try {
      await _paymentsSubscription?.cancel();
      _paymentsSubscription = getUnmatchedPaymentsUseCase().listen(
        (payments) => add(PaymentsUpdated(payments)),
        onError: (error) => emit(MoneyReceiveError(error.toString())),
      );
    } catch (e) {
      emit(MoneyReceiveError(e.toString()));
    }
  }

  void _onPaymentsUpdated(
    PaymentsUpdated event,
    Emitter<MoneyReceiveState> emit,
  ) {
    emit(MoneyReceiveLoaded(event.payments));
  }

  void _onDeletePayment(
    DeletePayment event,
    Emitter<MoneyReceiveState> emit,
  ) async {
    if (state is MoneyReceiveLoaded) {
      final currentPayments = (state as MoneyReceiveLoaded).payments;
      emit(PaymentDeleting(currentPayments, event.id));

      try {
        await deleteUnmatchedPaymentUseCase(event.id);
        // The stream will automatically update the UI
      } catch (e) {
        emit(MoneyReceiveError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _paymentsSubscription?.cancel();
    return super.close();
  }
}
