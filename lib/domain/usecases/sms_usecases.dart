import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/unmatched_payment.dart';
import '../repositories/sms_repository.dart';

class StartSmsMonitoring {
  final SmsRepository repository;

  StartSmsMonitoring(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.startSmsMonitoring();
  }
}

class StopSmsMonitoring {
  final SmsRepository repository;

  StopSmsMonitoring(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.stopSmsMonitoring();
  }
}

class GetSmsPaymentStream {
  final SmsRepository repository;

  GetSmsPaymentStream(this.repository);

  Stream<Either<Failure, UnmatchedPayment>> call() {
    return repository.getSmsPaymentStream();
  }
}

class ParseSmsMessage {
  final SmsRepository repository;

  ParseSmsMessage(this.repository);

  Future<Either<Failure, UnmatchedPayment?>> call(String message, String sender) {
    return repository.parseSmsMessage(message, sender);
  }
}
