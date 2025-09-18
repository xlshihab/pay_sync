class Payment {
  final String id;
  final double amount;
  final DateTime createdAt;
  final String method;
  final String packageType;
  final String phone;
  final int quantity;
  final String status;
  final String trxId;

  Payment({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.method,
    required this.packageType,
    required this.phone,
    required this.quantity,
    required this.status,
    required this.trxId,
  });

  Payment copyWith({
    String? id,
    double? amount,
    DateTime? createdAt,
    String? method,
    String? packageType,
    String? phone,
    int? quantity,
    String? status,
    String? trxId,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      method: method ?? this.method,
      packageType: packageType ?? this.packageType,
      phone: phone ?? this.phone,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      trxId: trxId ?? this.trxId,
    );
  }
}
