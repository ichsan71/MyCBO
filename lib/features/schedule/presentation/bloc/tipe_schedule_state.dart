part of 'tipe_schedule_bloc.dart';

abstract class TipeScheduleState extends Equatable {
  const TipeScheduleState();

  @override
  List<Object> get props => [];
}

class TipeScheduleInitial extends TipeScheduleState {}

class TipeScheduleLoading extends TipeScheduleState {}

class TipeScheduleLoaded extends TipeScheduleState {
  final List<TipeSchedule> tipeSchedules;

  const TipeScheduleLoaded({required this.tipeSchedules});

  @override
  List<Object> get props => [tipeSchedules];
}

class TipeScheduleError extends TipeScheduleState {
  final String message;

  const TipeScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}
