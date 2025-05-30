import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';
import '../../data/models/edit_schedule_data_model.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final List<Schedule> schedules;

  const ScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleEmpty extends ScheduleState {
  const ScheduleEmpty();
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

class RejectedSchedulesLoaded extends ScheduleState {
  final List schedules; // List<RejectedSchedule>

  const RejectedSchedulesLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class EditScheduleLoading extends ScheduleState {
  const EditScheduleLoading();
}

class EditScheduleLoaded extends ScheduleState {
  final EditScheduleDataModel editScheduleData;

  const EditScheduleLoaded(this.editScheduleData);

  @override
  List<Object?> get props => [editScheduleData];
}

class EditScheduleError extends ScheduleState {
  final String message;

  const EditScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

// New states for updating a schedule
class ScheduleUpdating extends ScheduleState {
  const ScheduleUpdating();
}

class ScheduleUpdated extends ScheduleState {
  final String message;

  const ScheduleUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduleUpdateError extends ScheduleState {
  final String message;

  const ScheduleUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}
