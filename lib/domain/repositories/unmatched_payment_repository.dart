import '../entities/unmatched_payment.dart';

abstract class UnmatchedPaymentRepository {
  Stream<List<UnmatchedPayment>> getUnmatchedPayments();
  Future<void> deleteUnmatchedPayment(String paymentId);
}
