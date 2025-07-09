import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../../domain/entities/realisasi_visit_gm.dart';
import '../../domain/usecases/approve_realisasi_visit.dart';
import '../../domain/usecases/get_realisasi_visits.dart';
import '../../domain/usecases/get_realisasi_visits_gm.dart';
import '../../domain/usecases/get_realisasi_visits_gm_details.dart';
import '../../domain/usecases/reject_realisasi_visit.dart';

part 'realisasi_visit_event.dart';
part 'realisasi_visit_state.dart';

class RealisasiVisitBloc
    extends Bloc<RealisasiVisitEvent, RealisasiVisitState> {
  final GetRealisasiVisits getRealisasiVisits;
  final GetRealisasiVisitsGM getRealisasiVisitsGM;
  final GetRealisasiVisitsGMDetails getRealisasiVisitsGMDetails;
  final ApproveRealisasiVisit approveRealisasiVisit;
  final RejectRealisasiVisit rejectRealisasiVisit;

  RealisasiVisitBloc({
    required this.getRealisasiVisits,
    required this.getRealisasiVisitsGM,
    required this.getRealisasiVisitsGMDetails,
    required this.approveRealisasiVisit,
    required this.rejectRealisasiVisit,
  }) : super(RealisasiVisitInitial()) {
    on<GetRealisasiVisitsEvent>(_onGetRealisasiVisits);
    on<GetRealisasiVisitsGMEvent>(_onGetRealisasiVisitsGM);
    on<GetRealisasiVisitsGMDetailsEvent>(_onGetRealisasiVisitsGMDetails);
    on<ApproveRealisasiVisitEvent>(_onApproveRealisasiVisit);
    on<RejectRealisasiVisitEvent>(_onRejectRealisasiVisit);
  }

  Future<void> _onGetRealisasiVisits(
    GetRealisasiVisitsEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitLoading());
    final result = await getRealisasiVisits(event.idAtasan);
    result.fold(
      (failure) => emit(RealisasiVisitError(
        message: _mapFailureToMessage(failure),
      )),
      (realisasiVisits) => emit(RealisasiVisitLoaded(
        realisasiVisits: realisasiVisits,
      )),
    );
  }

  Future<void> _onGetRealisasiVisitsGM(
    GetRealisasiVisitsGMEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitLoading());
    final result = await getRealisasiVisitsGM(event.idAtasan);
    result.fold(
      (failure) => emit(RealisasiVisitError(
        message: _mapFailureToMessage(failure),
      )),
      (realisasiVisitsGM) => emit(RealisasiVisitGMLoaded(
        realisasiVisitsGM: realisasiVisitsGM,
      )),
    );
  }

  Future<void> _onGetRealisasiVisitsGMDetails(
    GetRealisasiVisitsGMDetailsEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    Logger.info('realisasi_visit_bloc', '=== FETCHING BCO DETAILS ===');
    Logger.info('realisasi_visit_bloc', 'BCO ID: ${event.idBCO}');

    emit(RealisasiVisitLoading());

    try {
      final result = await getRealisasiVisitsGMDetails(event.idBCO);

      result.fold(
        (failure) {
          Logger.error('realisasi_visit_bloc', 'Error: ${failure.toString()}');
          emit(RealisasiVisitError(message: _mapFailureToMessage(failure)));
        },
        (realisasiVisitsGM) {
          Logger.info('realisasi_visit_bloc',
              'Success! Received ${realisasiVisitsGM.length} items');
          for (var item in realisasiVisitsGM) {
            Logger.info(
                'realisasi_visit_bloc', '- Item: ${item.name} (${item.id})');
            Logger.info('realisasi_visit_bloc',
                '  Details count: ${item.details.length}');
          }
          emit(RealisasiVisitGMDetailsLoaded(
              realisasiVisitsGM: realisasiVisitsGM));
        },
      );
    } catch (e) {
      Logger.error('realisasi_visit_bloc', 'Exception: $e');
      emit(RealisasiVisitError(
        message: 'Terjadi kesalahan saat memuat detail BCO: $e',
      ));
    }
  }

  Future<void> _onApproveRealisasiVisit(
    ApproveRealisasiVisitEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitLoading());
    final result = await approveRealisasiVisit(
      ApproveRealisasiVisitParams(
        idRealisasiVisits: event.idRealisasiVisits,
        idUser: event.idUser,
      ),
    );
    result.fold(
      (failure) => emit(RealisasiVisitError(
        message: _mapFailureToMessage(failure),
      )),
      (message) => emit(RealisasiVisitApproved(message: message)),
    );
  }

  Future<void> _onRejectRealisasiVisit(
    RejectRealisasiVisitEvent event,
    Emitter<RealisasiVisitState> emit,
  ) async {
    emit(RealisasiVisitLoading());
    final result = await rejectRealisasiVisit(
      RejectRealisasiVisitParams(
        idRealisasiVisits: event.idRealisasiVisits,
        idUser: event.idUser,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(RealisasiVisitError(
        message: _mapFailureToMessage(failure),
      )),
      (message) => emit(RealisasiVisitRejected(message: message)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Terjadi kesalahan pada server';
      case NetworkFailure:
        return 'Tidak ada koneksi internet';
      case CacheFailure:
        return 'Terjadi kesalahan pada cache';
      default:
        return 'Terjadi kesalahan yang tidak diketahui';
    }
  }
}
