import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'dart:developer' as developer;
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
    // Emit loading state terlebih dahulu untuk menunjukkan proses refresh
    emit(const ScheduleLoading());

    // Kemudian fetch data
    await _fetchSchedules(event.userId, emit);
  }

  Future<void> _onUpdateScheduleStatusEvent(
    UpdateScheduleStatusEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is ScheduleLoaded) {
      developer.log(
        'Memproses UpdateScheduleStatusEvent',
        name: 'ScheduleBloc',
      );
      developer.log(
        'Schedule ID: ${event.scheduleId}, New Status: ${event.newStatus}',
        name: 'ScheduleBloc',
      );

      final updatedSchedules = currentState.schedules.map((schedule) {
        if (schedule.id == event.scheduleId) {
          developer.log(
            'Mengupdate status jadwal ${schedule.id} dari "${schedule.statusCheckin}" ke "${event.newStatus}"',
            name: 'ScheduleBloc',
          );
          return schedule.copyWith(statusCheckin: event.newStatus);
        }
        return schedule;
      }).toList();

      emit(ScheduleLoaded(updatedSchedules));

      // Refresh jadwal dari server
      await _fetchSchedules(event.userId, emit);
    } else {
      developer.log(
        'Tidak dapat memproses UpdateScheduleStatusEvent: State bukan ScheduleLoaded',
        name: 'ScheduleBloc',
      );
    }
  }

  Future<void> _fetchSchedules(int userId, Emitter<ScheduleState> emit) async {
    Logger.info('ScheduleBloc', 'MULAI MENGAMBIL DATA JADWAL');
    Logger.info('ScheduleBloc', 'Request jadwal untuk user ID: $userId');

    try {
      final result = await getSchedulesUseCase(
        ScheduleParams(userId: userId),
      );

      result.fold(
        (failure) {
          // Ekstrak pesan error yang sesuai dari jenis failure
          String errorMessage = _mapFailureToMessage(failure);
          Logger.error('ScheduleBloc', 'ERROR: Gagal mengambil data jadwal');
          Logger.error('ScheduleBloc', 'Detail error: $errorMessage');
          Logger.info('ScheduleBloc', 'AKHIR PENGAMBILAN DATA JADWAL (GAGAL)');
          emit(ScheduleError(errorMessage));
        },
        (schedules) {
          if (schedules.isEmpty) {
            Logger.info('ScheduleBloc',
                'Berhasil mengambil data jadwal, tetapi data kosong');
            Logger.info(
                'ScheduleBloc', 'AKHIR PENGAMBILAN DATA JADWAL (KOSONG)');
            emit(const ScheduleEmpty());
          } else {
            Logger.info('ScheduleBloc',
                'BERHASIL mengambil data jadwal: ${schedules.length} item');
            Logger.info('ScheduleBloc', 'DETAIL DATA JADWAL');
            for (var i = 0; i < schedules.length; i++) {
              Logger.info('ScheduleBloc', 'Jadwal #${i + 1}:');
              Logger.info('ScheduleBloc',
                  '  - Nama Tujuan: ${schedules[i].namaTujuan}');
              Logger.info(
                  'ScheduleBloc', '  - Tanggal: ${schedules[i].tglVisit}');
              Logger.info('ScheduleBloc', '  - Shift: ${schedules[i].shift}');
              Logger.info(
                  'ScheduleBloc', '  - Tipe: ${schedules[i].tipeSchedule}');
              Logger.info(
                  'ScheduleBloc', '  - Status: ${schedules[i].statusCheckin}');
              Logger.info('ScheduleBloc', '  - Draft: ${schedules[i].draft}');
              Logger.info(
                  'ScheduleBloc', '  - Approved: ${schedules[i].approved}');
              Logger.info('ScheduleBloc',
                  '  - Nama Approver: ${schedules[i].namaApprover}');
            }
            Logger.info('ScheduleBloc', 'AKHIR DETAIL DATA JADWAL');
            Logger.info(
                'ScheduleBloc', 'AKHIR PENGAMBILAN DATA JADWAL (SUKSES)');
            emit(ScheduleLoaded(schedules));
          }
        },
      );
    } catch (e) {
      Logger.error('ScheduleBloc', 'ERROR TIDAK TERTANGANI: $e');
      emit(ScheduleError('Kesalahan tidak terduga: $e'));
    }
  }

  // Fungsi helper untuk mengubah failure menjadi pesan error
  String _mapFailureToMessage(Failure failure) {
    Logger.error(
        'ScheduleBloc', 'Mapping failure type: ${failure.runtimeType}');
    Logger.error('ScheduleBloc', 'Failure details: $failure');

    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        Logger.error('ScheduleBloc',
            'Server failure message: "${serverFailure.message}"');

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
