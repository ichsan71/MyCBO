import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedulesUseCase getSchedulesUseCase;

  ScheduleBloc({
    required this.getSchedulesUseCase,
  }) : super(const ScheduleInitial()) {
    on<GetSchedulesEvent>(_onGetSchedulesEvent);
    on<RefreshSchedulesEvent>(_onRefreshSchedulesEvent);
    on<UpdateScheduleStatusEvent>(_onUpdateScheduleStatusEvent);
  }

  Future<void> _onGetSchedulesEvent(
    GetSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    await _fetchSchedules(event.userId, emit);
  }

  Future<void> _onRefreshSchedulesEvent(
    RefreshSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    await _fetchSchedules(event.userId, emit);
  }

  Future<void> _onUpdateScheduleStatusEvent(
    UpdateScheduleStatusEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is ScheduleLoaded) {
      try {
        final updatedSchedules = currentState.schedules.map((schedule) {
          if (schedule.id == event.scheduleId) {
            return schedule.copyWith(statusCheckin: event.newStatus);
          }
          return schedule;
        }).toList();

        emit(ScheduleLoaded(updatedSchedules));

        // Tambahkan penanganan error saat fetch schedules
        try {
          await _fetchSchedules(event.userId, emit);
        } catch (e) {
          // Jika terjadi error saat fetch, tetap gunakan data yang sudah diupdate
          emit(ScheduleLoaded(updatedSchedules));
        }
      } catch (e) {
        // Jika terjadi error, log dan jangan ubah state
        print('Error updating schedule status: $e');
      }
    }
  }

  Future<void> _fetchSchedules(int userId, Emitter<ScheduleState> emit) async {
    try {
      final result = await getSchedulesUseCase(
        ScheduleParams(userId: userId),
      );

      result.fold(
        (failure) => emit(ScheduleError(_mapFailureToMessage(failure))),
        (schedules) {
          if (schedules.isEmpty) {
            emit(const ScheduleEmpty());
          } else {
            emit(ScheduleLoaded(schedules));
          }
        },
      );
    } catch (e) {
      emit(ScheduleError('Kesalahan tidak terduga: $e'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        if (serverFailure.message.isEmpty) {
          return 'Terjadi kesalahan pada server. Silakan coba lagi.';
        }
        if (serverFailure.message.contains('Instance of')) {
          return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
        }
        return serverFailure.message;
      case NetworkFailure:
        return 'Tidak ada koneksi internet. Silakan periksa koneksi anda dan coba lagi.';
      default:
        return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
    }
  }
}
