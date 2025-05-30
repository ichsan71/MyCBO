import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_schedules_usecase.dart'
    as get_schedules_usecase;
import 'schedule_event.dart';
import 'schedule_state.dart';
import '../../../approval/domain/repositories/approval_repository.dart';
import '../../../approval/data/datasources/approval_remote_data_source.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/usecases/get_schedules_by_range_date_usecase.dart'
    as range_date_usecase;
import '../../domain/usecases/get_edit_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import '../../data/models/edit_schedule_data_model.dart';
import '../../data/models/update_schedule_request_model.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import '../../domain/usecases/get_schedules_by_range_date_usecase.dart';
import '../../domain/usecases/get_schedules_by_range_date_usecase.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import '../../domain/usecases/get_schedules_by_range_date_usecase.dart';
import 'package:test_cbo/core/utils/logger.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final get_schedules_usecase.GetSchedulesUseCase getSchedulesUseCase;
  final range_date_usecase.GetSchedulesByRangeDateUseCase
      getSchedulesByRangeDateUseCase;
  final ApprovalRepository approvalRepository;
  final GetEditScheduleUseCase getEditScheduleUseCase;
  final UpdateScheduleUseCase updateScheduleUseCase;

  ScheduleBloc({
    required this.getSchedulesUseCase,
    required this.getSchedulesByRangeDateUseCase,
    required this.approvalRepository,
    required this.getEditScheduleUseCase,
    required this.updateScheduleUseCase,
  }) : super(const ScheduleInitial()) {
    on<GetSchedulesEvent>(_onGetSchedulesEvent);
    on<RefreshSchedulesEvent>(_onRefreshSchedulesEvent);
    on<UpdateScheduleStatusEvent>(_onUpdateScheduleStatusEvent);
    on<GetSchedulesByRangeDateEvent>(_onGetSchedulesByRangeDateEvent);
    on<FetchRejectedSchedulesEvent>(_onFetchRejectedSchedulesEvent);
    on<GetEditScheduleDataEvent>(_onGetEditScheduleDataEvent);
    on<UpdateScheduleEvent>(_onUpdateScheduleEvent);
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
        Logger.error('ScheduleBloc', 'Error updating schedule status: $e');
      }
    }
  }

  Future<void> _onGetSchedulesByRangeDateEvent(
    GetSchedulesByRangeDateEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    try {
      final result = await getSchedulesByRangeDateUseCase(
        range_date_usecase.ScheduleByRangeDateParams(
            userId: event.userId, rangeDate: event.rangeDate),
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

  Future<void> _onGetEditScheduleDataEvent(
    GetEditScheduleDataEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const EditScheduleLoading());
    final result = await getEditScheduleUseCase(event.scheduleId);

    result.fold(
      (failure) => emit(EditScheduleError(_mapFailureToMessage(failure))),
      (editScheduleData) => emit(EditScheduleLoaded(editScheduleData)),
    );
  }

  Future<void> _onUpdateScheduleEvent(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleUpdating());
    final result = await updateScheduleUseCase(
        UpdateScheduleParams(requestModel: event.requestModel));

    result.fold(
      (failure) => emit(ScheduleUpdateError(_mapFailureToMessage(failure))),
      (_) => emit(const ScheduleUpdated('Jadwal berhasil diperbarui')),
    );
  }

  Future<void> _fetchSchedules(int userId, Emitter<ScheduleState> emit) async {
    try {
      final result = await getSchedulesUseCase(
        get_schedules_usecase.ScheduleParams(userId: userId),
      );

      await result.fold(
        (failure) async {
          emit(ScheduleError(_mapFailureToMessage(failure)));
        },
        (schedules) async {
          // Fetch jadwal yang ditolak
          List<RejectedSchedule> rejected = [];
          try {
            rejected = await approvalRepository.getRejectedSchedules(userId);
          } catch (e) {
            // Bisa di-log jika perlu, tapi jangan gagalkan jadwal utama
          }
          // Mapping RejectedSchedule ke Schedule
          final rejectedSchedules = rejected
              .map((r) => Schedule(
                    id: r.id,
                    namaUser: r.namaUser,
                    tipeSchedule: r.tipeSchedule,
                    tujuan: r.tujuan,
                    idTujuan: 0,
                    tglVisit: r.tglVisit,
                    statusCheckin: r.statusCheckin,
                    shift: r.shift,
                    note: r.note,
                    product: '[]',
                    draft: r.draft,
                    statusDraft: '',
                    alasanReject: '',
                    namaTujuan: r.namaTujuan,
                    namaSpesialis: r.namaSpesialis,
                    namaProduct: r.namaProduct,
                    namaDivisi: r.namaDivisi,
                    approved: r.approved,
                    namaApprover: r.namaRejecter,
                    realisasiApprove: null,
                    idUser: 0,
                    productForIdDivisi: [],
                    productForIdSpesialis: [],
                    jenis: r.jenis,
                    approvedBy: null,
                    rejectedBy: null,
                    realisasiVisitApproved: null,
                    createdAt: r.createdAt,
                  ))
              .toList();
          // Gabungkan dan hilangkan duplikasi berdasarkan id
          final allSchedules = <int, Schedule>{};
          for (var s in schedules) {
            allSchedules[s.id] = s;
          }
          for (var s in rejectedSchedules) {
            allSchedules[s.id] = s;
          }
          final combined = allSchedules.values.toList();
          if (combined.isEmpty) {
            emit(const ScheduleEmpty());
          } else {
            emit(ScheduleLoaded(combined));
          }
        },
      );
    } catch (e) {
      emit(ScheduleError('Kesalahan tidak terduga: $e'));
    }
  }

  Future<void> _onFetchRejectedSchedulesEvent(
    FetchRejectedSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    try {
      final rejectedSchedules =
          await approvalRepository.getRejectedSchedules(event.userId);
      emit(RejectedSchedulesLoaded(rejectedSchedules));
    } catch (e) {
      emit(ScheduleError('Gagal memuat jadwal yang ditolak: $e'));
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
