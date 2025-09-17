import 'package:sqflite/sqflite.dart';
import '../models/sms_message_model.dart';
import '../../domain/entities/sms_message.dart';
import '../../core/database/local_database.dart';

abstract class SmsMessageLocalDataSource {
  Future<void> insertSmsMessage(SmsMessageModel message);
  Future<List<SmsMessageModel>> getAllSmsMessages();
  Future<List<SmsMessageModel>> getPaymentMessages();
  Future<SmsMessageModel?> getSmsMessageById(String id);
  Future<void> deleteSmsMessage(String id);
  Future<void> deleteAllSmsMessages();
  Stream<List<SmsMessageModel>> watchAllSmsMessages();
  Stream<List<SmsMessageModel>> watchPaymentMessages();
}

class SmsMessageLocalDataSourceImpl implements SmsMessageLocalDataSource {
  @override
  Future<void> insertSmsMessage(SmsMessageModel message) async {
    final db = await LocalDatabase.database;

    final messageData = {
      'id': message.id,
      'sender': message.sender,
      'body': message.body,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'is_payment_message': message.isPaymentMessage ? 1 : 0,
      'amount': message.paymentInfo?.amount,
      'sender_phone': message.paymentInfo?.senderPhone,
      'reference': message.paymentInfo?.reference,
      'transaction_id': message.paymentInfo?.transactionId,
      'balance': message.paymentInfo?.balance,
      'fee': message.paymentInfo?.fee,
      'payment_type': message.paymentInfo?.type.index,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(
      LocalDatabase.smsMessagesTable,
      messageData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<SmsMessageModel>> getAllSmsMessages() async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.smsMessagesTable,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => _mapToSmsMessage(map)).toList();
  }

  @override
  Future<List<SmsMessageModel>> getPaymentMessages() async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.smsMessagesTable,
      where: 'is_payment_message = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => _mapToSmsMessage(map)).toList();
  }

  @override
  Future<SmsMessageModel?> getSmsMessageById(String id) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.smsMessagesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToSmsMessage(maps.first);
    }
    return null;
  }

  @override
  Future<void> deleteSmsMessage(String id) async {
    final db = await LocalDatabase.database;
    await db.delete(
      LocalDatabase.smsMessagesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllSmsMessages() async {
    final db = await LocalDatabase.database;
    await db.delete(LocalDatabase.smsMessagesTable);
  }

  @override
  Stream<List<SmsMessageModel>> watchAllSmsMessages() async* {
    while (true) {
      yield await getAllSmsMessages();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Stream<List<SmsMessageModel>> watchPaymentMessages() async* {
    while (true) {
      yield await getPaymentMessages();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  SmsMessageModel _mapToSmsMessage(Map<String, dynamic> map) {
    PaymentInfoModel? paymentInfo;

    if (map['is_payment_message'] == 1 && map['amount'] != null) {
      paymentInfo = PaymentInfoModel(
        amount: (map['amount'] ?? 0.0).toDouble(),
        senderPhone: map['sender_phone'],
        reference: map['reference'],
        transactionId: map['transaction_id'],
        balance: map['balance']?.toDouble(),
        fee: map['fee']?.toDouble(),
        type: PaymentType.values[map['payment_type'] ?? 0],
      );
    }

    return SmsMessageModel(
      id: map['id'] ?? '',
      sender: map['sender'] ?? '',
      body: map['body'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isPaymentMessage: map['is_payment_message'] == 1,
      paymentInfo: paymentInfo,
    );
  }
}
