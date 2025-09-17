import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class WatchPaymentsByStatus {
  final PaymentRepository repository;

  WatchPaymentsByStatus(this.repository);

  Stream<Either<Failure, List<Payment>>> call(
    String status, {
    int? limit,
    Payment? startAfter,
  }) {
    return repository.watchPaymentsByStatus(
      status,
      limit: limit,
      startAfter: startAfter,
    );
  }
}
