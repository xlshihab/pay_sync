import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Equatable {
  final String id;
  final double amount;
  final DateTime createdAt;
  final PaymentMethod method;
  final PackageType packageType;
  final String phone;
  final int quantity;
  final PaymentStatus status;
  final String trxId;

  const PaymentModel({
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

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      method: _parseMethod(data['method']),
      packageType: _parsePackageType(data['package_type']),
      phone: data['phone'] ?? '',
      quantity: data['quantity'] ?? 0,
      status: _parseStatus(data['status']),
      trxId: data['trx_id'] ?? '',
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      method: _parseMethod(json['method']),
      packageType: _parsePackageType(json['package_type']),
      phone: json['phone'] ?? '',
      quantity: json['quantity'] ?? 0,
      status: _parseStatus(json['status']),
      trxId: json['trx_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'method': method.name,
      'package_type': packageType.name,
      'phone': phone,
      'quantity': quantity,
      'status': status.name,
      'trx_id': trxId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'created_at': Timestamp.fromDate(createdAt),
      'method': method.name,
      'package_type': packageType.name,
      'phone': phone,
      'quantity': quantity,
      'status': status.name,
      'trx_id': trxId,
    };
  }

  // Convert to domain entity
  Payment toEntity() {
    return Payment(
      id: id,
      amount: amount,
      createdAt: createdAt,
      method: method,
      packageType: packageType,
      phone: phone,
      quantity: quantity,
      status: status,
      trxId: trxId,
    );
  }

  // Create from domain entity
  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      id: entity.id,
      amount: entity.amount,
      createdAt: entity.createdAt,
      method: entity.method,
      packageType: entity.packageType,
      phone: entity.phone,
      quantity: entity.quantity,
      status: entity.status,
      trxId: entity.trxId,
    );
  }

  // Helper methods for parsing
  static PaymentMethod _parseMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'rocket':
        return PaymentMethod.rocket;
      case 'nagad':
        return PaymentMethod.nagad;
      case 'bkash':
        return PaymentMethod.bkash;
      case 'bank':
        return PaymentMethod.bank;
      default:
        return PaymentMethod.rocket;
    }
  }

  static PackageType _parsePackageType(String? packageType) {
    switch (packageType?.toLowerCase()) {
      case 'monthly':
        return PackageType.monthly;
      case 'yearly':
        return PackageType.yearly;
      case 'onetime':
        return PackageType.oneTime;
      default:
        return PackageType.monthly;
    }
  }

  static PaymentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
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
