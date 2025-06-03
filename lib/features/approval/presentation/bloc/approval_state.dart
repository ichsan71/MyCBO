part of 'approval_bloc.dart';

abstract class ApprovalState extends Equatable {
  const ApprovalState();

  @override
  List<Object?> get props => [];
}

class ApprovalInitial extends ApprovalState {}

class ApprovalLoading extends ApprovalState {}

class ApprovalLoaded extends ApprovalState {
  final List<Approval> approvals;

  const ApprovalLoaded({required this.approvals});

  @override
  List<Object?> get props => [approvals];
}

class MonthlyApprovalLoaded extends ApprovalState {
  final List<MonthlyApproval> approvals;

  const MonthlyApprovalLoaded({required this.approvals});

  @override
  List<Object?> get props => [approvals];
}

class ApprovalError extends ApprovalState {
  final String message;

  const ApprovalError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ApprovalSuccess extends ApprovalState {
  final String message;

  const ApprovalSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}