import '../repositories/money_receive_repository.dart';

class DeleteUnmatchedPaymentUseCase {
  final MoneyReceiveRepository repository;

  DeleteUnmatchedPaymentUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteUnmatchedPayment(id);
  }
}
