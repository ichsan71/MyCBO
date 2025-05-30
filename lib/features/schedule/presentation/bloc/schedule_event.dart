import 'package:equatable/equatable.dart';
import '../../data/models/update_schedule_request_model.dart';

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

class GetSchedulesByRangeDateEvent extends ScheduleEvent {
  final int userId;
  final String rangeDate; // format: MM/dd/yyyy - MM/dd/yyyy

  const GetSchedulesByRangeDateEvent(
      {required this.userId, required this.rangeDate});

  @override
  List<Object?> get props => [userId, rangeDate];
}

class FetchRejectedSchedulesEvent extends ScheduleEvent {
  final int userId;

  const FetchRejectedSchedulesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// New event for fetching data for editing a schedule
class GetEditScheduleDataEvent extends ScheduleEvent {
  final int scheduleId;

  const GetEditScheduleDataEvent({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}

// New event for updating a schedule
class UpdateScheduleEvent extends ScheduleEvent {
  final UpdateScheduleRequestModel requestModel;

  const UpdateScheduleEvent({required this.requestModel});

  @override
  List<Object?> get props => [requestModel];
}
