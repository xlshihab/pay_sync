import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<Payment>>? _successSubscription;
  StreamSubscription<List<Payment>>? _failedSubscription;

  HistoryBloc(this._paymentRepository) : super(HistoryInitial()) {
    on<LoadSuccessPayments>(_onLoadSuccessPayments);
    on<LoadFailedPayments>(_onLoadFailedPayments);
    on<LoadMoreSuccessPayments>(_onLoadMoreSuccessPayments);
    on<LoadMoreFailedPayments>(_onLoadMoreFailedPayments);
    on<RefreshPayments>(_onRefreshPayments);
  }

  Future<void> _onLoadSuccessPayments(LoadSuccessPayments event, Emitter<HistoryState> emit) async {
    if (state is! HistoryLoaded) {
      emit(HistoryLoading());
    }

    try {
      _successSubscription?.cancel();

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.success, limit: 10, offset: 0),
        onData: (payments) {
          final hasMore = payments.length == 10;

          if (state is HistoryLoaded) {
            final currentState = state as HistoryLoaded;
            return currentState.copyWith(
              successPayments: payments,
              hasMoreSuccess: hasMore,
              successPage: 0,
            );
          } else {
            return HistoryLoaded(
              successPayments: payments,
              failedPayments: const [],
              hasMoreSuccess: hasMore,
              successPage: 0,
            );
          }
        },
        onError: (error, stackTrace) {
          return HistoryError('Failed to load success payments: $error');
        },
      );
    } catch (error) {
      emit(HistoryError('Failed to load success payments: $error'));
    }
  }

  Future<void> _onLoadFailedPayments(LoadFailedPayments event, Emitter<HistoryState> emit) async {
    if (state is! HistoryLoaded) {
      emit(HistoryLoading());
    }

    try {
      _failedSubscription?.cancel();

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.failed, limit: 10, offset: 0),
        onData: (payments) {
          final hasMore = payments.length == 10;

          if (state is HistoryLoaded) {
            final currentState = state as HistoryLoaded;
            return currentState.copyWith(
              failedPayments: payments,
              hasMoreFailed: hasMore,
              failedPage: 0,
            );
          } else {
            return HistoryLoaded(
              successPayments: const [],
              failedPayments: payments,
              hasMoreFailed: hasMore,
              failedPage: 0,
            );
          }
        },
        onError: (error, stackTrace) {
          return HistoryError('Failed to load failed payments: $error');
        },
      );
    } catch (error) {
      emit(HistoryError('Failed to load failed payments: $error'));
    }
  }

  Future<void> _onLoadMoreSuccessPayments(LoadMoreSuccessPayments event, Emitter<HistoryState> emit) async {
    if (state is! HistoryLoaded) return;

    final currentState = state as HistoryLoaded;
    if (!currentState.hasMoreSuccess || currentState.isLoadingMoreSuccess) return;

    emit(currentState.copyWith(isLoadingMoreSuccess: true));

    try {
      final nextPage = currentState.successPage + 1;
      final offset = nextPage * 10;

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.success, limit: 10, offset: offset),
        onData: (newPayments) {
          final allPayments = [...currentState.successPayments, ...newPayments];
          final hasMore = newPayments.length == 10;

          return currentState.copyWith(
            successPayments: allPayments,
            isLoadingMoreSuccess: false,
            hasMoreSuccess: hasMore,
            successPage: nextPage,
          );
        },
        onError: (error, stackTrace) {
          return currentState.copyWith(isLoadingMoreSuccess: false);
        },
      );
    } catch (error) {
      emit(currentState.copyWith(isLoadingMoreSuccess: false));
    }
  }

  Future<void> _onLoadMoreFailedPayments(LoadMoreFailedPayments event, Emitter<HistoryState> emit) async {
    if (state is! HistoryLoaded) return;

    final currentState = state as HistoryLoaded;
    if (!currentState.hasMoreFailed || currentState.isLoadingMoreFailed) return;

    emit(currentState.copyWith(isLoadingMoreFailed: true));

    try {
      final nextPage = currentState.failedPage + 1;
      final offset = nextPage * 10;

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.failed, limit: 10, offset: offset),
        onData: (newPayments) {
          final allPayments = [...currentState.failedPayments, ...newPayments];
          final hasMore = newPayments.length == 10;

          return currentState.copyWith(
            failedPayments: allPayments,
            isLoadingMoreFailed: false,
            hasMoreFailed: hasMore,
            failedPage: nextPage,
          );
        },
        onError: (error, stackTrace) {
          return currentState.copyWith(isLoadingMoreFailed: false);
        },
      );
    } catch (error) {
      emit(currentState.copyWith(isLoadingMoreFailed: false));
    }
  }

  void _onRefreshPayments(RefreshPayments event, Emitter<HistoryState> emit) {
    emit(HistoryLoading());
    add(LoadSuccessPayments());
    add(LoadFailedPayments());
  }

  @override
  Future<void> close() {
    _successSubscription?.cancel();
    _failedSubscription?.cancel();
    return super.close();
  }
}
