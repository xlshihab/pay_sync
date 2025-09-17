import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/unmatched_payment.dart';
import '../../../domain/usecases/sms_usecases.dart';
import '../../../domain/repositories/unmatched_payment_repository.dart';
import '../../../core/services/background_service_manager.dart';
import '../../../core/services/advanced_permission_service.dart';
import '../../../core/services/queue_manager.dart';
import '../../../injection/injection_container.dart' as di;

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
    try {
      emit(PendingLoading());

      // Step 1: Check and request advanced permissions
      final permissionService = di.sl<AdvancedPermissionService>();
      final permissionResult = await permissionService.checkAdvancedPermissions();

      await permissionResult.fold(
        (failure) async {
          emit(PendingError('Permission check failed: ${failure.message}'));
          return;
        },
        (hasPermissions) async {
          if (!hasPermissions) {
            // Request permissions
            final requestResult = await permissionService.requestAdvancedPermissions();
            await requestResult.fold(
              (failure) async {
                emit(PendingError('Required permissions not granted: ${failure.message}'));
                return;
              },
              (granted) async {
                if (!granted) {
                  emit(const PendingError('Advanced permissions are required for background SMS monitoring'));
                  return;
                }
              },
            );
          }
        },
      );

      // Step 2: Start SMS monitoring
      final smsResult = await startSmsMonitoring();
      await smsResult.fold(
        (failure) async {
          emit(PendingError(failure.message));
        },
        (_) async {
          // Step 3: Start background service
          final backgroundService = di.sl<BackgroundServiceManager>();
          final serviceResult = await backgroundService.startForegroundService();

          await serviceResult.fold(
            (failure) async {
              print('Background service start failed: ${failure.message}');
              // Continue without background service, just show warning
            },
            (_) async {
              print('Background service started successfully');
            },
          );

          _smsMonitoringActive = true;
          emit(SmsMonitoringStarted());
          _startListeningToSmsStream();
        },
      );
    } catch (e) {
      emit(PendingError('Failed to start SMS monitoring: ${e.toString()}'));
    }
  }

  Future<void> _onStopSmsMonitoring(
    StopSmsMonitoringEvent event,
    Emitter<PendingState> emit,
  ) async {
    try {
      await _smsSubscription?.cancel();
      _smsSubscription = null;

      // Stop background service
      final backgroundService = di.sl<BackgroundServiceManager>();
      await backgroundService.stopForegroundService();

      final result = await stopSmsMonitoring();

      result.fold(
        (failure) => emit(PendingError(failure.message)),
        (_) {
          _smsMonitoringActive = false;
          emit(SmsMonitoringStopped());
        },
      );
    } catch (e) {
      emit(PendingError('Failed to stop SMS monitoring: ${e.toString()}'));
    }
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
    try {
      // Get queue manager and process queue manually
      final queueManager = di.sl<QueueManager>();
      final result = await queueManager.processQueue();

      result.fold(
        (failure) {
          // Show temporary error but don't change main state
          print('Manual sync failed: ${failure.message}');
        },
        (_) {
          print('Manual sync completed successfully');
          // Update queue count
          _updateQueueCountFromManager();
        },
      );
    } catch (e) {
      print('Error in manual sync: $e');
    }
  }

  Future<void> _updateQueueCountFromManager() async {
    try {
      final queueManager = di.sl<QueueManager>();
      final countResult = await queueManager.getQueueCount();

      countResult.fold(
        (failure) => print('Failed to get queue count: ${failure.message}'),
        (count) => add(UpdateQueueCountEvent(count)),
      );
    } catch (e) {
      print('Error getting queue count: $e');
    }
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
