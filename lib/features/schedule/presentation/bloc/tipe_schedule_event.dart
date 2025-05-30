part of 'tipe_schedule_bloc.dart';

abstract class TipeScheduleEvent extends Equatable {
  const TipeScheduleEvent();

  @override
  List<Object> get props => [];
}

class GetTipeSchedulesEvent extends TipeScheduleEvent {
  const GetTipeSchedulesEvent();
}
