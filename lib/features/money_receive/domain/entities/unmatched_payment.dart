import 'package:equatable/equatable.dart';

class UnmatchedPayment extends Equatable {
  final String id;
  final double amount;
  final String method;
  final DateTime receivedAt;
  final String senderNumber;
  final String trxId;

  const UnmatchedPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.receivedAt,
    required this.senderNumber,
    required this.trxId,
  });

  @override
  List<Object?> get props => [id, amount, method, receivedAt, senderNumber, trxId];
}
