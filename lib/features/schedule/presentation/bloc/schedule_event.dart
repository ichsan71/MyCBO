import 'package:equatable/equatable.dart';
import '../../data/models/update_schedule_request_model.dart';
import '../../data/models/checkin_request_model.dart';
import '../../data/models/checkout_request_model.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class GetSchedulesEvent extends ScheduleEvent {
  final int userId;
  final int page;

  const GetSchedulesEvent({required this.userId, this.page = 1});

  @override
  List<Object?> get props => [userId, page];
}

class RefreshSchedulesEvent extends ScheduleEvent {
  final int userId;
  final String rangeDate;

  const RefreshSchedulesEvent({
    required this.userId,
    this.rangeDate = '',
  });

  @override
  List<Object?> get props => [userId, rangeDate];
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
  final int page;

  const GetSchedulesByRangeDateEvent({
    required this.userId,
    required this.rangeDate,
    this.page = 1,
  });

  @override
  List<Object?> get props => [userId, rangeDate, page];
}

class LoadMoreSchedulesEvent extends ScheduleEvent {
  final int userId;
  final String rangeDate;

  const LoadMoreSchedulesEvent({
    required this.userId,
    required this.rangeDate,
  });

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

// Add check-in event
class CheckInEvent extends ScheduleEvent {
  final CheckinRequestModel request;

  const CheckInEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

// Add check-out event
class CheckOutEvent extends ScheduleEvent {
  final CheckoutRequestModel request;
  final int userId;

  const CheckOutEvent({
    required this.request,
    required this.userId,
  });

  @override
  List<Object?> get props => [request, userId];
}

class SaveCheckOutFormEvent extends ScheduleEvent {
  final String? imagePath;
  final String? imageTimestamp;
  final String note;
  final String status;
  final int scheduleId;

  const SaveCheckOutFormEvent({
    this.imagePath,
    this.imageTimestamp,
    required this.note,
    required this.status,
    required this.scheduleId,
  });

  @override
  List<Object?> get props =>
      [imagePath, imageTimestamp, note, status, scheduleId];
}
