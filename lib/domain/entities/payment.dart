import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String userId;
  final String packageType;
  final int quantity;
  final double amount;
  final String trxId;
  final String status;
  final String method;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.userId,
    required this.packageType,
    required this.quantity,
    required this.amount,
    required this.trxId,
    required this.status,
    required this.method,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? userId,
    String? packageType,
    int? quantity,
    double? amount,
    String? trxId,
    String? status,
    String? method,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageType: packageType ?? this.packageType,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      trxId: trxId ?? this.trxId,
      status: status ?? this.status,
      method: method ?? this.method,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        packageType,
        quantity,
        amount,
        trxId,
        status,
        method,
        createdAt,
      ];
}
