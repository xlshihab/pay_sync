import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/payment_model.dart';

class FirebasePaymentDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PaymentModel>> getPendingPayments() {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .where('status', isEqualTo: AppConstants.statusPending)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<PaymentModel>> getSuccessPayments({
    int limit = AppConstants.pageSize,
    DocumentSnapshot? lastDoc,
  }) {
    Query query = _firestore
        .collection(AppConstants.paymentsCollection)
        .where('status', isEqualTo: AppConstants.statusSuccess)
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<PaymentModel>> getFailedPayments({
    int limit = AppConstants.pageSize,
    DocumentSnapshot? lastDoc,
  }) {
    Query query = _firestore
        .collection(AppConstants.paymentsCollection)
        .where('status', isEqualTo: AppConstants.statusFailed)
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList());
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _firestore
        .collection(AppConstants.paymentsCollection)
        .doc(paymentId)
        .update({'status': status});
  }
}
