import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import 'pending_event.dart';
import 'pending_state.dart';

class PendingBloc extends Bloc<PendingEvent, PendingState> {
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<Payment>>? _pendingSubscription;

  PendingBloc(this._paymentRepository) : super(PendingInitial()) {
    on<LoadPendingPayments>(_onLoadPendingPayments);
    on<UpdatePaymentStatus>(_onUpdatePaymentStatus);
    on<RefreshPendingPayments>(_onRefreshPendingPayments);
  }

  Future<void> _onLoadPendingPayments(LoadPendingPayments event, Emitter<PendingState> emit) async {
    emit(PendingLoading());

    try {
      _pendingSubscription?.cancel();

      await emit.forEach(
        _paymentRepository.getPaymentsByStatus(PaymentStatus.pending),
        onData: (payments) {
          return PendingLoaded( pendingPayments: payments);
        },
        onError: (error, stackTrace) {
          return PendingError('Failed to load pending payments: $error');
        },
      );
    } catch (error) {
      emit(PendingError('Failed to load pending payments: $error'));
    }
  }

  Future<void> _onUpdatePaymentStatus(UpdatePaymentStatus event, Emitter<PendingState> emit) async {
    if (state is PendingLoaded) {
      final currentState = state as PendingLoaded;
      emit(currentState.copyWith(isUpdating: true));

      try {
        await _paymentRepository.updatePaymentStatus(event.paymentId, event.newStatus);

        String statusText = event.newStatus == PaymentStatus.success ? 'successful' : 'failed';
        emit(PaymentStatusUpdated('Payment marked as $statusText'));

        // Reload pending payments
        add(LoadPendingPayments());
      } catch (error) {
        emit(PendingError('Failed to update payment status: $error'));
      }
    }
  }

  void _onRefreshPendingPayments(RefreshPendingPayments event, Emitter<PendingState> emit) {
    emit(PendingLoading());
    add(LoadPendingPayments());
  }

  @override
  Future<void> close() {
    _pendingSubscription?.cancel();
    return super.close();
  }
}
