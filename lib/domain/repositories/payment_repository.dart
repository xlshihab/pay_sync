import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  Stream<Either<Failure, List<Payment>>> watchPaymentsByStatus(
    String status, {
    int? limit,
    Payment? startAfter,
  });
  Future<Either<Failure, void>> updatePaymentStatus(String paymentId, String status);
  Future<Either<Failure, void>> deletePayment(String paymentId);
}
