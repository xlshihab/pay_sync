import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'payments';

  PaymentRepositoryImpl(this._firestore);

  @override
  Stream<List<Payment>> getPaymentsByStatus(PaymentStatus status, {int limit = 10, int offset = 0}) {
    print('🔍 PaymentRepository: Querying payments with status: ${status.name}, limit: $limit, offset: $offset');

    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.name)
        .orderBy('created_at', descending: true)
        .limit(limit + offset) // Get more data to skip
        .snapshots()
        .map((snapshot) {
          print('📄 PaymentRepository: Received ${snapshot.docs.length} documents for status ${status.name}');

          final allPayments = snapshot.docs
              .map((doc) {
                try {
                  return PaymentModel.fromFirestore(doc).toEntity();
                } catch (e) {
                  print('❌ Error parsing document ${doc.id}: $e');
                  return null;
                }
              })
              .where((payment) => payment != null)
              .cast<Payment>()
              .toList();

          // Skip the first 'offset' items and take only 'limit' items
          final payments = offset > 0 && allPayments.length > offset
              ? allPayments.skip(offset).take(limit).toList()
              : allPayments.take(limit).toList();

          print('✅ PaymentRepository: Successfully parsed ${payments.length} payments for status ${status.name} (offset: $offset)');
          return payments;
        });
  }

  @override
  Stream<List<Payment>> getPayments({int limit = 10, String? lastDocumentId}) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .limit(limit);

    // For now, we'll implement basic pagination later
    // The startAfterDocument needs actual DocumentSnapshot, not just ID

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc).toEntity())
        .toList());
  }

  @override
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    await _firestore.collection(_collection).doc(paymentId).update({
      'status': status.name,
    });
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return PaymentModel.fromFirestore(doc).toEntity();
    }
    return null;
  }

  @override
  Future<void> addPayment(Payment payment) async {
    final paymentModel = PaymentModel.fromEntity(payment);
    if (payment.id.isEmpty) {
      // Auto-generate ID
      await _firestore.collection(_collection).add(paymentModel.toFirestore());
    } else {
      // Use provided ID
      await _firestore
          .collection(_collection)
          .doc(payment.id)
          .set(paymentModel.toFirestore());
    }
  }
}
