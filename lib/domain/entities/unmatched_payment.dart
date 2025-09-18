class UnmatchedPayment {
  final String id;
  final double amount;
  final DateTime receivedAt;
  final String senderNumber;
  final String trxId;

  UnmatchedPayment({
    required this.id,
    required this.amount,
    required this.receivedAt,
    required this.senderNumber,
    required this.trxId,
  });

  UnmatchedPayment copyWith({
    String? id,
    double? amount,
    DateTime? receivedAt,
    String? senderNumber,
    String? trxId,
  }) {
    return UnmatchedPayment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      receivedAt: receivedAt ?? this.receivedAt,
      senderNumber: senderNumber ?? this.senderNumber,
      trxId: trxId ?? this.trxId,
    );
  }
}
