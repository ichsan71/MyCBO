import 'package:equatable/equatable.dart';
import '../../domain/entities/approval.dart';
import '../../domain/entities/approval_response.dart';

abstract class ApprovalState extends Equatable {
  const ApprovalState();

  @override
  List<Object> get props => [];
}

class ApprovalInitial extends ApprovalState {}

class ApprovalLoading extends ApprovalState {}

class ApprovalsLoaded extends ApprovalState {
  final List<Approval> approvals;

  const ApprovalsLoaded({required this.approvals});

  @override
  List<Object> get props => [approvals];
}

class ApprovalsEmpty extends ApprovalState {}

class ApprovalSending extends ApprovalState {}

class ApprovalSent extends ApprovalState {
  final ApprovalResponse response;

  const ApprovalSent({required this.response});

  @override
  List<Object> get props => [response];
}

class ApprovalError extends ApprovalState {
  final String message;

  const ApprovalError({required this.message});

  @override
  List<Object> get props => [message];
}
