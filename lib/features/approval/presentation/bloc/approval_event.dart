part of 'approval_bloc.dart';

abstract class ApprovalEvent extends Equatable {
  const ApprovalEvent();

  @override
  List<Object?> get props => [];
}

class GetApprovals extends ApprovalEvent {
  final int userId;

  const GetApprovals({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetMonthlyApprovals extends ApprovalEvent {
  final int userId;

  const GetMonthlyApprovals({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FilterApprovals extends ApprovalEvent {
  final String searchQuery;
  final int? month;
  final int? year;
  final int? status;
  final int userId;

  const FilterApprovals({
    required this.searchQuery,
    this.month,
    this.year,
    this.status,
    required this.userId,
  });

  @override
  List<Object?> get props => [searchQuery, month, year, status, userId];
}

class ApproveRequest extends ApprovalEvent {
  final int approvalId;
  final String notes;
  final BuildContext context;

  const ApproveRequest({
    required this.approvalId,
    required this.notes,
    required this.context,
  });

  @override
  List<Object?> get props => [approvalId, notes, context];
}

class RejectRequest extends ApprovalEvent {
  final String idSchedule;
  final String idRejecter;
  final String comment;
  final BuildContext context;

  const RejectRequest({
    required this.idSchedule,
    required this.idRejecter,
    required this.comment,
    required this.context,
  });

  @override
  List<Object?> get props => [idSchedule, idRejecter, comment, context];
}

class SendApproval extends ApprovalEvent {
  final int scheduleId;
  final int userId;
  final bool isApproved;
  final String? joinScheduleId;

  const SendApproval({
    required this.scheduleId,
    required this.userId,
    required this.isApproved,
    this.joinScheduleId,
  });

  @override
  List<Object?> get props => [scheduleId, userId, isApproved, joinScheduleId];
}

class BatchApproveRequest extends ApprovalEvent {
  final List<int> scheduleIds;
  final String notes;
  final BuildContext context;

  const BatchApproveRequest({
    required this.scheduleIds,
    required this.notes,
    required this.context,
  });

  @override
  List<Object?> get props => [scheduleIds, notes, context];
}
