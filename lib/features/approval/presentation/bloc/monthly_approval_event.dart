part of 'monthly_approval_bloc.dart';

abstract class MonthlyApprovalEvent extends Equatable {
  const MonthlyApprovalEvent();

  @override
  List<Object?> get props => [];
}

class GetMonthlyApprovals extends MonthlyApprovalEvent {
  final int userId;

  const GetMonthlyApprovals({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SendMonthlyApproval extends MonthlyApprovalEvent {
  final List<int> scheduleIds;
  final List<String> scheduleJoinVisitIds;
  final int userId;
  final int userAtasanId;
  final bool isRejected;
  final String? comment;

  const SendMonthlyApproval({
    required this.scheduleIds,
    required this.scheduleJoinVisitIds,
    required this.userId,
    required this.userAtasanId,
    this.isRejected = false,
    this.comment,
  });

  @override
  List<Object?> get props => [
        scheduleIds,
        scheduleJoinVisitIds,
        userId,
        userAtasanId,
        isRejected,
        comment,
      ];
}
