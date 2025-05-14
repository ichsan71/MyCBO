import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class GetSchedulesEvent extends ScheduleEvent {
  final int userId;

  const GetSchedulesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshSchedulesEvent extends ScheduleEvent {
  final int userId;

  const RefreshSchedulesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateScheduleStatusEvent extends ScheduleEvent {
  final int scheduleId;
  final String newStatus;
  final int userId;

  const UpdateScheduleStatusEvent({
    required this.scheduleId,
    required this.newStatus,
    required this.userId,
  });

  @override
  List<Object?> get props => [scheduleId, newStatus, userId];
}
