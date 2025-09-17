import 'dart:async';
import 'package:dartz/dartz.dart';
import '../database/local_database.dart';
import '../errors/failures.dart';
import '../../data/models/unmatched_payment_model.dart';
import '../../domain/repositories/unmatched_payment_repository.dart';
import 'connectivity_service.dart';

abstract class QueueManager {
  Future<Either<Failure, void>> addToQueue(UnmatchedPaymentModel payment);
  Future<Either<Failure, void>> processQueue();
  Future<Either<Failure, int>> getQueueCount();
  Future<Either<Failure, void>> startAutoSync();
  Future<Either<Failure, void>> stopAutoSync();
  Stream<int> get queueCountStream;
}

class QueueManagerImpl implements QueueManager {
  final ConnectivityService _connectivityService;
  final UnmatchedPaymentRepository _paymentRepository;
  StreamController<int>? _queueCountController;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isAutoSyncActive = false;

  QueueManagerImpl({
    required ConnectivityService connectivityService,
    required UnmatchedPaymentRepository paymentRepository,
  }) : _connectivityService = connectivityService,
       _paymentRepository = paymentRepository {
    _initQueueCountStream();
    _startConnectivityListener();
  }

  void _initQueueCountStream() {
    _queueCountController = StreamController<int>.broadcast();
    _updateQueueCount();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (isConnected && _isAutoSyncActive) {
          print('Internet connected - starting queue sync');
          processQueue();
        } else if (!isConnected) {
          print('Internet disconnected - queue will wait for connection');
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> addToQueue(UnmatchedPaymentModel payment) async {
    try {
      // Convert payment model to map for database storage
      final paymentData = {
        'sender_number': payment.senderNumber,
        'amount': payment.amount,
        'trx_id': payment.trxId,
        'method': payment.method,
        'message_body': _generateMessageBody(payment),
        'received_at': payment.receivedAt.millisecondsSinceEpoch,
      };

      await LocalDatabase.insertSmsToQueue(paymentData);
      print('Payment added to local queue: ${payment.trxId}');

      // Update queue count
      _updateQueueCount();

      // Try to sync immediately if connected
      final connectivityResult = await _connectivityService.isConnected;
      connectivityResult.fold(
        (failure) => print('Failed to check connectivity: ${failure.message}'),
        (isConnected) {
          if (isConnected) {
            processQueue();
          }
        },
      );

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add payment to queue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> processQueue() async {
    try {
      // Check if we have internet connection
      final connectivityResult = await _connectivityService.isConnected;
      return connectivityResult.fold(
        (failure) => Left(failure),
        (isConnected) async {
          if (!isConnected) {
            return Left(NetworkFailure('No internet connection available'));
          }

          // Get unsynced SMS from local database
          final unsyncedSms = await LocalDatabase.getUnsyncedSms();

          if (unsyncedSms.isEmpty) {
            print('No unsynced SMS to process');
            return const Right(null);
          }

          print('Processing ${unsyncedSms.length} unsynced SMS');

          // Process each SMS
          for (final smsData in unsyncedSms) {
            final result = await _syncSingleSms(smsData);
            result.fold(
              (failure) => print('Failed to sync SMS ${smsData['id']}: ${failure.message}'),
              (_) async {
                // Mark as synced in local database
                await LocalDatabase.markSmsAsSynced(smsData['id']);
                print('SMS ${smsData['id']} synced successfully');
              },
            );
          }

          // Clean up synced records (optional - keep for history)
          // await LocalDatabase.deleteSyncedSms();

          // Update queue count
          _updateQueueCount();

          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to process queue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> _syncSingleSms(Map<String, dynamic> smsData) async {
    try {
      // Convert database record back to UnmatchedPaymentModel
      final payment = UnmatchedPaymentModel(
        id: '', // Firebase will generate
        senderNumber: smsData['sender_number'],
        amount: smsData['amount'],
        trxId: smsData['trx_id'],
        method: smsData['method'],
        receivedAt: DateTime.fromMillisecondsSinceEpoch(smsData['received_at']),
      );

      // Send to Firebase
      final result = await _paymentRepository.addUnmatchedPayment(payment);
      return result;
    } catch (e) {
      return Left(NetworkFailure('Failed to sync SMS: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getQueueCount() async {
    try {
      final count = await LocalDatabase.getQueueCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get queue count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> startAutoSync() async {
    try {
      _isAutoSyncActive = true;

      // Start periodic sync (every 30 seconds when connected)
      _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isAutoSyncActive) {
          processQueue();
        }
      });

      print('Auto-sync started');
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Failed to start auto-sync: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> stopAutoSync() async {
    try {
      _isAutoSyncActive = false;
      _syncTimer?.cancel();
      _syncTimer = null;

      print('Auto-sync stopped');
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Failed to stop auto-sync: ${e.toString()}'));
    }
  }

  @override
  Stream<int> get queueCountStream {
    if (_queueCountController == null) {
      _initQueueCountStream();
    }
    return _queueCountController!.stream;
  }

  Future<void> _updateQueueCount() async {
    try {
      final count = await LocalDatabase.getQueueCount();
      _queueCountController?.add(count);
    } catch (e) {
      print('Failed to update queue count: $e');
    }
  }

  String _generateMessageBody(UnmatchedPaymentModel payment) {
    // Reconstruct a generic message body for storage
    return 'Payment received: ${payment.amount} Tk from ${payment.senderNumber} via ${payment.method}. TrxID: ${payment.trxId}';
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _queueCountController?.close();
    _syncTimer?.cancel();
  }
}
