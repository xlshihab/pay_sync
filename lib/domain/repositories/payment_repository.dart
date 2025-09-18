import '../entities/payment.dart';

abstract class PaymentRepository {
  Stream<List<Payment>> getPendingPayments();
  Stream<List<Payment>> getSuccessPayments({int limit = 10, Payment? lastDoc});
  Stream<List<Payment>> getFailedPayments({int limit = 10, Payment? lastDoc});
  Future<void> updatePaymentStatus(String paymentId, String status);
}
