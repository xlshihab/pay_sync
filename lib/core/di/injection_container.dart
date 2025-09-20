import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/money_receive/data/datasources/money_receive_remote_data_source.dart';
import '../../features/money_receive/data/repositories/money_receive_repository_impl.dart';
import '../../features/money_receive/domain/repositories/money_receive_repository.dart';
import '../../features/money_receive/domain/usecases/get_unmatched_payments_use_case.dart';
import '../../features/money_receive/domain/usecases/delete_unmatched_payment_use_case.dart';
import '../../features/money_receive/presentation/bloc/money_receive_bloc.dart';
// Payment features
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/pending/presentation/bloc/pending_bloc.dart';
import '../theme/theme_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Theme
  sl.registerFactory<ThemeCubit>(() => ThemeCubit());

  // Money Receive Feature
  _initMoneyReceive();

  // Payment Features
  _initPayments();
}

void _initMoneyReceive() {
  // Bloc
  sl.registerFactory<MoneyReceiveBloc>(() => MoneyReceiveBloc(
        getUnmatchedPaymentsUseCase: sl(),
        deleteUnmatchedPaymentUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton<GetUnmatchedPaymentsUseCase>(
      () => GetUnmatchedPaymentsUseCase(sl()));
  sl.registerLazySingleton<DeleteUnmatchedPaymentUseCase>(
      () => DeleteUnmatchedPaymentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MoneyReceiveRepository>(
      () => MoneyReceiveRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<MoneyReceiveRemoteDataSource>(
      () => MoneyReceiveRemoteDataSourceImpl(firestore: sl()));
}

void _initPayments() {
  // Blocs
  sl.registerFactory<HistoryBloc>(() => HistoryBloc(sl()));
  sl.registerFactory<PendingBloc>(() => PendingBloc(sl()));

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(sl()));
}
