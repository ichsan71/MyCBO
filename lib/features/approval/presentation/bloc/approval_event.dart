part of 'approval_bloc.dart';

abstract class ApprovalEvent extends Equatable {
  const ApprovalEvent();

  @override
  List<Object> get props => [];
}

class GetApprovalsEvent extends ApprovalEvent {
  final int userId;

  const GetApprovalsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class FilterApprovalsEvent extends ApprovalEvent {
  final ApprovalFilter filter;

  const FilterApprovalsEvent({required this.filter});

  @override
  List<Object> get props => [filter];
}

class ApproveDetailEvent extends ApprovalEvent {
  final int scheduleId;
  final int userId;
  final String notes;

  const ApproveDetailEvent({
    required this.scheduleId,
    required this.userId,
    required this.notes,
  });

  @override
  List<Object> get props => [scheduleId, userId, notes];
}

class RejectDetailEvent extends ApprovalEvent {
  final int scheduleId;
  final int userId;
  final String notes;

  const RejectDetailEvent({
    required this.scheduleId,
    required this.userId,
    required this.notes,
  });

  @override
  List<Object> get props => [scheduleId, userId, notes];
}

class ApproveRequestEvent extends ApprovalEvent {
  final int approvalId;
  final int userId;
  final String notes;

  const ApproveRequestEvent({
    required this.approvalId,
    required this.userId,
    required this.notes,
  });

  @override
  List<Object> get props => [approvalId, userId, notes];
}

class RejectRequestEvent extends ApprovalEvent {
  final String idSchedule;
  final String idRejecter;
  final String comment;

  const RejectRequestEvent({
    required this.idSchedule,
    required this.idRejecter,
    required this.comment,
  });

  @override
  List<Object> get props => [idSchedule, idRejecter, comment];
}

class SendApprovalEvent extends ApprovalEvent {
  final int scheduleId;
  final int userId;
  final bool isApproved;

  const SendApprovalEvent({
    required this.scheduleId,
    required this.userId,
    required this.isApproved,
  });

  @override
  List<Object> get props => [scheduleId, userId, isApproved];
}
