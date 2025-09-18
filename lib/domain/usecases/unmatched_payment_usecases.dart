import '../entities/unmatched_payment.dart';
import '../repositories/unmatched_payment_repository.dart';

class GetUnmatchedPayments {
  final UnmatchedPaymentRepository repository;

  GetUnmatchedPayments(this.repository);

  Stream<List<UnmatchedPayment>> call() {
    return repository.getUnmatchedPayments();
  }
}

class DeleteUnmatchedPayment {
  final UnmatchedPaymentRepository repository;

  DeleteUnmatchedPayment(this.repository);

  Future<void> call(String paymentId) {
    return repository.deleteUnmatchedPayment(paymentId);
  }
}
