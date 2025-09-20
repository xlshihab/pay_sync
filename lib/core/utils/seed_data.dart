import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/payments/domain/entities/payment.dart';
import '../../features/payments/data/models/payment_model.dart';

class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'payments';

  static Future<void> seedTestData() async {
    try {
      print('🌱 SeedData: Starting to seed test data...');

      // Check if data already exists
      final existingData = await _firestore.collection(_collection).limit(1).get();
      if (existingData.docs.isNotEmpty) {
        print('📊 SeedData: Data already exists, skipping seed...');
        return;
      }

      // Create test payments
      final testPayments = [
        Payment(
          id: '',
          amount: 500.0,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          method: PaymentMethod.bkash,
          packageType: PackageType.monthly,
          phone: '01712345678',
          quantity: 1,
          status: PaymentStatus.pending,
          trxId: 'TXN001',
        ),
        Payment(
          id: '',
          amount: 1000.0,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          method: PaymentMethod.nagad,
          packageType: PackageType.monthly,
          phone: '01798765432',
          quantity: 2,
          status: PaymentStatus.success,
          trxId: 'TXN002',
        ),
        Payment(
          id: '',
          amount: 750.0,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          method: PaymentMethod.rocket,
          packageType: PackageType.yearly,
          phone: '01611111111',
          quantity: 1,
          status: PaymentStatus.failed,
          trxId: 'TXN003',
        ),
        Payment(
          id: '',
          amount: 300.0,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          method: PaymentMethod.bkash,
          packageType: PackageType.oneTime,
          phone: '01922222222',
          quantity: 1,
          status: PaymentStatus.pending,
          trxId: 'TXN004',
        ),
        Payment(
          id: '',
          amount: 1500.0,
          createdAt: DateTime.now().subtract(const Duration(hours: 10)),
          method: PaymentMethod.bank,
          packageType: PackageType.yearly,
          phone: '01833333333',
          quantity: 3,
          status: PaymentStatus.success,
          trxId: 'TXN005',
        ),
      ];

      // Add test payments to Firestore
      final batch = _firestore.batch();

      for (final payment in testPayments) {
        final paymentModel = PaymentModel.fromEntity(payment);
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, paymentModel.toFirestore());
      }

      await batch.commit();
      print('✅ SeedData: Successfully added ${testPayments.length} test payments');

    } catch (e) {
      print('❌ SeedData: Error seeding test data: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      print('🗑️ SeedData: Clearing all data...');

      final querySnapshot = await _firestore.collection(_collection).get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ SeedData: Successfully cleared all data');
    } catch (e) {
      print('❌ SeedData: Error clearing data: $e');
    }
  }
}
