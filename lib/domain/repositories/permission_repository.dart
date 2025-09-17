import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class PermissionRepository {
  Future<Either<Failure, bool>> checkSmsPermission();
  Future<Either<Failure, bool>> requestSmsPermission();
  Future<Either<Failure, bool>> checkAllRequiredPermissions();
  Future<Either<Failure, bool>> requestAllRequiredPermissions();
}
