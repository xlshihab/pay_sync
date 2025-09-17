import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

class AdvancedPermissionService {
  static AdvancedPermissionService? _instance;
  static AdvancedPermissionService get instance => _instance ??= AdvancedPermissionService._();

  AdvancedPermissionService._();

  /// Check if all advanced permissions are granted
  Future<Either<Failure, bool>> checkAdvancedPermissions() async {
    try {
      final permissions = await _getRequiredPermissions();

      for (final permission in permissions) {
        final status = await permission.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          return const Right(false);
        }
      }

      // Check battery optimization separately
      final batteryOptimized = await _isBatteryOptimized();
      if (batteryOptimized) {
        return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left(PermissionFailure('Failed to check permissions: ${e.toString()}'));
    }
  }

  /// Request all advanced permissions with user-friendly dialogs
  Future<Either<Failure, bool>> requestAdvancedPermissions() async {
    try {
      // Step 1: Request basic permissions
      final basicResult = await _requestBasicPermissions();
      if (basicResult.isLeft()) {
        return basicResult;
      }

      // Step 2: Request notification permission (Android 13+)
      await _requestNotificationPermission();

      // Step 3: Handle battery optimization
      final batteryResult = await requestBatteryOptimizationExemption();
      if (batteryResult.isLeft()) {
        return batteryResult;
      }

      // Step 4: Android 10+ specific permissions
      if (Platform.isAndroid) {
        final android10Result = await _handleAndroid10PlusPermissions();
        if (android10Result.isLeft()) {
          return android10Result;
        }
      }

      return const Right(true);
    } catch (e) {
      return Left(PermissionFailure('Failed to request permissions: ${e.toString()}'));
    }
  }

  /// Request battery optimization exemption with user explanation
  Future<Either<Failure, bool>> requestBatteryOptimizationExemption() async {
    try {
      if (!Platform.isAndroid) {
        return const Right(true);
      }

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Only for Android 6+ (API 23+)
      if (androidInfo.version.sdkInt < 23) {
        return const Right(true);
      }

      final isOptimized = await _isBatteryOptimized();
      if (!isOptimized) {
        return const Right(true); // Already exempted
      }

      // Request exemption
      final status = await Permission.ignoreBatteryOptimizations.request();

      if (status.isGranted) {
        return const Right(true);
      } else {
        return const Left(PermissionFailure(
          'Battery optimization exemption is required for reliable SMS monitoring in background'
        ));
      }
    } catch (e) {
      return Left(PermissionFailure('Failed to request battery optimization exemption: ${e.toString()}'));
    }
  }

  /// Open app settings for manual permission configuration
  Future<Either<Failure, void>> openApplicationSettings() async {
    try {
      final opened = await openAppSettings();
      if (opened) {
        return const Right(null);
      } else {
        return const Left(GeneralFailure('Failed to open app settings'));
      }
    } catch (e) {
      return Left(GeneralFailure('Error opening app settings: ${e.toString()}'));
    }
  }

  /// Check if app is battery optimized
  Future<bool> _isBatteryOptimized() async {
    try {
      if (!Platform.isAndroid) return false;

      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isDenied;
    } catch (e) {
      print('Error checking battery optimization: $e');
      return true; // Assume optimized if can't check
    }
  }

  /// Get list of required permissions based on Android version
  Future<List<Permission>> _getRequiredPermissions() async {
    final permissions = <Permission>[
      Permission.sms,
      Permission.phone,
    ];

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Android 13+ (API 33+) - Notification permission
      if (androidInfo.version.sdkInt >= 33) {
        permissions.add(Permission.notification);
      }

      // Android 10+ (API 29+) - Background activity
      if (androidInfo.version.sdkInt >= 29) {
        permissions.add(Permission.systemAlertWindow);
      }
    }

    return permissions;
  }

  /// Request basic SMS and phone permissions
  Future<Either<Failure, bool>> _requestBasicPermissions() async {
    try {
      final basicPermissions = [
        Permission.sms,
        Permission.phone,
      ];

      final statuses = await basicPermissions.request();

      for (final entry in statuses.entries) {
        if (entry.value.isDenied || entry.value.isPermanentlyDenied) {
          return Left(PermissionFailure(
            '${entry.key.toString()} permission is required for SMS monitoring'
          ));
        }
      }

      return const Right(true);
    } catch (e) {
      return Left(PermissionFailure('Failed to request basic permissions: ${e.toString()}'));
    }
  }

  /// Request notification permission (Android 13+)
  Future<void> _requestNotificationPermission() async {
    try {
      if (!Platform.isAndroid) return;

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        await Permission.notification.request();
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  /// Handle Android 10+ specific permissions and restrictions
  Future<Either<Failure, bool>> _handleAndroid10PlusPermissions() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt < 29) {
        return const Right(true); // Not Android 10+
      }

      // Request background activity permission
      final backgroundStatus = await Permission.systemAlertWindow.request();
      if (backgroundStatus.isDenied) {
        return const Left(PermissionFailure(
          'Background activity permission is required for Android 10+ background SMS monitoring'
        ));
      }

      return const Right(true);
    } catch (e) {
      return Left(PermissionFailure('Failed to handle Android 10+ permissions: ${e.toString()}'));
    }
  }
}
