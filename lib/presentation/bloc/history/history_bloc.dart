import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/usecases/watch_payments_by_status.dart';
import '../../../domain/usecases/delete_payment.dart';
import '../../../core/constants/app_constants.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSuccessPaymentsEvent extends HistoryEvent {}

class LoadFailedPaymentsEvent extends HistoryEvent {}

class LoadMoreSuccessPaymentsEvent extends HistoryEvent {}

class LoadMoreFailedPaymentsEvent extends HistoryEvent {}

class DeletePaymentEvent extends HistoryEvent {
  final String paymentId;

  const DeletePaymentEvent(this.paymentId);

  @override
  List<Object> get props => [paymentId];
}

// States
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistorySuccessLoaded extends HistoryState {
  final List<Payment> payments;
  final bool hasMore;
  final bool isLoadingMore;

  const HistorySuccessLoaded(this.payments, {this.hasMore = true, this.isLoadingMore = false});

  @override
  List<Object> get props => [payments, hasMore, isLoadingMore];

  HistorySuccessLoaded copyWith({
    List<Payment>? payments,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HistorySuccessLoaded(
      payments ?? this.payments,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HistoryFailedLoaded extends HistoryState {
  final List<Payment> payments;
  final bool hasMore;
  final bool isLoadingMore;

  const HistoryFailedLoaded(this.payments, {this.hasMore = true, this.isLoadingMore = false});

  @override
  List<Object> get props => [payments, hasMore, isLoadingMore];

  HistoryFailedLoaded copyWith({
    List<Payment>? payments,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HistoryFailedLoaded(
      payments ?? this.payments,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentDeleting extends HistoryState {}

class PaymentDeleted extends HistoryState {}

// BLoC
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final WatchPaymentsByStatus watchPaymentsByStatus;
  final DeletePayment deletePayment;

  List<Payment> _successPayments = [];
  List<Payment> _failedPayments = [];
  bool _hasMoreSuccess = true;
  bool _hasMoreFailed = true;

  HistoryBloc({
    required this.watchPaymentsByStatus,
    required this.deletePayment,
  }) : super(HistoryInitial()) {
    on<LoadSuccessPaymentsEvent>(_onLoadSuccessPayments);
    on<LoadFailedPaymentsEvent>(_onLoadFailedPayments);
    on<LoadMoreSuccessPaymentsEvent>(_onLoadMoreSuccessPayments);
    on<LoadMoreFailedPaymentsEvent>(_onLoadMoreFailedPayments);
    on<DeletePaymentEvent>(_onDeletePayment);
  }

  Future<void> _onLoadSuccessPayments(
    LoadSuccessPaymentsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    _successPayments = [];
    _hasMoreSuccess = true;

    await emit.forEach(
      watchPaymentsByStatus(AppConstants.statusSuccess),
      onData: (result) {
        return result.fold(
          (failure) => HistoryError(failure.message),
          (payments) {
            _successPayments = payments.take(AppConstants.paginationLimit).toList();
            _hasMoreSuccess = payments.length > AppConstants.paginationLimit;
            return HistorySuccessLoaded(_successPayments, hasMore: _hasMoreSuccess);
          },
        );
      },
      onError: (error, stackTrace) => HistoryError(error.toString()),
    );
  }

  Future<void> _onLoadFailedPayments(
    LoadFailedPaymentsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    _failedPayments = [];
    _hasMoreFailed = true;

    await emit.forEach(
      watchPaymentsByStatus(AppConstants.statusFailed),
      onData: (result) {
        return result.fold(
          (failure) => HistoryError(failure.message),
          (payments) {
            _failedPayments = payments.take(AppConstants.paginationLimit).toList();
            _hasMoreFailed = payments.length > AppConstants.paginationLimit;
            return HistoryFailedLoaded(_failedPayments, hasMore: _hasMoreFailed);
          },
        );
      },
      onError: (error, stackTrace) => HistoryError(error.toString()),
    );
  }

  Future<void> _onLoadMoreSuccessPayments(
    LoadMoreSuccessPaymentsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistorySuccessLoaded && _hasMoreSuccess) {
      final currentState = state as HistorySuccessLoaded;
      emit(currentState.copyWith(isLoadingMore: true));

      // For now, just show message that more data loading is not implemented yet
      await Future.delayed(const Duration(seconds: 1));
      emit(currentState.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> _onLoadMoreFailedPayments(
    LoadMoreFailedPaymentsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryFailedLoaded && _hasMoreFailed) {
      final currentState = state as HistoryFailedLoaded;
      emit(currentState.copyWith(isLoadingMore: true));

      // For now, just show message that more data loading is not implemented yet
      await Future.delayed(const Duration(seconds: 1));
      emit(currentState.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> _onDeletePayment(
    DeletePaymentEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(PaymentDeleting());

    final result = await deletePayment(event.paymentId);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => emit(PaymentDeleted()),
    );
  }
}
