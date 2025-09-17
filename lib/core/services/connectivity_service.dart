import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class ConnectivityService {
  Future<Either<Failure, bool>> get isConnected;
  Stream<bool> get connectivityStream;
  Future<Either<Failure, void>> checkConnection();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = false;

  ConnectivityServiceImpl() {
    _initConnectivityStream();
  }

  void _initConnectivityStream() {
    _connectivityController = StreamController<bool>.broadcast();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateConnectionStatus(results);
      },
    );

    // Check initial connectivity
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking initial connectivity: $e');
      _isConnected = false;
      _connectivityController?.add(false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any connection type is available (WiFi, Mobile, Ethernet)
    final hasConnection = results.any((result) =>
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectivityController?.add(_isConnected);
      print('Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}');
    }
  }

  @override
  Future<Either<Failure, bool>> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = result.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet
      );
      return Right(hasConnection);
    } catch (e) {
      return Left(NetworkFailure('Failed to check connectivity: ${e.toString()}'));
    }
  }

  @override
  Stream<bool> get connectivityStream {
    if (_connectivityController == null) {
      _initConnectivityStream();
    }
    return _connectivityController!.stream;
  }

  @override
  Future<Either<Failure, void>> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('Failed to check connection: ${e.toString()}'));
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}
