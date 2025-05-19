import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../../domain/entities/realisasi_visit_response.dart';
import '../../domain/usecases/approve_realisasi_visit_usecase.dart';
import '../../domain/usecases/get_realisasi_visits_usecase.dart';
import '../../domain/usecases/reject_realisasi_visit_usecase.dart';

part 'realisasi_visit_event.dart';
part 'realisasi_visit_state.dart';

class RealisasiVisitBloc
    extends Bloc<RealisasiVisitEvent, RealisasiVisitState> {
  final GetRealisasiVisitsUseCase getRealisasiVisits;
  final ApproveRealisasiVisitUseCase approveRealisasiVisit;
  final RejectRealisasiVisitUseCase rejectRealisasiVisit;

  RealisasiVisitBloc({
    required this.getRealisasiVisits,
    required this.approveRealisasiVisit,
    required this.rejectRealisasiVisit,
  }) : super(RealisasiVisitInitial()) {
    on<GetRealisasiVisitsEvent>(_onGetRealisasiVisits);
    on<ApproveRealisasiVisitEvent>(_onApproveRealisasiVisit);
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
        return 'Terjadi kesalahan pada server. Silakan coba lagi.';
      case NetworkFailure:
        return 'Tidak ada koneksi internet. Silakan periksa koneksi anda dan coba lagi.';
      case AuthenticationFailure:
        return 'Sesi telah berakhir. Silakan login kembali.';
      default:
        return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
    }
  }
}
