import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';

abstract class EditScheduleEvent extends Equatable {
  const EditScheduleEvent();

  @override
  List<Object> get props => [];
}

class LoadEditScheduleData extends EditScheduleEvent {
  final int scheduleId;

  const LoadEditScheduleData(this.scheduleId);

  @override
  List<Object> get props => [scheduleId];
}

class SaveEditedSchedule extends EditScheduleEvent {
  final Schedule schedule;

  const SaveEditedSchedule(this.schedule);

  @override
  List<Object> get props => [schedule];
}
