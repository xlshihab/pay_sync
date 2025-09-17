import '../../domain/entities/sms_message.dart';

class SmsMessageModel extends SmsMessage {
  const SmsMessageModel({
    required super.id,
    required super.sender,
    required super.body,
    required super.timestamp,
    required super.isPaymentMessage,
    super.paymentInfo,
  });

  factory SmsMessageModel.fromMap(Map<String, dynamic> map) {
    PaymentInfo? paymentInfo;
    if (map['payment_info'] != null) {
      final paymentMap = map['payment_info'] as Map<String, dynamic>;
      paymentInfo = PaymentInfoModel.fromMap(paymentMap);
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_payment_message': isPaymentMessage ? 1 : 0,
      'payment_info': paymentInfo != null
          ? (paymentInfo as PaymentInfoModel).toMap()
          : null,
    };
  }

  factory SmsMessageModel.fromEntity(SmsMessage message) {
    return SmsMessageModel(
      id: message.id,
      sender: message.sender,
      body: message.body,
      timestamp: message.timestamp,
      isPaymentMessage: message.isPaymentMessage,
      paymentInfo: message.paymentInfo,
    );
  }
}

class PaymentInfoModel extends PaymentInfo {
  const PaymentInfoModel({
    required super.amount,
    super.senderPhone,
    super.reference,
    super.transactionId,
    super.balance,
    super.fee,
    required super.type,
  });

  factory PaymentInfoModel.fromMap(Map<String, dynamic> map) {
    return PaymentInfoModel(
      amount: (map['amount'] ?? 0.0).toDouble(),
      senderPhone: map['sender_phone'],
      reference: map['reference'],
      transactionId: map['transaction_id'],
      balance: map['balance']?.toDouble(),
      fee: map['fee']?.toDouble(),
      type: PaymentType.values[map['type'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'sender_phone': senderPhone,
      'reference': reference,
      'transaction_id': transactionId,
      'balance': balance,
      'fee': fee,
      'type': type.index,
    };
  }
}
