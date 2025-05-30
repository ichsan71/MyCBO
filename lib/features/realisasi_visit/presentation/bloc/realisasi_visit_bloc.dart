import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../../domain/entities/realisasi_visit_gm.dart';
import '../../domain/entities/realisasi_visit_response.dart';
import '../../domain/usecases/approve_realisasi_visit_gm_usecase.dart';
import '../../domain/usecases/approve_realisasi_visit_usecase.dart';
import '../../domain/usecases/get_realisasi_visits_gm_usecase.dart';
import '../../domain/usecases/get_realisasi_visits_usecase.dart';
import '../../domain/usecases/reject_realisasi_visit_usecase.dart';

part 'realisasi_visit_event.dart';
part 'realisasi_visit_state.dart';

class RealisasiVisitBloc
    extends Bloc<RealisasiVisitEvent, RealisasiVisitState> {
  final GetRealisasiVisitsUseCase getRealisasiVisits;
  final GetRealisasiVisitsGMUseCase getRealisasiVisitsGM;
  final ApproveRealisasiVisitUseCase approveRealisasiVisit;
  final ApproveRealisasiVisitGMUseCase approveRealisasiVisitGM;
  final RejectRealisasiVisitUseCase rejectRealisasiVisit;

  RealisasiVisitBloc({
    required this.getRealisasiVisits,
    required this.getRealisasiVisitsGM,
    required this.approveRealisasiVisit,
    required this.approveRealisasiVisitGM,
    required this.rejectRealisasiVisit,
  }) : super(RealisasiVisitInitial()) {
    on<GetRealisasiVisitsEvent>(_onGetRealisasiVisits);
    on<GetRealisasiVisitsGMEvent>(_onGetRealisasiVisitsGM);
    on<ApproveRealisasiVisitEvent>(_onApproveRealisasiVisit);
    on<ApproveRealisasiVisitGMEvent>(_onApproveRealisasiVisitGM);
    on<RejectRealisasiVisitEvent>(_onRejectRealisasiVisit);
  }

  Future<void> _onGetRealisasiVisits(
    GetRealisasiVisitsEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitLoading());
    final result = await getRealisasiVisits(
      GetRealisasiVisitsParams(idAtasan: event.idAtasan),
    );
    result.fold(
      (failure) =>
          emit(RealisasiVisitError(message: _mapFailureToMessage(failure))),
      (realisasiVisits) =>
          emit(RealisasiVisitLoaded(realisasiVisits: realisasiVisits)),
    );
  }

  Future<void> _onGetRealisasiVisitsGM(
    GetRealisasiVisitsGMEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitLoading());
    final result = await getRealisasiVisitsGM(
      GetRealisasiVisitsGMParams(idAtasan: event.idAtasan),
    );
    result.fold(
      (failure) =>
          emit(RealisasiVisitError(message: _mapFailureToMessage(failure))),
      (realisasiVisitsGM) =>
          emit(RealisasiVisitGMLoaded(realisasiVisitsGM: realisasiVisitsGM)),
    );
  }

  Future<void> _onApproveRealisasiVisit(
    ApproveRealisasiVisitEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitProcessing());
    final result = await approveRealisasiVisit(
      ApproveRealisasiVisitParams(
        idAtasan: event.idAtasan,
        idSchedule: event.idSchedule,
      ),
    );
    result.fold(
      (failure) =>
          emit(RealisasiVisitError(message: _mapFailureToMessage(failure))),
      (response) => emit(RealisasiVisitApproved(response: response)),
    );
  }

  Future<void> _onApproveRealisasiVisitGM(
    ApproveRealisasiVisitGMEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitProcessing());
    final result = await approveRealisasiVisitGM(
      ApproveRealisasiVisitGMParams(
        idAtasan: event.idAtasan,
        idSchedule: event.idSchedule,
      ),
    );
    result.fold(
      (failure) =>
          emit(RealisasiVisitError(message: _mapFailureToMessage(failure))),
      (response) => emit(RealisasiVisitApproved(response: response)),
    );
  }

  Future<void> _onRejectRealisasiVisit(
    RejectRealisasiVisitEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitProcessing());
    final result = await rejectRealisasiVisit(
      RejectRealisasiVisitParams(
        idAtasan: event.idAtasan,
        idSchedule: event.idSchedule,
      ),
    );
    result.fold(
      (failure) =>
          emit(RealisasiVisitError(message: _mapFailureToMessage(failure))),
      (response) => emit(RealisasiVisitRejected(response: response)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case NetworkFailure:
        return 'Tidak dapat terhubung ke server. Cek koneksi internet Anda.';
      case AuthenticationFailure:
        return (failure as AuthenticationFailure).message;
      default:
        return 'Terjadi kesalahan yang tidak terduga';
    }
  }
}
