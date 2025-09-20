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
  final int successPage;
  final int failedPage;

  const HistoryLoaded({
    required this.successPayments,
    required this.failedPayments,
    this.isLoadingMoreSuccess = false,
    this.isLoadingMoreFailed = false,
    this.hasMoreSuccess = true,
    this.hasMoreFailed = true,
    this.successPage = 0,
    this.failedPage = 0,
  });

  HistoryLoaded copyWith({
    List<Payment>? successPayments,
    List<Payment>? failedPayments,
    bool? isLoadingMoreSuccess,
    bool? isLoadingMoreFailed,
    bool? hasMoreSuccess,
    bool? hasMoreFailed,
    int? successPage,
    int? failedPage,
  }) {
    return HistoryLoaded(
      successPayments: successPayments ?? this.successPayments,
      failedPayments: failedPayments ?? this.failedPayments,
      isLoadingMoreSuccess: isLoadingMoreSuccess ?? this.isLoadingMoreSuccess,
      isLoadingMoreFailed: isLoadingMoreFailed ?? this.isLoadingMoreFailed,
      hasMoreSuccess: hasMoreSuccess ?? this.hasMoreSuccess,
      hasMoreFailed: hasMoreFailed ?? this.hasMoreFailed,
      successPage: successPage ?? this.successPage,
      failedPage: failedPage ?? this.failedPage,
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
        successPage,
        failedPage,
      ];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
