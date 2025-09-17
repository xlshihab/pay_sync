import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/permission_repository.dart';

class CheckRequiredPermissions {
  final PermissionRepository repository;

  CheckRequiredPermissions(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.checkAllRequiredPermissions();
  }
}

class RequestRequiredPermissions {
  final PermissionRepository repository;

  RequestRequiredPermissions(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.requestAllRequiredPermissions();
  }
}
