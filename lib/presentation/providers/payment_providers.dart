import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_payment_datasource.dart';
import '../../data/datasources/firebase_unmatched_payment_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/unmatched_payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/unmatched_payment_repository.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../../domain/usecases/unmatched_payment_usecases.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/unmatched_payment.dart';

// Datasource providers
final firebasePaymentDatasourceProvider = Provider<FirebasePaymentDatasource>((ref) {
  return FirebasePaymentDatasource();
});

final firebaseUnmatchedPaymentDatasourceProvider = Provider<FirebaseUnmatchedPaymentDatasource>((ref) {
  return FirebaseUnmatchedPaymentDatasource();
});

// Repository providers
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final datasource = ref.watch(firebasePaymentDatasourceProvider);
  return PaymentRepositoryImpl(datasource);
});

final unmatchedPaymentRepositoryProvider = Provider<UnmatchedPaymentRepository>((ref) {
  final datasource = ref.watch(firebaseUnmatchedPaymentDatasourceProvider);
  return UnmatchedPaymentRepositoryImpl(datasource);
});

// Use case providers
final getPendingPaymentsProvider = Provider<GetPendingPayments>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetPendingPayments(repository);
});

final getSuccessPaymentsProvider = Provider<GetSuccessPayments>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetSuccessPayments(repository);
});

final getFailedPaymentsProvider = Provider<GetFailedPayments>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetFailedPayments(repository);
});

final updatePaymentStatusProvider = Provider<UpdatePaymentStatus>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return UpdatePaymentStatus(repository);
});

final getUnmatchedPaymentsProvider = Provider<GetUnmatchedPayments>((ref) {
  final repository = ref.watch(unmatchedPaymentRepositoryProvider);
  return GetUnmatchedPayments(repository);
});

final deleteUnmatchedPaymentProvider = Provider<DeleteUnmatchedPayment>((ref) {
  final repository = ref.watch(unmatchedPaymentRepositoryProvider);
  return DeleteUnmatchedPayment(repository);
});

// Stream providers for real-time data
final pendingPaymentsStreamProvider = StreamProvider<List<Payment>>((ref) {
  final usecase = ref.watch(getPendingPaymentsProvider);
  return usecase();
});

final successPaymentsStreamProvider = StreamProvider<List<Payment>>((ref) {
  final usecase = ref.watch(getSuccessPaymentsProvider);
  return usecase();
});

final failedPaymentsStreamProvider = StreamProvider<List<Payment>>((ref) {
  final usecase = ref.watch(getFailedPaymentsProvider);
  return usecase();
});

final unmatchedPaymentsStreamProvider = StreamProvider<List<UnmatchedPayment>>((ref) {
  final usecase = ref.watch(getUnmatchedPaymentsProvider);
  return usecase();
});

// History tab state provider (success/failed tab selection)
final historyTabIndexProvider = StateProvider<int>((ref) => 0);
