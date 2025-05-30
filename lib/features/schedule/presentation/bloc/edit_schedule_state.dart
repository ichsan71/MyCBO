import 'package:equatable/equatable.dart';
import '../../data/models/edit/edit_schedule_response_model.dart';

abstract class EditScheduleState extends Equatable {
  const EditScheduleState();

  @override
  List<Object?> get props => [];
}

class EditScheduleInitial extends EditScheduleState {}

class EditScheduleLoading extends EditScheduleState {}

class EditScheduleDataLoaded extends EditScheduleState {
  final EditScheduleResponseModel data;

  const EditScheduleDataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class EditScheduleSaving extends EditScheduleState {}

class EditScheduleSaveSuccess extends EditScheduleState {}

class EditScheduleError extends EditScheduleState {
  final String message;

  const EditScheduleError(this.message);

  @override
  List<Object> get props => [message];
}
