import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/queue_manager.dart';
import '../../domain/entities/unmatched_payment.dart';
import '../../domain/repositories/sms_repository.dart';
import '../../domain/repositories/unmatched_payment_repository.dart';
import '../datasources/sms_local_datasource.dart';

class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDataSource localDataSource;
  final UnmatchedPaymentRepository unmatchedPaymentRepository;
  final QueueManager queueManager;

  SmsRepositoryImpl({
    required this.localDataSource,
    required this.unmatchedPaymentRepository,
    required this.queueManager,
  });

  @override
  Future<Either<Failure, void>> startSmsMonitoring() async {
    final result = await localDataSource.startSmsMonitoring();

    // Start auto-sync for queue manager
    await queueManager.startAutoSync();

    // Listen to SMS stream and add to offline queue
    localDataSource.getSmsPaymentStream().listen((event) {
      event.fold(
        (failure) {
          print('SMS parsing failure: ${failure.message}');
        },
        (payment) async {
          // Add to offline queue instead of directly to Firebase
          final queueResult = await queueManager.addToQueue(payment);
          queueResult.fold(
            (failure) => print('Failed to add payment to queue: ${failure.message}'),
            (_) => print('Payment added to offline queue successfully'),
          );
        },
      );
    });

    return result;
  }

  @override
  Future<Either<Failure, void>> stopSmsMonitoring() async {
    // Stop auto-sync
    await queueManager.stopAutoSync();

    return localDataSource.stopSmsMonitoring();
  }

  @override
  Stream<Either<Failure, UnmatchedPayment>> getSmsPaymentStream() {
    return localDataSource.getSmsPaymentStream();
  }

  @override
  Future<Either<Failure, UnmatchedPayment?>> parseSmsMessage(String message, String sender) {
    return localDataSource.parseSmsMessage(message, sender);
  }
}
