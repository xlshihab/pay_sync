import 'package:equatable/equatable.dart';
import '../../../domain/entities/sms_message.dart';

abstract class SmsInboxState extends Equatable {
  const SmsInboxState();

  @override
  List<Object> get props => [];
}

class SmsInboxInitial extends SmsInboxState {}

class SmsInboxLoading extends SmsInboxState {}

class SmsInboxLoaded extends SmsInboxState {
  final List<SmsMessage> messages;
  final bool isMonitoring;

  const SmsInboxLoaded({
    required this.messages,
    this.isMonitoring = false,
  });

  @override
  List<Object> get props => [messages, isMonitoring];

  SmsInboxLoaded copyWith({
    List<SmsMessage>? messages,
    bool? isMonitoring,
  }) {
    return SmsInboxLoaded(
      messages: messages ?? this.messages,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }
}

class SmsInboxError extends SmsInboxState {
  final String message;

  const SmsInboxError(this.message);

  @override
  List<Object> get props => [message];
}
