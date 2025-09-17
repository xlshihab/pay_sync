import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:another_telephony/telephony.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';
import '../models/unmatched_payment_model.dart';

abstract class SmsLocalDataSource {
  Future<Either<Failure, void>> startSmsMonitoring();
  Future<Either<Failure, void>> stopSmsMonitoring();
  Stream<Either<Failure, UnmatchedPaymentModel>> getSmsPaymentStream();
  Future<Either<Failure, UnmatchedPaymentModel?>> parseSmsMessage(String message, String sender);
}

class SmsLocalDataSourceImpl implements SmsLocalDataSource {
  final Telephony telephony = Telephony.instance;
  StreamController<Either<Failure, UnmatchedPaymentModel>>? _smsController;
  bool _isMonitoring = false;

  SmsLocalDataSourceImpl();

  @override
  Future<Either<Failure, void>> startSmsMonitoring() async {
    try {
      if (_isMonitoring) {
        return const Right(null);
      }

      _smsController = StreamController<Either<Failure, UnmatchedPaymentModel>>.broadcast();

      // Start real-time SMS listening using another_telephony
      await _startListening();

      _isMonitoring = true;
      print('Real-time SMS monitoring started successfully');
      return const Right(null);
    } catch (e) {
      return Left(SmsParsingFailure('Failed to start SMS monitoring: ${e.toString()}'));
    }
  }

  Future<void> _startListening() async {
    try {
      // Listen for incoming SMS messages in real-time
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          _handleIncomingSms(message);
        },
        onBackgroundMessage: onBackgroundMessage,
        listenInBackground: true,
      );
    } catch (e) {
      throw Exception('Failed to start SMS listening: ${e.toString()}');
    }
  }

  void _handleIncomingSms(SmsMessage message) {
    if (_smsController != null && !_smsController!.isClosed) {
      final sender = message.address ?? '';
      final body = message.body ?? '';

      print('New SMS received from $sender: $body');

      // Parse the SMS and add to stream if it's a payment SMS
      parseSmsMessage(body, sender).then((result) {
        result.fold(
          (failure) => _smsController!.add(Left(failure)),
          (payment) {
            if (payment != null) {
              print('Payment SMS detected: ${payment.amount} Tk from ${payment.senderNumber}');
              _smsController!.add(Right(payment));
            }
          },
        );
      });
    }
  }

  // Background message handler (static method required)
  static onBackgroundMessage(SmsMessage message) {
    print("Background SMS received: ${message.body}");
    // Could store in local database or handle background processing
  }

  @override
  Future<Either<Failure, void>> stopSmsMonitoring() async {
    try {
      await _smsController?.close();
      _smsController = null;
      _isMonitoring = false;
      print('SMS monitoring stopped');
      return const Right(null);
    } catch (e) {
      return Left(SmsParsingFailure('Failed to stop SMS monitoring: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, UnmatchedPaymentModel>> getSmsPaymentStream() {
    if (_smsController == null) {
      return Stream.value(Left(SmsParsingFailure('SMS monitoring not started')));
    }
    return _smsController!.stream;
  }

  @override
  Future<Either<Failure, UnmatchedPaymentModel?>> parseSmsMessage(String message, String sender) async {
    try {
      final lowerMessage = message.toLowerCase();

      // Bkash SMS parsing
      if (_isBkashMessage(lowerMessage)) {
        return _parseBkashSms(message, sender);
      }

      // Nagad SMS parsing
      if (_isNagadMessage(lowerMessage)) {
        return _parseNagadSms(message, sender);
      }

      return const Right(null); // Not a payment SMS
    } catch (e) {
      return Left(SmsParsingFailure('Failed to parse SMS: ${e.toString()}'));
    }
  }

  bool _isBkashMessage(String message) {
    return message.contains('bkash') &&
        message.contains('received') &&
        message.contains('tk');
  }

  bool _isNagadMessage(String message) {
    return message.contains('nagad') &&
        message.contains('money received') &&
        message.contains('amount');
  }

  Either<Failure, UnmatchedPaymentModel?> _parseBkashSms(String message, String sender) {
    try {
      // Example: "You have received Tk 735.00 from 01954880349.Ref wifi. Fee Tk 0.00. Balance Tk 762.57. TrxID CHI8MADSNW at 18/08/2025 23:47"

      final amountRegex = RegExp(r'received Tk (\d+\.?\d*)');
      final senderRegex = RegExp(r'from (\d{11})');
      final trxIdRegex = RegExp(r'TrxID ([A-Z0-9]+)');

      final amountMatch = amountRegex.firstMatch(message);
      final senderMatch = senderRegex.firstMatch(message);
      final trxIdMatch = trxIdRegex.firstMatch(message);

      if (amountMatch == null || senderMatch == null || trxIdMatch == null) {
        return const Right(null);
      }

      final amount = double.parse(amountMatch.group(1)!);
      final senderNumber = senderMatch.group(1)!;
      final trxId = trxIdMatch.group(1)!;
      final receivedAt = DateTime.now();

      final payment = UnmatchedPaymentModel(
        id: '', // Will be set by Firebase
        senderNumber: senderNumber,
        amount: amount,
        trxId: trxId,
        method: AppConstants.methodBkash,
        receivedAt: receivedAt,
      );

      return Right(payment);
    } catch (e) {
      return Left(SmsParsingFailure('Failed to parse Bkash SMS: ${e.toString()}'));
    }
  }

  Either<Failure, UnmatchedPaymentModel?> _parseNagadSms(String message, String sender) {
    try {
      // Example: "Money Received.\nAmount: Tk 500.00\nSender: 01737067174\nRef: N/A\nTxnID: 747FUXJZ\nBalance: Tk 500.78\n30/07/2025 11:54"

      final amountRegex = RegExp(r'Amount: Tk (\d+\.?\d*)');
      final senderRegex = RegExp(r'Sender: (\d{11})');
      final trxIdRegex = RegExp(r'TxnID: ([A-Z0-9]+)');

      final amountMatch = amountRegex.firstMatch(message);
      final senderMatch = senderRegex.firstMatch(message);
      final trxIdMatch = trxIdRegex.firstMatch(message);

      if (amountMatch == null || senderMatch == null || trxIdMatch == null) {
        return const Right(null);
      }

      final amount = double.parse(amountMatch.group(1)!);
      final senderNumber = senderMatch.group(1)!;
      final trxId = trxIdMatch.group(1)!;
      final receivedAt = DateTime.now();

      final payment = UnmatchedPaymentModel(
        id: '', // Will be set by Firebase
        senderNumber: senderNumber,
        amount: amount,
        trxId: trxId,
        method: AppConstants.methodNagad,
        receivedAt: receivedAt,
      );

      return Right(payment);
    } catch (e) {
      return Left(SmsParsingFailure('Failed to parse Nagad SMS: ${e.toString()}'));
    }
  }

  // Method to manually add a test SMS (for testing purposes)
  void addTestSms(String message, String sender) {
    if (_smsController != null && _isMonitoring) {
      parseSmsMessage(message, sender).then((result) {
        result.fold(
          (failure) => _smsController?.add(Left(failure)),
          (payment) => payment != null ? _smsController?.add(Right(payment)) : null,
        );
      });
    }
  }

  // Method to get SMS messages from device (requires permissions)
  Future<Either<Failure, List<SmsMessage>>> getInboxSms() async {
    try {
      final messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      return Right(messages);
    } catch (e) {
      return Left(SmsParsingFailure('Failed to get SMS messages: ${e.toString()}'));
    }
  }
}

