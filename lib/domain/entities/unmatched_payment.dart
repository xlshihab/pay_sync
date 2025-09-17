import 'package:equatable/equatable.dart';

class UnmatchedPayment extends Equatable {
  final String id;
  final String senderNumber;
  final double amount;
  final String trxId;
  final String method;
  final DateTime receivedAt;

  const UnmatchedPayment({
    required this.id,
    required this.senderNumber,
    required this.amount,
    required this.trxId,
    required this.method,
    required this.receivedAt,
  });

  UnmatchedPayment copyWith({
    String? id,
    String? senderNumber,
    double? amount,
    String? trxId,
    String? method,
    DateTime? receivedAt,
  }) {
    return UnmatchedPayment(
      id: id ?? this.id,
      senderNumber: senderNumber ?? this.senderNumber,
      amount: amount ?? this.amount,
      trxId: trxId ?? this.trxId,
      method: method ?? this.method,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderNumber,
        amount,
        trxId,
        method,
        receivedAt,
      ];
}
