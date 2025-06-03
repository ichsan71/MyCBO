part of 'monthly_approval_bloc.dart';

abstract class MonthlyApprovalState extends Equatable {
  const MonthlyApprovalState();

  @override
  List<Object?> get props => [];
}

class MonthlyApprovalInitial extends MonthlyApprovalState {}

class MonthlyApprovalLoading extends MonthlyApprovalState {}

class MonthlyApprovalLoaded extends MonthlyApprovalState {
  final List<MonthlyApproval> approvals;

  const MonthlyApprovalLoaded({required this.approvals});

  @override
  List<Object?> get props => [approvals];
}

class MonthlyApprovalError extends MonthlyApprovalState {
  final String message;

  const MonthlyApprovalError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MonthlyApprovalSuccess extends MonthlyApprovalState {
  final String message;

  const MonthlyApprovalSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
