import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/unmatched_payment.dart';

class UnmatchedPaymentModel extends UnmatchedPayment {
  UnmatchedPaymentModel({
    required super.id,
    required super.amount,
    required super.receivedAt,
    required super.senderNumber,
    required super.trxId,
  });

  factory UnmatchedPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UnmatchedPaymentModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      receivedAt: (data['received_at'] as Timestamp).toDate(),
      senderNumber: data['sender_number'] as String,
      trxId: data['trx_id'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'received_at': Timestamp.fromDate(receivedAt),
      'sender_number': senderNumber,
      'trx_id': trxId,
    };
  }
}
