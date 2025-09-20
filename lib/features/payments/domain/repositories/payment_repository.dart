import '../entities/payment.dart';

abstract class PaymentRepository {
  // Get payments by status with pagination
  Stream<List<Payment>> getPaymentsByStatus(PaymentStatus status, {int limit = 10, int offset = 0});

  // Get payments with pagination
  Stream<List<Payment>> getPayments({int limit = 10, String? lastDocumentId});

  // Update payment status
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status);

  // Get payment by ID
  Future<Payment?> getPaymentById(String id);

  // Add new payment
  Future<void> addPayment(Payment payment);
}
