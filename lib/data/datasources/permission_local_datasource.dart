import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class PermissionLocalDataSource {
  Future<Either<Failure, bool>> checkSmsPermission();
  Future<Either<Failure, bool>> requestSmsPermission();
  Future<Either<Failure, bool>> checkAllRequiredPermissions();
  Future<Either<Failure, bool>> requestAllRequiredPermissions();
}

class PermissionLocalDataSourceImpl implements PermissionLocalDataSource {
  final Telephony telephony = Telephony.instance;

  @override
  Future<Either<Failure, bool>> checkSmsPermission() async {
    try {
      final smsPermission = await Permission.sms.status;
      final isSmsCapable = await telephony.isSmsCapable;

      return Right(smsPermission.isGranted && (isSmsCapable ?? false));
    } catch (e) {
      return Left(PermissionFailure('Failed to check SMS permission: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestSmsPermission() async {
    try {
      // Check if device supports SMS
      final isSmsCapable = await telephony.isSmsCapable;
      if (!(isSmsCapable ?? false)) {
        return Left(PermissionFailure('Device does not support SMS'));
      }

      // Request SMS permissions
      final smsStatus = await Permission.sms.request();
      final telephonyPermission = await telephony.requestSmsPermissions;

      return Right(smsStatus.isGranted && (telephonyPermission ?? false));
    } catch (e) {
      return Left(PermissionFailure('Failed to request SMS permission: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAllRequiredPermissions() async {
    try {
      final smsStatus = await Permission.sms.status;
      final phoneStatus = await Permission.phone.status;
      final isSmsCapable = await telephony.isSmsCapable;

      return Right(smsStatus.isGranted && phoneStatus.isGranted && (isSmsCapable ?? false));
    } catch (e) {
      return Left(PermissionFailure('Failed to check permissions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestAllRequiredPermissions() async {
    try {
      // Check SMS capability first
      final isSmsCapable = await telephony.isSmsCapable;
      if (!(isSmsCapable ?? false)) {
        return Left(PermissionFailure('Device does not support SMS'));
      }

      // Request all required permissions
      final permissions = await [
        Permission.sms,
        Permission.phone,
      ].request();

      // Also request telephony specific permissions
      final telephonyPermission = await telephony.requestSmsPermissions;

      final allGranted = permissions.values.every((status) => status.isGranted) &&
          (telephonyPermission ?? false);

      return Right(allGranted);
    } catch (e) {
      return Left(PermissionFailure('Failed to request permissions: ${e.toString()}'));
    }
  }
}
