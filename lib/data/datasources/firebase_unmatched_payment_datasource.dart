import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unmatched_payment_model.dart';

class FirebaseUnmatchedPaymentDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'unmatched_payments';

  Stream<List<UnmatchedPaymentModel>> getUnmatchedPayments() {
    return _firestore
        .collection(_collectionName)
        .orderBy('received_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnmatchedPaymentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> deleteUnmatchedPayment(String paymentId) async {
    await _firestore
        .collection(_collectionName)
        .doc(paymentId)
        .delete();
  }
}
