import '../../domain/entities/unmatched_payment.dart';
import '../../domain/repositories/unmatched_payment_repository.dart';
import '../datasources/firebase_unmatched_payment_datasource.dart';

class UnmatchedPaymentRepositoryImpl implements UnmatchedPaymentRepository {
  final FirebaseUnmatchedPaymentDatasource _datasource;

  UnmatchedPaymentRepositoryImpl(this._datasource);

  @override
  Stream<List<UnmatchedPayment>> getUnmatchedPayments() {
    return _datasource.getUnmatchedPayments();
  }

  @override
  Future<void> deleteUnmatchedPayment(String paymentId) {
    return _datasource.deleteUnmatchedPayment(paymentId);
  }
}
