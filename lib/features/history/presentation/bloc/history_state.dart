import 'package:equatable/equatable.dart';
import '../../../payments/domain/entities/payment.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Payment> successPayments;
  final List<Payment> failedPayments;
  final bool isLoadingMoreSuccess;
  final bool isLoadingMoreFailed;
  final bool hasMoreSuccess;
  final bool hasMoreFailed;

  const HistoryLoaded({
    required this.successPayments,
    required this.failedPayments,
    this.isLoadingMoreSuccess = false,
    this.isLoadingMoreFailed = false,
    this.hasMoreSuccess = true,
    this.hasMoreFailed = true,
  });

  HistoryLoaded copyWith({
    List<Payment>? successPayments,
    List<Payment>? failedPayments,
    bool? isLoadingMoreSuccess,
    bool? isLoadingMoreFailed,
    bool? hasMoreSuccess,
    bool? hasMoreFailed,
  }) {
    return HistoryLoaded(
      successPayments: successPayments ?? this.successPayments,
      failedPayments: failedPayments ?? this.failedPayments,
      isLoadingMoreSuccess: isLoadingMoreSuccess ?? this.isLoadingMoreSuccess,
      isLoadingMoreFailed: isLoadingMoreFailed ?? this.isLoadingMoreFailed,
      hasMoreSuccess: hasMoreSuccess ?? this.hasMoreSuccess,
      hasMoreFailed: hasMoreFailed ?? this.hasMoreFailed,
    );
  }

  @override
  List<Object> get props => [
        successPayments,
        failedPayments,
        isLoadingMoreSuccess,
        isLoadingMoreFailed,
        hasMoreSuccess,
        hasMoreFailed,
      ];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
