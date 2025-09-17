import 'package:equatable/equatable.dart';

class SmsMessage extends Equatable {
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final bool isPaymentMessage;
  final PaymentInfo? paymentInfo;

  const SmsMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.isPaymentMessage,
    this.paymentInfo,
  });

  @override
  List<Object?> get props => [
        id,
        sender,
        body,
        timestamp,
        isPaymentMessage,
        paymentInfo,
      ];
}

class PaymentInfo extends Equatable {
  final double amount;
  final String? senderPhone;
  final String? reference;
  final String? transactionId;
  final double? balance;
  final double? fee;
  final PaymentType type;

  const PaymentInfo({
    required this.amount,
    this.senderPhone,
    this.reference,
    this.transactionId,
    this.balance,
    this.fee,
    required this.type,
  });

  @override
  List<Object?> get props => [
        amount,
        senderPhone,
        reference,
        transactionId,
        balance,
        fee,
        type,
      ];
}

enum PaymentType {
  received,
  sent,
  unknown,
}
