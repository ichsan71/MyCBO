import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_edit_schedule_data.dart';
import 'edit_schedule_event.dart';
import 'edit_schedule_state.dart';

class EditScheduleBloc extends Bloc<EditScheduleEvent, EditScheduleState> {
  final GetEditScheduleData getEditScheduleData;

  EditScheduleBloc({
    required this.getEditScheduleData,
  }) : super(EditScheduleInitial()) {
    on<LoadEditScheduleData>(_onLoadEditScheduleData);
    on<SaveEditedSchedule>(_onSaveEditedSchedule);
  }

  Future<void> _onLoadEditScheduleData(
    LoadEditScheduleData event,
    Emitter<EditScheduleState> emit,
  ) async {
    try {
      emit(EditScheduleLoading());
      Logger.info('EditScheduleBloc', 'Loading edit schedule data...');

      final result =
          await getEditScheduleData(Params(scheduleId: event.scheduleId));

      await result.fold(
        (failure) async {
          Logger.error('EditScheduleBloc', 'Error: ${failure.toString()}');
          emit(EditScheduleError(failure.toString()));
        },
        (data) async {
          Logger.info('EditScheduleBloc', 'Data loaded successfully');
          emit(EditScheduleDataLoaded(data));
        },
      );
    } catch (e) {
      Logger.error('EditScheduleBloc', 'Unexpected error: $e');
      emit(EditScheduleError(e.toString()));
    }
  }

  Future<void> _onSaveEditedSchedule(
    SaveEditedSchedule event,
    Emitter<EditScheduleState> emit,
  ) async {
    try {
      emit(EditScheduleSaving());
      Logger.info('EditScheduleBloc', 'Saving edited schedule...');

      // TODO: Implement save functionality
      // final result = await saveEditedSchedule(event.schedule);

      emit(EditScheduleSaveSuccess());
    } catch (e) {
      Logger.error('EditScheduleBloc', 'Error saving schedule: $e');
      emit(EditScheduleError(e.toString()));
    }
  }
}
