import 'dart:async';
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../database/local_database.dart';
import '../../injection/injection_container.dart';
import 'queue_manager.dart';

class BackgroundServiceManager {
  static const String _workManagerTaskName = 'sms_sync_task';

  static BackgroundServiceManager? _instance;
  static BackgroundServiceManager get instance => _instance ??= BackgroundServiceManager._();

  BackgroundServiceManager._();

  bool _isServiceRunning = false;
  bool _isBatteryOptimizationHandled = false;

  /// Initialize background service manager
  Future<Either<Failure, void>> initialize() async {
    try {
      // Initialize WorkManager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      print('Background service manager initialized successfully');
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Failed to initialize background service: ${e.toString()}'));
    }
  }

  /// Start background SMS monitoring
  Future<Either<Failure, void>> startForegroundService() async {
    try {
      if (_isServiceRunning) {
        return const Right(null);
      }

      // Request permissions first
      final permissionResult = await _requestBackgroundPermissions();
      if (permissionResult.isLeft()) {
        return permissionResult;
      }

      // Handle battery optimization
      await _handleBatteryOptimization();

      // Register periodic WorkManager task for sync
      await _registerPeriodicSyncTask();

      _isServiceRunning = true;
      print('Background service started successfully');
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Error starting background service: ${e.toString()}'));
    }
  }

  /// Stop background service
  Future<Either<Failure, void>> stopForegroundService() async {
    try {
      await Workmanager().cancelAll();
      _isServiceRunning = false;

      print('Background service stopped successfully');
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Error stopping background service: ${e.toString()}'));
    }
  }

  /// Check if service is running
  bool get isServiceRunning => _isServiceRunning;

  /// Request all necessary background permissions
  Future<Either<Failure, void>> _requestBackgroundPermissions() async {
    try {
      final permissions = [
        Permission.notification,
        Permission.ignoreBatteryOptimizations,
      ];

      // Request permissions one by one
      for (final permission in permissions) {
        final status = await permission.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          return Left(PermissionFailure('${permission.toString()} permission denied'));
        }
      }

      // Android 10+ specific permissions
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt >= 29) {
          final backgroundStatus = await Permission.systemAlertWindow.request();
          if (backgroundStatus.isDenied || backgroundStatus.isPermanentlyDenied) {
            return const Left(PermissionFailure('Background activity permission required for Android 10+'));
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(PermissionFailure('Failed to request permissions: ${e.toString()}'));
    }
  }

  /// Handle battery optimization exemption
  Future<void> _handleBatteryOptimization() async {
    try {
      if (_isBatteryOptimizationHandled) return;

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt >= 23) {
          final status = await Permission.ignoreBatteryOptimizations.status;
          if (status.isDenied) {
            await Permission.ignoreBatteryOptimizations.request();
          }
        }
      }

      _isBatteryOptimizationHandled = true;
    } catch (e) {
      print('Error handling battery optimization: $e');
    }
  }

  /// Register periodic WorkManager task for background sync
  Future<void> _registerPeriodicSyncTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        _workManagerTaskName,
        _workManagerTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );

      print('Periodic sync task registered successfully');
    } catch (e) {
      print('Error registering periodic task: $e');
    }
  }

  /// Get service status info
  Map<String, dynamic> getServiceStatus() {
    return {
      'isRunning': _isServiceRunning,
      'batteryOptimizationHandled': _isBatteryOptimizationHandled,
    };
  }
}

/// WorkManager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('WorkManager task executing: $task');

      // Initialize local database for background context
      await LocalDatabase.database;

      // Get queue manager and process queue
      final queueManager = sl<QueueManager>();
      final result = await queueManager.processQueue();

      result.fold(
        (failure) {
          print('Background sync failed: ${failure.message}');
          return Future.value(false);
        },
        (_) {
          print('Background sync completed successfully');
          return Future.value(true);
        },
      );

      return Future.value(true);
    } catch (e) {
      print('WorkManager task error: $e');
      return Future.value(false);
    }
  });
}
