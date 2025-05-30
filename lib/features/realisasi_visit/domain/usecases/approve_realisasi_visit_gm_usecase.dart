import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit_response.dart';
import '../repositories/realisasi_visit_repository.dart';

class ApproveRealisasiVisitGMUseCase
    implements UseCase<RealisasiVisitResponse, ApproveRealisasiVisitGMParams> {
  final RealisasiVisitRepository repository;

  ApproveRealisasiVisitGMUseCase(this.repository);

  @override
  Future<Either<Failure, RealisasiVisitResponse>> call(
      ApproveRealisasiVisitGMParams params) async {
    return await repository.approveRealisasiVisitGM(
        params.idAtasan, params.idSchedule);
  }
}

class ApproveRealisasiVisitGMParams extends Equatable {
  final int idAtasan;
  final List<String> idSchedule;

  const ApproveRealisasiVisitGMParams({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object?> get props => [idAtasan, idSchedule];
}
