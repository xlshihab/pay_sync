import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/repositories/sms_message_repository.dart';
import '../datasources/sms_message_local_datasource.dart';
import '../models/sms_message_model.dart';

class SmsMessageRepositoryImpl implements SmsMessageRepository {
  final SmsMessageLocalDataSource localDataSource;

  SmsMessageRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> saveSmsMessage(SmsMessage message) async {
    try {
      final messageModel = SmsMessageModel.fromEntity(message);
      await localDataSource.insertSmsMessage(messageModel);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Failed to save SMS message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SmsMessage>>> getAllSmsMessages() async {
    try {
      final messages = await localDataSource.getAllSmsMessages();
      return Right(messages);
    } catch (e) {
      return Left(GeneralFailure('Failed to get SMS messages: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SmsMessage>>> getPaymentMessages() async {
    try {
      final messages = await localDataSource.getPaymentMessages();
      return Right(messages);
    } catch (e) {
      return Left(GeneralFailure('Failed to get payment messages: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SmsMessage?>> getSmsMessageById(String id) async {
    try {
      final message = await localDataSource.getSmsMessageById(id);
      return Right(message);
    } catch (e) {
      return Left(GeneralFailure('Failed to get SMS message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSmsMessage(String id) async {
    try {
      await localDataSource.deleteSmsMessage(id);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Failed to delete SMS message: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<SmsMessage>>> watchAllSmsMessages() async* {
    try {
      await for (final messages in localDataSource.watchAllSmsMessages()) {
        yield Right(messages);
      }
    } catch (e) {
      yield Left(GeneralFailure('Failed to watch SMS messages: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<SmsMessage>>> watchPaymentMessages() async* {
    try {
      await for (final messages in localDataSource.watchPaymentMessages()) {
        yield Right(messages);
      }
    } catch (e) {
      yield Left(GeneralFailure('Failed to watch payment messages: ${e.toString()}'));
    }
  }
}
