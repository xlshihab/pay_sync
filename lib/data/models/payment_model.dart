import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  PaymentModel({
    required super.id,
    required super.amount,
    required super.createdAt,
    required super.method,
    required super.packageType,
    required super.phone,
    required super.quantity,
    required super.status,
    required super.trxId,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      method: data['mathod'] as String, // Note: using 'mathod' as per your Firebase field
      packageType: data['package_type'] as String,
      phone: data['phone'] as String,
      quantity: data['quantity'] as int,
      status: data['status'] as String,
      trxId: data['trx_id'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'created_at': Timestamp.fromDate(createdAt),
      'mathod': method,
      'package_type': packageType,
      'phone': phone,
      'quantity': quantity,
      'status': status,
      'trx_id': trxId,
    };
  }
}
