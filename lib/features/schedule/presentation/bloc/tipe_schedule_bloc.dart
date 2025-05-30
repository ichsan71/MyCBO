import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/tipe_schedule.dart';
import '../../domain/usecases/get_tipe_schedules.dart';
import 'package:flutter/foundation.dart';

part 'tipe_schedule_event.dart';
part 'tipe_schedule_state.dart';

class TipeScheduleBloc extends Bloc<TipeScheduleEvent, TipeScheduleState> {
  final GetTipeSchedules getTipeSchedules;

  TipeScheduleBloc({required this.getTipeSchedules})
      : super(TipeScheduleInitial()) {
    on<GetTipeSchedulesEvent>(_onGetTipeSchedules);
  }

  Future<void> _onGetTipeSchedules(
    GetTipeSchedulesEvent event,
    Emitter<TipeScheduleState> emit,
  ) async {
    emit(TipeScheduleLoading());

    if (kDebugMode) {
      print('🔍 [TIPE SCHEDULE BLOC] Memuat data tipe jadwal...');
    }

    final result = await getTipeSchedules(NoParams());

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('🔍 [TIPE SCHEDULE BLOC] Gagal memuat: ${failure.message}');
        }
        emit(TipeScheduleError(message: _mapFailureToMessage(failure)));
      },
      (tipeSchedules) {
        if (kDebugMode) {
          print(
              '🔍 [TIPE SCHEDULE BLOC] Berhasil memuat ${tipeSchedules.length} tipe jadwal:');
          for (var tipe in tipeSchedules) {
            print(
                '🔍 [TIPE SCHEDULE BLOC] - ID: ${tipe.id}, Nama: ${tipe.nameTipeSchedule}');
          }
        }
        emit(TipeScheduleLoaded(tipeSchedules: tipeSchedules));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
      case ConnectionFailure:
        return 'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }
}
