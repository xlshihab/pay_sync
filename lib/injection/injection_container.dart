import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core Services
import '../core/services/connectivity_service.dart';
import '../core/services/queue_manager.dart';
import '../core/services/background_service_manager.dart';
import '../core/services/advanced_permission_service.dart';

// Data Sources
import '../data/datasources/payment_remote_datasource.dart';
import '../data/datasources/unmatched_payment_remote_datasource.dart';
import '../data/datasources/permission_local_datasource.dart';
import '../data/datasources/sms_local_datasource.dart';

// Repositories
import '../data/repositories/payment_repository_impl.dart';
import '../data/repositories/unmatched_payment_repository_impl.dart';
import '../data/repositories/permission_repository_impl.dart';
import '../data/repositories/sms_repository_impl.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/repositories/unmatched_payment_repository.dart';
import '../domain/repositories/permission_repository.dart';
import '../domain/repositories/sms_repository.dart';

// Use Cases
import '../domain/usecases/watch_payments_by_status.dart';
import '../domain/usecases/update_payment_status.dart';
import '../domain/usecases/delete_payment.dart';
import '../domain/usecases/permission_usecases.dart';
import '../domain/usecases/sms_usecases.dart';

// BLoCs
import '../presentation/bloc/permission/permission_bloc.dart';
import '../presentation/bloc/request/request_bloc.dart';
import '../presentation/bloc/pending/pending_bloc.dart';
import '../presentation/bloc/history/history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Core Services
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  sl.registerLazySingleton<AdvancedPermissionService>(
    () => AdvancedPermissionService.instance,
  );

  sl.registerLazySingleton<BackgroundServiceManager>(
    () => BackgroundServiceManager.instance,
  );

  // Data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<UnmatchedPaymentRemoteDataSource>(
    () => UnmatchedPaymentRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<PermissionLocalDataSource>(
    () => PermissionLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<SmsLocalDataSource>(
    () => SmsLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UnmatchedPaymentRepository>(
    () => UnmatchedPaymentRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PermissionRepository>(
    () => PermissionRepositoryImpl(localDataSource: sl()),
  );

  // QueueManager - repositories এর পরে register করতে হবে
  sl.registerLazySingleton<QueueManager>(
    () => QueueManagerImpl(
      connectivityService: sl(),
      paymentRepository: sl<UnmatchedPaymentRepository>(),
    ),
  );

  sl.registerLazySingleton<SmsRepository>(
    () => SmsRepositoryImpl(
      localDataSource: sl(),
      unmatchedPaymentRepository: sl(),
      queueManager: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => WatchPaymentsByStatus(sl()));
  sl.registerLazySingleton(() => UpdatePaymentStatus(sl()));
  sl.registerLazySingleton(() => DeletePayment(sl()));
  sl.registerLazySingleton(() => CheckRequiredPermissions(sl()));
  sl.registerLazySingleton(() => RequestRequiredPermissions(sl()));
  sl.registerLazySingleton(() => StartSmsMonitoring(sl()));
  sl.registerLazySingleton(() => StopSmsMonitoring(sl()));
  sl.registerLazySingleton(() => GetSmsPaymentStream(sl()));
  sl.registerLazySingleton(() => ParseSmsMessage(sl()));

  // BLoCs
  sl.registerFactory(() => PermissionBloc(
    checkPermissions: sl(),
    requestPermissions: sl(),
  ));

  sl.registerFactory(() => RequestBloc(
    watchPayments: sl(),
    updateStatus: sl(),
  ));

  sl.registerFactory(() => PendingBloc(
    unmatchedPaymentRepository: sl(),
    startSmsMonitoring: sl(),
    stopSmsMonitoring: sl(),
    getSmsPaymentStream: sl(),
  ));

  sl.registerFactory(() => HistoryBloc(
    watchPaymentsByStatus: sl(),
    deletePayment: sl(),
  ));
}
