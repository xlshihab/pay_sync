import '../entities/unmatched_payment.dart';
import '../repositories/money_receive_repository.dart';

class GetUnmatchedPaymentsUseCase {
  final MoneyReceiveRepository repository;

  GetUnmatchedPaymentsUseCase(this.repository);

  Stream<List<UnmatchedPayment>> call() {
    return repository.getUnmatchedPayments();
  }
}
