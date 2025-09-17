import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<Payment>>> watchPaymentsByStatus(
    String status, {
    int? limit,
    Payment? startAfter,
  }) {
    return remoteDataSource.watchPaymentsByStatus(
      status,
      limit: limit,
      startAfter: startAfter,
    );
  }

  @override
  Future<Either<Failure, void>> updatePaymentStatus(String paymentId, String status) {
    return remoteDataSource.updatePaymentStatus(paymentId, status);
  }

  @override
  Future<Either<Failure, void>> deletePayment(String paymentId) {
    return remoteDataSource.deletePayment(paymentId);
  }
}
