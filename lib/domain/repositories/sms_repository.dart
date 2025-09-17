import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/unmatched_payment.dart';

abstract class SmsRepository {
  Future<Either<Failure, void>> startSmsMonitoring();
  Future<Either<Failure, void>> stopSmsMonitoring();
  Stream<Either<Failure, UnmatchedPayment>> getSmsPaymentStream();
  Future<Either<Failure, UnmatchedPayment?>> parseSmsMessage(String message, String sender);
}
