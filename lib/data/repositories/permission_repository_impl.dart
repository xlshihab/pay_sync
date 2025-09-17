import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_local_datasource.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionLocalDataSource localDataSource;

  PermissionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> checkSmsPermission() {
    return localDataSource.checkSmsPermission();
  }

  @override
  Future<Either<Failure, bool>> requestSmsPermission() {
    return localDataSource.requestSmsPermission();
  }

  @override
  Future<Either<Failure, bool>> checkAllRequiredPermissions() {
    return localDataSource.checkAllRequiredPermissions();
  }

  @override
  Future<Either<Failure, bool>> requestAllRequiredPermissions() {
    return localDataSource.requestAllRequiredPermissions();
  }
}
