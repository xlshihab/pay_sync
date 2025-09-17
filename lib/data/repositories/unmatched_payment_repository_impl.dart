import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/unmatched_payment.dart';
import '../../domain/repositories/unmatched_payment_repository.dart';
import '../datasources/unmatched_payment_remote_datasource.dart';
import '../models/unmatched_payment_model.dart';

class UnmatchedPaymentRepositoryImpl implements UnmatchedPaymentRepository {
  final UnmatchedPaymentRemoteDataSource remoteDataSource;

  UnmatchedPaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<UnmatchedPayment>>> watchUnmatchedPayments() {
    return remoteDataSource.watchUnmatchedPayments();
  }

  @override
  Future<Either<Failure, void>> addUnmatchedPayment(UnmatchedPayment payment) {
    final model = UnmatchedPaymentModel.fromEntity(payment);
    return remoteDataSource.addUnmatchedPayment(model);
  }

  @override
  Future<Either<Failure, void>> deleteUnmatchedPayment(String paymentId) {
    return remoteDataSource.deleteUnmatchedPayment(paymentId);
  }
}
