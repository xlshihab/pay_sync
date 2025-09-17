import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sms_inbox_event.dart';
import 'sms_inbox_state.dart';
import '../../../domain/usecases/sms_message_usecases.dart';
import '../../../domain/services/sms_inbox_service.dart';

class SmsInboxBloc extends Bloc<SmsInboxEvent, SmsInboxState> {
  final GetAllSmsMessages getAllSmsMessages;
  final GetPaymentMessages getPaymentMessages;
  final WatchAllSmsMessages watchAllSmsMessages;
  final SmsInboxService smsInboxService;

  StreamSubscription? _messagesSubscription;

  SmsInboxBloc({
    required this.getAllSmsMessages,
    required this.getPaymentMessages,
    required this.watchAllSmsMessages,
    required this.smsInboxService,
  }) : super(SmsInboxInitial()) {
    on<LoadAllMessagesEvent>(_onLoadAllMessages);
    on<LoadPaymentMessagesEvent>(_onLoadPaymentMessages);
    on<RefreshMessagesEvent>(_onRefreshMessages);
    on<StartInboxMonitoringEvent>(_onStartInboxMonitoring);
    on<StopInboxMonitoringEvent>(_onStopInboxMonitoring);

    // Start watching messages automatically
    _startWatchingMessages();
  }

  void _startWatchingMessages() {
    _messagesSubscription = watchAllSmsMessages().listen(
      (result) {
        result.fold(
          (failure) => add(LoadAllMessagesEvent()),
          (messages) {
            if (state is SmsInboxLoaded) {
              final currentState = state as SmsInboxLoaded;
              // Use add instead of emit to avoid warning
              if (currentState.messages != messages) {
                add(LoadAllMessagesEvent());
              }
            } else {
              add(LoadAllMessagesEvent());
            }
          },
        );
      },
    );
  }

  Future<void> _onLoadAllMessages(
    LoadAllMessagesEvent event,
    Emitter<SmsInboxState> emit,
  ) async {
    emit(SmsInboxLoading());

    final result = await getAllSmsMessages();
    result.fold(
      (failure) => emit(SmsInboxError(failure.message)),
      (messages) => emit(SmsInboxLoaded(
        messages: messages,
        isMonitoring: smsInboxService.isMonitoring,
      )),
    );
  }

  Future<void> _onLoadPaymentMessages(
    LoadPaymentMessagesEvent event,
    Emitter<SmsInboxState> emit,
  ) async {
    emit(SmsInboxLoading());

    final result = await getPaymentMessages();
    result.fold(
      (failure) => emit(SmsInboxError(failure.message)),
      (messages) => emit(SmsInboxLoaded(
        messages: messages,
        isMonitoring: smsInboxService.isMonitoring,
      )),
    );
  }

  Future<void> _onRefreshMessages(
    RefreshMessagesEvent event,
    Emitter<SmsInboxState> emit,
  ) async {
    if (state is SmsInboxLoaded) {
      add(LoadAllMessagesEvent());
    }
  }

  Future<void> _onStartInboxMonitoring(
    StartInboxMonitoringEvent event,
    Emitter<SmsInboxState> emit,
  ) async {
    final success = await smsInboxService.startInboxMonitoring();

    if (state is SmsInboxLoaded) {
      final currentState = state as SmsInboxLoaded;
      emit(currentState.copyWith(isMonitoring: success));
    }
  }

  Future<void> _onStopInboxMonitoring(
    StopInboxMonitoringEvent event,
    Emitter<SmsInboxState> emit,
  ) async {
    await smsInboxService.stopInboxMonitoring();

    if (state is SmsInboxLoaded) {
      final currentState = state as SmsInboxLoaded;
      emit(currentState.copyWith(isMonitoring: false));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
