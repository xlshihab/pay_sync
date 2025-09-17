import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/payment_repository.dart';

class DeletePayment {
  final PaymentRepository repository;

  DeletePayment(this.repository);

  Future<Either<Failure, void>> call(String paymentId) {
    return repository.deletePayment(paymentId);
  }
}
