import '../../domain/entities/unmatched_payment.dart';
import '../../domain/repositories/money_receive_repository.dart';
import '../datasources/money_receive_remote_data_source.dart';

class MoneyReceiveRepositoryImpl implements MoneyReceiveRepository {
  final MoneyReceiveRemoteDataSource remoteDataSource;

  MoneyReceiveRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<UnmatchedPayment>> getUnmatchedPayments() {
    return remoteDataSource
        .getUnmatchedPayments()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> deleteUnmatchedPayment(String id) async {
    await remoteDataSource.deleteUnmatchedPayment(id);
  }
}
