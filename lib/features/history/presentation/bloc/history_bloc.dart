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
    print('🚀 HistoryBloc: Starting to load success payments');
    if (state is! HistoryLoaded) {
      emit(HistoryLoading());
    }

    try {
      _successSubscription?.cancel();

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.success, limit: 10),
        onData: (payments) {
          print('📦 HistoryBloc: Received ${payments.length} success payments');
          print('✅ HistoryBloc: Emitting HistoryLoaded state for success payments');

          if (state is HistoryLoaded) {
            final currentState = state as HistoryLoaded;
            return currentState.copyWith(successPayments: payments);
          } else {
            return HistoryLoaded(
              successPayments: payments,
              failedPayments: const [],
            );
          }
        },
        onError: (error, stackTrace) {
          print('❌ HistoryBloc: Success payments stream error - $error');
          return HistoryError('Failed to load success payments: $error');
        },
      );
    } catch (error) {
      print('💥 HistoryBloc: Exception in _onLoadSuccessPayments - $error');
      emit(HistoryError('Failed to load success payments: $error'));
    }
  }

  Future<void> _onLoadFailedPayments(LoadFailedPayments event, Emitter<HistoryState> emit) async {
    print('🚀 HistoryBloc: Starting to load failed payments');
    if (state is! HistoryLoaded) {
      emit(HistoryLoading());
    }

    try {
      _failedSubscription?.cancel();

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.failed, limit: 10),
        onData: (payments) {
          print('📦 HistoryBloc: Received ${payments.length} failed payments');
          print('✅ HistoryBloc: Emitting HistoryLoaded state for failed payments');

          if (state is HistoryLoaded) {
            final currentState = state as HistoryLoaded;
            return currentState.copyWith(failedPayments: payments);
          } else {
            return HistoryLoaded(
              successPayments: const [],
              failedPayments: payments,
            );
          }
        },
        onError: (error, stackTrace) {
          print('❌ HistoryBloc: Failed payments stream error - $error');
          return HistoryError('Failed to load failed payments: $error');
        },
      );
    } catch (error) {
      print('💥 HistoryBloc: Exception in _onLoadFailedPayments - $error');
      emit(HistoryError('Failed to load failed payments: $error'));
    }
  }

  void _onLoadMoreSuccessPayments(LoadMoreSuccessPayments event, Emitter<HistoryState> emit) {
    // TODO: Implement pagination for more success payments
  }

  void _onLoadMoreFailedPayments(LoadMoreFailedPayments event, Emitter<HistoryState> emit) {
    // TODO: Implement pagination for more failed payments
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
