import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit_response.dart';
import '../repositories/realisasi_visit_repository.dart';

class ApproveRealisasiVisitUseCase
    implements UseCase<RealisasiVisitResponse, ApproveRealisasiVisitParams> {
  final RealisasiVisitRepository repository;

  ApproveRealisasiVisitUseCase(this.repository);

  @override
  Future<Either<Failure, RealisasiVisitResponse>> call(
      ApproveRealisasiVisitParams params) async {
    return await repository.approveRealisasiVisit(
        params.idAtasan, params.idSchedule);
  }
}

class ApproveRealisasiVisitParams extends Equatable {
  final int idAtasan;
  final List<String> idSchedule;

  const ApproveRealisasiVisitParams({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object?> get props => [idAtasan, idSchedule];
}
