import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/unmatched_payment.dart';
import '../../../domain/usecases/sms_usecases.dart';
import '../../../domain/repositories/unmatched_payment_repository.dart';

// Events
abstract class PendingEvent extends Equatable {
  const PendingEvent();

  @override
  List<Object> get props => [];
}

class StartSmsMonitoringEvent extends PendingEvent {}

class StopSmsMonitoringEvent extends PendingEvent {}

class LoadUnmatchedPaymentsEvent extends PendingEvent {}

class NewSmsPaymentEvent extends PendingEvent {
  final UnmatchedPayment payment;

  const NewSmsPaymentEvent(this.payment);

  @override
  List<Object> get props => [payment];
}

class DeleteUnmatchedPaymentEvent extends PendingEvent {
  final String paymentId;

  const DeleteUnmatchedPaymentEvent(this.paymentId);

  @override
  List<Object> get props => [paymentId];
}

class SyncOfflineQueueEvent extends PendingEvent {}

class UpdateQueueCountEvent extends PendingEvent {
  final int count;

  const UpdateQueueCountEvent(this.count);

  @override
  List<Object> get props => [count];
}

// States
abstract class PendingState extends Equatable {
  const PendingState();

  @override
  List<Object> get props => [];
}

class PendingInitial extends PendingState {}

class PendingLoading extends PendingState {}

class PendingLoaded extends PendingState {
  final List<UnmatchedPayment> payments;
  final bool smsMonitoringActive;
  final int? queueCount;

  const PendingLoaded(
    this.payments,
    this.smsMonitoringActive, {
    this.queueCount,
  });

  @override
  List<Object> get props => [payments, smsMonitoringActive, queueCount ?? 0];

  PendingLoaded copyWith({
    List<UnmatchedPayment>? payments,
    bool? smsMonitoringActive,
    int? queueCount,
  }) {
    return PendingLoaded(
      payments ?? this.payments,
      smsMonitoringActive ?? this.smsMonitoringActive,
      queueCount: queueCount ?? this.queueCount,
    );
  }
}

class PendingError extends PendingState {
  final String message;

  const PendingError(this.message);

  @override
  List<Object> get props => [message];
}

class SmsMonitoringStarted extends PendingState {}

class SmsMonitoringStopped extends PendingState {}

class PaymentDeleting extends PendingState {}

class PaymentDeleted extends PendingState {}

// BLoC
class PendingBloc extends Bloc<PendingEvent, PendingState> {
  final UnmatchedPaymentRepository unmatchedPaymentRepository;
  final StartSmsMonitoring startSmsMonitoring;
  final StopSmsMonitoring stopSmsMonitoring;
  final GetSmsPaymentStream getSmsPaymentStream;

  StreamSubscription? _smsSubscription;
  bool _smsMonitoringActive = false;

  PendingBloc({
    required this.unmatchedPaymentRepository,
    required this.startSmsMonitoring,
    required this.stopSmsMonitoring,
    required this.getSmsPaymentStream,
  }) : super(PendingInitial()) {
    on<StartSmsMonitoringEvent>(_onStartSmsMonitoring);
    on<StopSmsMonitoringEvent>(_onStopSmsMonitoring);
    on<SyncOfflineQueueEvent>(_onSyncOfflineQueue);
    on<UpdateQueueCountEvent>(_onUpdateQueueCount);
    on<LoadUnmatchedPaymentsEvent>(_onLoadUnmatchedPayments);
    on<NewSmsPaymentEvent>(_onNewSmsPayment);
    on<DeleteUnmatchedPaymentEvent>(_onDeleteUnmatchedPayment);
  }

  Future<void> _onStartSmsMonitoring(
    StartSmsMonitoringEvent event,
    Emitter<PendingState> emit,
  ) async {
    final result = await startSmsMonitoring();

    result.fold(
      (failure) => emit(PendingError(failure.message)),
      (_) {
        _smsMonitoringActive = true;
        emit(SmsMonitoringStarted());
        _startListeningToSmsStream();
      },
    );
  }

  Future<void> _onStopSmsMonitoring(
    StopSmsMonitoringEvent event,
    Emitter<PendingState> emit,
  ) async {
    await _smsSubscription?.cancel();
    _smsSubscription = null;

    final result = await stopSmsMonitoring();

    result.fold(
      (failure) => emit(PendingError(failure.message)),
      (_) {
        _smsMonitoringActive = false;
        emit(SmsMonitoringStopped());
      },
    );
  }

  void _startListeningToSmsStream() {
    _smsSubscription = getSmsPaymentStream().listen((result) {
      result.fold(
        (failure) {
          print('SMS parsing error: ${failure.message}');
        },
        (payment) {
          add(NewSmsPaymentEvent(payment));
        },
      );
    });
  }

  Future<void> _onNewSmsPayment(
    NewSmsPaymentEvent event,
    Emitter<PendingState> emit,
  ) async {
    if (state is PendingLoaded) {
      final currentState = state as PendingLoaded;
      emit(PendingLoaded(
        [...currentState.payments, event.payment],
        currentState.smsMonitoringActive,
        queueCount: currentState.queueCount,
      ));
    }
  }

  Future<void> _onDeleteUnmatchedPayment(
    DeleteUnmatchedPaymentEvent event,
    Emitter<PendingState> emit,
  ) async {
    emit(PaymentDeleting());
    // Implement delete logic here
  }

  Future<void> _onLoadUnmatchedPayments(
    LoadUnmatchedPaymentsEvent event,
    Emitter<PendingState> emit,
  ) async {
    emit(PendingLoading());
    // Implement load logic here
  }

  Future<void> _onSyncOfflineQueue(
    SyncOfflineQueueEvent event,
    Emitter<PendingState> emit,
  ) async {
    // Implement sync logic here
  }

  Future<void> _onUpdateQueueCount(
    UpdateQueueCountEvent event,
    Emitter<PendingState> emit,
  ) async {
    if (state is PendingLoaded) {
      final currentState = state as PendingLoaded;
      emit(currentState.copyWith(queueCount: event.count));
    }
  }

  @override
  Future<void> close() {
    _smsSubscription?.cancel();
    return super.close();
  }
}
