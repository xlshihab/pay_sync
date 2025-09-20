import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unmatched_payment_model.dart';

abstract class MoneyReceiveRemoteDataSource {
  Stream<List<UnmatchedPaymentModel>> getUnmatchedPayments();
  Future<void> deleteUnmatchedPayment(String id);
}

class MoneyReceiveRemoteDataSourceImpl implements MoneyReceiveRemoteDataSource {
  final FirebaseFirestore firestore;

  MoneyReceiveRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<UnmatchedPaymentModel>> getUnmatchedPayments() {
    return firestore
        .collection('unmatched_payments')
        .orderBy('received_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnmatchedPaymentModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> deleteUnmatchedPayment(String id) async {
    await firestore.collection('unmatched_payments').doc(id).delete();
  }
}
