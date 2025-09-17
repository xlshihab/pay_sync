import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/sms_message.dart';
import '../repositories/sms_message_repository.dart';

class GetAllSmsMessages {
  final SmsMessageRepository repository;

  GetAllSmsMessages(this.repository);

  Future<Either<Failure, List<SmsMessage>>> call() async {
    return await repository.getAllSmsMessages();
  }
}

class GetPaymentMessages {
  final SmsMessageRepository repository;

  GetPaymentMessages(this.repository);

  Future<Either<Failure, List<SmsMessage>>> call() async {
    return await repository.getPaymentMessages();
  }
}

class SaveSmsMessage {
  final SmsMessageRepository repository;

  SaveSmsMessage(this.repository);

  Future<Either<Failure, void>> call(SmsMessage message) async {
    return await repository.saveSmsMessage(message);
  }
}

class WatchAllSmsMessages {
  final SmsMessageRepository repository;

  WatchAllSmsMessages(this.repository);

  Stream<Either<Failure, List<SmsMessage>>> call() {
    return repository.watchAllSmsMessages();
  }
}

class WatchPaymentMessages {
  final SmsMessageRepository repository;

  WatchPaymentMessages(this.repository);

  Stream<Either<Failure, List<SmsMessage>>> call() {
    return repository.watchPaymentMessages();
  }
}

class DeleteSmsMessage {
  final SmsMessageRepository repository;

  DeleteSmsMessage(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSmsMessage(id);
  }
}
