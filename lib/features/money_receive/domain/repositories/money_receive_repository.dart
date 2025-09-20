import '../entities/unmatched_payment.dart';

abstract class MoneyReceiveRepository {
  Stream<List<UnmatchedPayment>> getUnmatchedPayments();
  Future<void> deleteUnmatchedPayment(String id);
}
