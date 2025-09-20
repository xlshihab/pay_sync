import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, success, failed }

enum PaymentMethod { rocket, nagad, bkash, bank }

enum PackageType { monthly, yearly, oneTime }

class Payment extends Equatable {
  final String id;
  final double amount;
  final DateTime createdAt;
  final PaymentMethod method;
  final PackageType packageType;
  final String phone;
  final int quantity;
  final PaymentStatus status;
  final String trxId;

  const Payment({
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

  // Helper getters
  String get methodString => method.name;
  String get packageTypeString => packageType.name;
  String get statusString => status.name;

  // Create copy with updated status
  Payment copyWith({
    String? id,
    double? amount,
    DateTime? createdAt,
    PaymentMethod? method,
    PackageType? packageType,
    String? phone,
    int? quantity,
    PaymentStatus? status,
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

  @override
  List<Object?> get props => [
        id,
        amount,
        createdAt,
        method,
        packageType,
        phone,
        quantity,
        status,
        trxId,
      ];
}
