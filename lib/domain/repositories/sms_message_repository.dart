import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/sms_message.dart';

abstract class SmsMessageRepository {
  Future<Either<Failure, void>> saveSmsMessage(SmsMessage message);
  Future<Either<Failure, List<SmsMessage>>> getAllSmsMessages();
  Future<Either<Failure, List<SmsMessage>>> getPaymentMessages();
  Future<Either<Failure, SmsMessage?>> getSmsMessageById(String id);
  Future<Either<Failure, void>> deleteSmsMessage(String id);
  Stream<Either<Failure, List<SmsMessage>>> watchAllSmsMessages();
  Stream<Either<Failure, List<SmsMessage>>> watchPaymentMessages();
}
