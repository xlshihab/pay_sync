import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPendingPayments {
  final PaymentRepository repository;

  GetPendingPayments(this.repository);

  Stream<List<Payment>> call() {
    return repository.getPendingPayments();
  }
}

class GetSuccessPayments {
  final PaymentRepository repository;

  GetSuccessPayments(this.repository);

  Stream<List<Payment>> call({int limit = 10, Payment? lastDoc}) {
    return repository.getSuccessPayments(limit: limit, lastDoc: lastDoc);
  }
}

class GetFailedPayments {
  final PaymentRepository repository;

  GetFailedPayments(this.repository);

  Stream<List<Payment>> call({int limit = 10, Payment? lastDoc}) {
    return repository.getFailedPayments(limit: limit, lastDoc: lastDoc);
  }
}

class UpdatePaymentStatus {
  final PaymentRepository repository;

  UpdatePaymentStatus(this.repository);

  Future<void> call(String paymentId, String status) {
    return repository.updatePaymentStatus(paymentId, status);
  }
}
