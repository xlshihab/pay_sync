import 'dart:developer';
import '../../domain/entities/sms_message.dart';

class SmsParserService {
  static SmsParserService? _instance;
  static SmsParserService get instance => _instance ??= SmsParserService._();
  SmsParserService._();

  /// Parse SMS message and check if it's a payment message
  SmsMessage parseMessage({
    required String id,
    required String sender,
    required String body,
    required DateTime timestamp,
  }) {
    final paymentInfo = _extractPaymentInfo(body);

    return SmsMessage(
      id: id,
      sender: sender,
      body: body,
      timestamp: timestamp,
      isPaymentMessage: paymentInfo != null,
      paymentInfo: paymentInfo,
    );
  }

  /// Extract payment information from SMS body
  PaymentInfo? _extractPaymentInfo(String smsBody) {
    // Format 1: Money Received. Amount: Tk 500.00 Sender: 01737067174 Ref: N/A TxnID: 747FUXJZ Balance: Tk 500.78
    final format1 = _parseFormat1(smsBody);
    if (format1 != null) return format1;

    // Format 2: You have received Tk 1.00 from 01830493296. Fee Tk 0.00. Balance Tk 744.85. TrxID CII4HQFXEY
    final format2 = _parseFormat2(smsBody);
    if (format2 != null) return format2;

    return null;
  }

  /// Parse Format 1: Money Received. Amount: Tk 500.00 Sender: 01737067174 Ref: N/A TxnID: 747FUXJZ Balance: Tk 500.78
  PaymentInfo? _parseFormat1(String smsBody) {
    try {
      // Check if it starts with "Money Received"
      if (!smsBody.toLowerCase().contains('money received')) {
        return null;
      }

      // Extract amount
      final amountRegex = RegExp(r'Amount:\s*Tk\s*([\d,]+\.?\d*)');
      final amountMatch = amountRegex.firstMatch(smsBody);
      if (amountMatch == null) return null;

      final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));

      // Extract sender phone
      final senderRegex = RegExp(r'Sender:\s*(\d+)');
      final senderMatch = senderRegex.firstMatch(smsBody);
      final senderPhone = senderMatch?.group(1);

      // Extract reference
      final refRegex = RegExp(r'Ref:\s*([^\s]+)');
      final refMatch = refRegex.firstMatch(smsBody);
      final reference = refMatch?.group(1);

      // Extract transaction ID
      final txnRegex = RegExp(r'TxnID:\s*([^\s]+)');
      final txnMatch = txnRegex.firstMatch(smsBody);
      final transactionId = txnMatch?.group(1);

      // Extract balance
      final balanceRegex = RegExp(r'Balance:\s*Tk\s*([\d,]+\.?\d*)');
      final balanceMatch = balanceRegex.firstMatch(smsBody);
      final balance = balanceMatch != null
          ? double.parse(balanceMatch.group(1)!.replaceAll(',', ''))
          : null;

      return PaymentInfo(
        amount: amount,
        senderPhone: senderPhone,
        reference: reference == 'N/A' ? null : reference,
        transactionId: transactionId,
        balance: balance,
        type: PaymentType.received,
      );
    } catch (e) {
      log('Error parsing format 1: $e');
      return null;
    }
  }

  /// Parse Format 2: You have received Tk 1.00 from 01830493296. Fee Tk 0.00. Balance Tk 744.85. TrxID CII4HQFXEY
  PaymentInfo? _parseFormat2(String smsBody) {
    try {
      // Check if it contains "received" and "from"
      if (!smsBody.toLowerCase().contains('received') ||
          !smsBody.toLowerCase().contains('from')) {
        return null;
      }

      // Extract amount
      final amountRegex = RegExp(r'received\s+Tk\s*([\d,]+\.?\d*)', caseSensitive: false);
      final amountMatch = amountRegex.firstMatch(smsBody);
      if (amountMatch == null) return null;

      final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));

      // Extract sender phone
      final senderRegex = RegExp(r'from\s+(\d+)', caseSensitive: false);
      final senderMatch = senderRegex.firstMatch(smsBody);
      final senderPhone = senderMatch?.group(1);

      // Extract fee
      final feeRegex = RegExp(r'Fee\s+Tk\s*([\d,]+\.?\d*)', caseSensitive: false);
      final feeMatch = feeRegex.firstMatch(smsBody);
      final fee = feeMatch != null
          ? double.parse(feeMatch.group(1)!.replaceAll(',', ''))
          : null;

      // Extract balance
      final balanceRegex = RegExp(r'Balance\s+Tk\s*([\d,]+\.?\d*)', caseSensitive: false);
      final balanceMatch = balanceRegex.firstMatch(smsBody);
      final balance = balanceMatch != null
          ? double.parse(balanceMatch.group(1)!.replaceAll(',', ''))
          : null;

      // Extract transaction ID
      final txnRegex = RegExp(r'TrxID\s+([^\s]+)', caseSensitive: false);
      final txnMatch = txnRegex.firstMatch(smsBody);
      final transactionId = txnMatch?.group(1);

      return PaymentInfo(
        amount: amount,
        senderPhone: senderPhone,
        fee: fee,
        balance: balance,
        transactionId: transactionId,
        type: PaymentType.received,
      );
    } catch (e) {
      log('Error parsing format 2: $e');
      return null;
    }
  }
}
