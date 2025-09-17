import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.packageType,
    required super.quantity,
    required super.amount,
    required super.trxId,
    required super.status,
    required super.method,
    required super.createdAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      packageType: data['package_type'] ?? '',
      quantity: data['quantity'] ?? 0,
      amount: (data['amount'] ?? 0).toDouble(),
      trxId: data['trx_id'] ?? '',
      status: data['status'] ?? '',
      method: data['method'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'package_type': packageType,
      'quantity': quantity,
      'amount': amount,
      'trx_id': trxId,
      'status': status,
      'method': method,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      userId: payment.userId,
      packageType: payment.packageType,
      quantity: payment.quantity,
      amount: payment.amount,
      trxId: payment.trxId,
      status: payment.status,
      method: payment.method,
      createdAt: payment.createdAt,
    );
  }
}
