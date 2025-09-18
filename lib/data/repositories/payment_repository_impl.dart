import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/firebase_payment_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebasePaymentDatasource _datasource;

  PaymentRepositoryImpl(this._datasource);

  @override
  Stream<List<Payment>> getPendingPayments() {
    return _datasource.getPendingPayments();
  }

  @override
  Stream<List<Payment>> getSuccessPayments({int limit = 10, Payment? lastDoc}) {
    // Convert Payment entity to DocumentSnapshot if needed for pagination
    DocumentSnapshot? lastDocSnapshot;
    // For now, we'll pass null and implement proper pagination later if needed
    return _datasource.getSuccessPayments(limit: limit, lastDoc: lastDocSnapshot);
  }

  @override
  Stream<List<Payment>> getFailedPayments({int limit = 10, Payment? lastDoc}) {
    // Convert Payment entity to DocumentSnapshot if needed for pagination
    DocumentSnapshot? lastDocSnapshot;
    // For now, we'll pass null and implement proper pagination later if needed
    return _datasource.getFailedPayments(limit: limit, lastDoc: lastDocSnapshot);
  }

  @override
  Future<void> updatePaymentStatus(String paymentId, String status) {
    return _datasource.updatePaymentStatus(paymentId, status);
  }
}
