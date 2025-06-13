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
import '../../../check_in/domain/repositories/check_in_repository.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final get_schedules_usecase.GetSchedulesUseCase getSchedulesUseCase;
  final range_date_usecase.GetSchedulesByRangeDateUseCase
      getSchedulesByRangeDateUseCase;
  final ApprovalRepository approvalRepository;
  final GetEditScheduleUseCase getEditScheduleUseCase;
  final UpdateScheduleUseCase updateScheduleUseCase;
  final CheckInRepository checkInRepository;

  int _currentPage = 1;
  bool _hasMoreData = true;
  List<Schedule> _allSchedules = [];
  bool _isLoading = false;

  ScheduleBloc({
    required this.getSchedulesUseCase,
    required this.getSchedulesByRangeDateUseCase,
    required this.approvalRepository,
    required this.getEditScheduleUseCase,
    required this.updateScheduleUseCase,
    required this.checkInRepository,
  }) : super(const ScheduleInitial()) {
    on<GetSchedulesEvent>(_onGetSchedules);
    on<GetSchedulesByRangeDateEvent>(_onGetSchedulesByRangeDate);
    on<LoadMoreSchedulesEvent>(_onLoadMoreSchedules);
    on<RefreshSchedulesEvent>(_onRefreshSchedules);
    on<UpdateScheduleStatusEvent>(_onUpdateScheduleStatusEvent);
    on<FetchRejectedSchedulesEvent>(_onFetchRejectedSchedulesEvent);
    on<GetEditScheduleDataEvent>(_onGetEditScheduleDataEvent);
    on<UpdateScheduleEvent>(_onUpdateScheduleEvent);
    on<CheckInEvent>(_onCheckInEvent);
    on<CheckOutEvent>(_onCheckOutEvent);
    on<SaveCheckOutFormEvent>(_onSaveCheckOutFormEvent);
  }

  Future<void> _onGetSchedules(
    GetSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    _resetPaginationState();

    try {
      Logger.info(
          'ScheduleBloc', 'Fetching schedules for user ${event.userId}');
      final result = await getSchedulesUseCase(
        get_schedules_usecase.ScheduleParams(userId: event.userId),
      );

      await result.fold(
        (failure) async {
          Logger.error(
              'ScheduleBloc', 'Failed to fetch schedules: ${failure.message}');
          emit(ScheduleError(failure.message));
        },
        (schedules) {
          Logger.info('ScheduleBloc',
              'Successfully fetched ${schedules.length} schedules');
          _allSchedules = schedules;
          if (schedules.isEmpty) {
            emit(const ScheduleEmpty());
          } else {
            emit(ScheduleLoaded(
              schedules: schedules,
              currentPage: _currentPage,
              hasMoreData: _hasMoreData,
            ));
          }
        },
      );
    } catch (e) {
      Logger.error(
          'ScheduleBloc', 'Unexpected error during schedule fetch: $e');
      emit(ScheduleError('Terjadi kesalahan tidak terduga: ${e.toString()}'));
    }
  }

  Future<void> _onGetSchedulesByRangeDate(
    GetSchedulesByRangeDateEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    if (_isLoading) return;

    if (event.page == 1) {
      emit(const ScheduleLoading());
      _resetPaginationState();
    } else {
      emit(ScheduleLoadingMore(currentSchedules: _allSchedules));
    }

    _isLoading = true;

    final result = await getSchedulesByRangeDateUseCase(
      range_date_usecase.ScheduleByRangeDateParams(
        userId: event.userId,
        rangeDate: event.rangeDate,
        page: event.page,
      ),
    );

    _isLoading = false;

    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (schedules) {
        if (event.page == 1) {
          _allSchedules = schedules;
        } else {
          _allSchedules.addAll(schedules);
        }

        if (schedules.isEmpty) {
          _hasMoreData = false;
        }

        if (_allSchedules.isEmpty) {
          emit(const ScheduleEmpty());
        } else {
          emit(ScheduleLoaded(
            schedules: _allSchedules,
            currentPage: _currentPage,
            hasMoreData: _hasMoreData,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreSchedules(
    LoadMoreSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    if (!_hasMoreData || _isLoading) return;

    _currentPage++;
    add(GetSchedulesByRangeDateEvent(
      userId: event.userId,
      rangeDate: event.rangeDate,
      page: _currentPage,
    ));
  }

  Future<void> _onRefreshSchedules(
    RefreshSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    _resetPaginationState();
    add(GetSchedulesEvent(userId: event.userId));
  }

  void _resetPaginationState() {
    _currentPage = 1;
    _hasMoreData = true;
    _allSchedules = [];
    _isLoading = false;
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

        emit(ScheduleLoaded(schedules: updatedSchedules));

        // Tambahkan penanganan error saat fetch schedules
        try {
          await _fetchSchedules(event.userId, emit);
        } catch (e) {
          // Jika terjadi error saat fetch, tetap gunakan data yang sudah diupdate
          emit(ScheduleLoaded(schedules: updatedSchedules));
        }
      } catch (e) {
        // Jika terjadi error, log dan jangan ubah state
        Logger.error('ScheduleBloc', 'Error updating schedule status: $e');
      }
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

  Future<void> _onCheckInEvent(
    CheckInEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      Logger.info('ScheduleBloc', 'Processing check-in request...');

      final result = await checkInRepository.checkIn(event.request);

      await result.fold(
        (failure) async {
          Logger.error('ScheduleBloc', 'Check-in failed: ${failure.message}');
          emit(ScheduleError(failure.message));
        },
        (_) async {
          Logger.success('ScheduleBloc', 'Check-in successful');

          // Emit CheckInSuccess state first
          emit(const CheckInSuccess());

          // Then refresh schedules
          try {
            final scheduleResult = await getSchedulesUseCase(
              get_schedules_usecase.ScheduleParams(
                  userId: event.request.userId),
            );

            scheduleResult.fold(
              (failure) {
                Logger.error('ScheduleBloc',
                    'Failed to refresh schedules after check-in: ${failure.message}');
                // Even if refresh fails, we still want to show success
                emit(const CheckInSuccess());
              },
              (schedules) {
                Logger.info('ScheduleBloc',
                    'Schedules refreshed successfully after check-in');
                emit(ScheduleLoaded(schedules: schedules));
              },
            );
          } catch (e) {
            Logger.error('ScheduleBloc',
                'Error refreshing schedules after check-in: $e');
            // Even if refresh fails, we still want to show success
            emit(const CheckInSuccess());
          }
        },
      );
    } catch (e) {
      Logger.error('ScheduleBloc', 'Unexpected error during check-in: $e');
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onCheckOutEvent(
    CheckOutEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleLoading());
      Logger.info('ScheduleBloc', 'Processing check-out request...');

      final result = await checkInRepository.checkOut(event.request);

      await result.fold(
        (failure) async {
          Logger.error('ScheduleBloc', 'Check-out failed: ${failure.message}');
          emit(ScheduleError(failure.message));
        },
        (_) async {
          Logger.success('ScheduleBloc', 'Check-out successful');

          // Refresh schedules after successful check-out
          try {
            final scheduleResult = await getSchedulesUseCase(
              get_schedules_usecase.ScheduleParams(userId: event.userId),
            );

            scheduleResult.fold(
              (failure) {
                Logger.error('ScheduleBloc',
                    'Failed to refresh schedules after check-out: ${failure.message}');
                // Even if refresh fails, we still want to show success
                emit(const CheckOutSuccess());
              },
              (schedules) {
                Logger.info('ScheduleBloc',
                    'Schedules refreshed successfully after check-out');
                emit(ScheduleLoaded(schedules: schedules));
              },
            );
          } catch (e) {
            Logger.error('ScheduleBloc',
                'Error refreshing schedules after check-out: $e');
            // Even if refresh fails, we still want to show success
            emit(const CheckOutSuccess());
          }
        },
      );
    } catch (e) {
      Logger.error('ScheduleBloc', 'Unexpected error during check-out: $e');
      emit(ScheduleError(e.toString()));
    }
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
          final rejectedResult =
              await approvalRepository.getRejectedSchedules(userId);
          List<RejectedSchedule> rejectedSchedules = [];
          rejectedResult.fold(
            (failure) {
              Logger.error('ScheduleBloc',
                  'Error fetching rejected schedules: ${failure.message}');
            },
            (schedules) {
              rejectedSchedules = schedules;
            },
          );

          // Mapping RejectedSchedule ke Schedule dengan penanganan null
          final rejectedMapped = rejectedSchedules
              .map((r) => Schedule(
                    id: r.id ?? 0,
                    namaUser: r.namaUser ?? '',
                    tipeSchedule: r.tipeSchedule ?? '',
                    tujuan: r.tujuan ?? '',
                    idTujuan: 0,
                    tglVisit: r.tglVisit ?? '',
                    statusCheckin: r.statusCheckin ?? '',
                    shift: r.shift ?? '',
                    note: r.note ?? '',
                    product: '[]',
                    draft: r.draft ?? '',
                    statusDraft: '',
                    alasanReject: '',
                    namaTujuan: r.namaTujuan ?? '',
                    namaSpesialis: r.namaSpesialis ?? '',
                    namaProduct: r.namaProduct ?? '',
                    namaDivisi: r.namaDivisi ?? '',
                    approved: r.approved ?? 0,
                    namaApprover: r.namaRejecter ?? '',
                    realisasiApprove: null,
                    idUser: 0,
                    productForIdDivisi: [],
                    productForIdSpesialis: [],
                    jenis: r.jenis ?? '',
                    approvedBy: null,
                    rejectedBy: null,
                    realisasiVisitApproved: null,
                    createdAt: r.createdAt ?? '',
                  ))
              .toList();

          // Gabungkan dan hilangkan duplikasi berdasarkan id
          final allSchedules = <int, Schedule>{};
          for (var s in schedules) {
            allSchedules[s.id] = s;
          }
          for (var s in rejectedMapped) {
            allSchedules[s.id] = s;
          }
          final combined = allSchedules.values.toList();

          // Sort schedules by date (newest first)
          combined.sort((a, b) => b.tglVisit.compareTo(a.tglVisit));

          if (combined.isEmpty) {
            emit(const ScheduleEmpty());
          } else {
            emit(ScheduleLoaded(schedules: combined));
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error(
          'ScheduleBloc', 'Unexpected error: $e\nStack trace: $stackTrace');
      emit(ScheduleError('Kesalahan tidak terduga: $e'));
    }
  }

  Future<void> _onFetchRejectedSchedulesEvent(
    FetchRejectedSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    try {
      final result =
          await approvalRepository.getRejectedSchedules(event.userId);
      result.fold(
        (failure) => emit(ScheduleError(_mapFailureToMessage(failure))),
        (rejectedSchedules) {
          if (rejectedSchedules.isEmpty) {
            emit(const ScheduleEmpty());
          } else {
            emit(RejectedSchedulesLoaded(rejectedSchedules));
          }
        },
      );
    } catch (e) {
      emit(ScheduleError('Gagal memuat jadwal yang ditolak: $e'));
    }
  }

  void _onSaveCheckOutFormEvent(
    SaveCheckOutFormEvent event,
    Emitter<ScheduleState> emit,
  ) {
    Logger.info('ScheduleBloc', 'Saving check-out form data...');
    emit(CheckOutFormData(
      imagePath: event.imagePath,
      imageTimestamp: event.imageTimestamp,
      note: event.note,
      status: event.status,
      scheduleId: event.scheduleId,
    ));
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
