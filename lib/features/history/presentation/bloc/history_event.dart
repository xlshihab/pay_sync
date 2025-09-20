import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSuccessPayments extends HistoryEvent {}

class LoadFailedPayments extends HistoryEvent {}

class LoadMoreSuccessPayments extends HistoryEvent {}

class LoadMoreFailedPayments extends HistoryEvent {}

class RefreshPayments extends HistoryEvent {}
