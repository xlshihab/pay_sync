import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/payment_repository.dart';

class UpdatePaymentStatus {
  final PaymentRepository repository;

  UpdatePaymentStatus(this.repository);

  Future<Either<Failure, void>> call(String paymentId, String status) {
    return repository.updatePaymentStatus(paymentId, status);
  }
}
