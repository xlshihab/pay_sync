import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Stream<Either<Failure, List<PaymentModel>>> watchPaymentsByStatus(
    String status, {
    int? limit,
    Payment? startAfter,
  });
  Future<Either<Failure, void>> updatePaymentStatus(String paymentId, String status);
  Future<Either<Failure, void>> deletePayment(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseFirestore firestore;

  PaymentRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<Either<Failure, List<PaymentModel>>> watchPaymentsByStatus(
    String status, {
    int? limit,
    Payment? startAfter,
  }) {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection(AppConstants.paymentsCollection)
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true);

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      // Apply startAfter for pagination if provided
      if (startAfter != null) {
        query = query.startAfter([startAfter.createdAt]);
      }

      return query.snapshots().map((snapshot) {
        try {
          final payments = snapshot.docs
              .map((doc) => PaymentModel.fromFirestore(doc))
              .toList();
          return Right(payments);
        } catch (e) {
          return Left(ServerFailure('Failed to parse payments: ${e.toString()}'));
        }
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch payments: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentStatus(String paymentId, String status) async {
    try {
      await firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .update({'status': status});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update payment status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(String paymentId) async {
    try {
      await firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete payment: ${e.toString()}'));
    }
  }
}
