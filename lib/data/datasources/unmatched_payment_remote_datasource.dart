import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/unmatched_payment_model.dart';

abstract class UnmatchedPaymentRemoteDataSource {
  Stream<Either<Failure, List<UnmatchedPaymentModel>>> watchUnmatchedPayments();
  Future<Either<Failure, void>> addUnmatchedPayment(UnmatchedPaymentModel payment);
  Future<Either<Failure, void>> deleteUnmatchedPayment(String paymentId);
}

class UnmatchedPaymentRemoteDataSourceImpl implements UnmatchedPaymentRemoteDataSource {
  final FirebaseFirestore firestore;

  UnmatchedPaymentRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<Either<Failure, List<UnmatchedPaymentModel>>> watchUnmatchedPayments() {
    try {
      return firestore
          .collection(AppConstants.unmatchedPaymentsCollection)
          .orderBy('received_at', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          final payments = snapshot.docs
              .map((doc) => UnmatchedPaymentModel.fromFirestore(doc))
              .toList();
          return Right(payments);
        } catch (e) {
          return Left(ServerFailure('Failed to parse unmatched payments: ${e.toString()}'));
        }
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch unmatched payments: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, void>> addUnmatchedPayment(UnmatchedPaymentModel payment) async {
    try {
      await firestore
          .collection(AppConstants.unmatchedPaymentsCollection)
          .add(payment.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add unmatched payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnmatchedPayment(String paymentId) async {
    try {
      await firestore
          .collection(AppConstants.unmatchedPaymentsCollection)
          .doc(paymentId)
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete unmatched payment: ${e.toString()}'));
    }
  }
}
