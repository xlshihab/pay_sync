import 'package:equatable/equatable.dart';

abstract class SmsInboxEvent extends Equatable {
  const SmsInboxEvent();

  @override
  List<Object> get props => [];
}

class LoadAllMessagesEvent extends SmsInboxEvent {}

class LoadPaymentMessagesEvent extends SmsInboxEvent {}

class RefreshMessagesEvent extends SmsInboxEvent {}

class StartInboxMonitoringEvent extends SmsInboxEvent {}

class StopInboxMonitoringEvent extends SmsInboxEvent {}
