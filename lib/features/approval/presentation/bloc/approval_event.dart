import 'package:equatable/equatable.dart';

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
