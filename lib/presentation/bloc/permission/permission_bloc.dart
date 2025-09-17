import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/permission_usecases.dart';

// Events
abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

class CheckPermissionsEvent extends PermissionEvent {}

class RequestPermissionsEvent extends PermissionEvent {}

// States
abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionChecking extends PermissionState {}

class PermissionGranted extends PermissionState {}

class PermissionDenied extends PermissionState {
  final String message;

  const PermissionDenied(this.message);

  @override
  List<Object> get props => [message];
}

class PermissionRequesting extends PermissionState {}

// BLoC
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final CheckRequiredPermissions checkPermissions;
  final RequestRequiredPermissions requestPermissions;

  PermissionBloc({
    required this.checkPermissions,
    required this.requestPermissions,
  }) : super(PermissionInitial()) {
    on<CheckPermissionsEvent>(_onCheckPermissions);
    on<RequestPermissionsEvent>(_onRequestPermissions);
  }

  Future<void> _onCheckPermissions(
    CheckPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionChecking());

    final result = await checkPermissions();
    result.fold(
      (failure) => emit(PermissionDenied(failure.message)),
      (granted) => granted
        ? emit(PermissionGranted())
        : emit(const PermissionDenied('Required permissions not granted')),
    );
  }

  Future<void> _onRequestPermissions(
    RequestPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionRequesting());

    final result = await requestPermissions();
    result.fold(
      (failure) => emit(PermissionDenied(failure.message)),
      (granted) => granted
        ? emit(PermissionGranted())
        : emit(const PermissionDenied('User denied required permissions')),
    );
  }
}
