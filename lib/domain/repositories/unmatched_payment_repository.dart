import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/unmatched_payment.dart';

abstract class UnmatchedPaymentRepository {
  Future<Either<Failure, void>> addUnmatchedPayment(UnmatchedPayment payment);
  Stream<Either<Failure, List<UnmatchedPayment>>> watchUnmatchedPayments();
  Future<Either<Failure, void>> deleteUnmatchedPayment(String paymentId);
}
