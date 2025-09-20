import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/unmatched_payment.dart';

class UnmatchedPaymentModel extends Equatable {
  final String id;
  final double amount;
  final String method;
  final DateTime receivedAt;
  final String senderNumber;
  final String trxId;

  const UnmatchedPaymentModel({
    required this.id,
    required this.amount,
    required this.method,
    required this.receivedAt,
    required this.senderNumber,
    required this.trxId,
  });

  factory UnmatchedPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UnmatchedPaymentModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      method: data['method'] ?? '',
      receivedAt: (data['received_at'] as Timestamp).toDate(),
      senderNumber: data['sender_number'] ?? '',
      trxId: data['trx_id'] ?? '',
    );
  }

  factory UnmatchedPaymentModel.fromJson(Map<String, dynamic> json) {
    return UnmatchedPaymentModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? '',
      receivedAt: DateTime.parse(json['received_at']),
      senderNumber: json['sender_number'] ?? '',
      trxId: json['trx_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'method': method,
      'received_at': receivedAt.toIso8601String(),
      'sender_number': senderNumber,
      'trx_id': trxId,
    };
  }

  // Convert to domain entity
  UnmatchedPayment toEntity() {
    return UnmatchedPayment(
      id: id,
      amount: amount,
      method: method,
      receivedAt: receivedAt,
      senderNumber: senderNumber,
      trxId: trxId,
    );
  }

  // Create from domain entity
  factory UnmatchedPaymentModel.fromEntity(UnmatchedPayment entity) {
    return UnmatchedPaymentModel(
      id: entity.id,
      amount: entity.amount,
      method: entity.method,
      receivedAt: entity.receivedAt,
      senderNumber: entity.senderNumber,
      trxId: entity.trxId,
    );
  }

  @override
  List<Object?> get props => [id, amount, method, receivedAt, senderNumber, trxId];
}
