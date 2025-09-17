import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/unmatched_payment.dart';

class UnmatchedPaymentModel extends UnmatchedPayment {
  const UnmatchedPaymentModel({
    required super.id,
    required super.senderNumber,
    required super.amount,
    required super.trxId,
    required super.method,
    required super.receivedAt,
  });

  factory UnmatchedPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UnmatchedPaymentModel(
      id: doc.id,
      senderNumber: data['sender_number'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      trxId: data['trx_id'] ?? '',
      method: data['method'] ?? '',
      receivedAt: (data['received_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender_number': senderNumber,
      'amount': amount,
      'trx_id': trxId,
      'method': method,
      'received_at': Timestamp.fromDate(receivedAt),
    };
  }

  factory UnmatchedPaymentModel.fromEntity(UnmatchedPayment unmatchedPayment) {
    return UnmatchedPaymentModel(
      id: unmatchedPayment.id,
      senderNumber: unmatchedPayment.senderNumber,
      amount: unmatchedPayment.amount,
      trxId: unmatchedPayment.trxId,
      method: unmatchedPayment.method,
      receivedAt: unmatchedPayment.receivedAt,
    );
  }
}
