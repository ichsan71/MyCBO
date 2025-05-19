import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit_response.dart';
import '../repositories/realisasi_visit_repository.dart';

class RejectRealisasiVisitUseCase
    implements UseCase<RealisasiVisitResponse, RejectRealisasiVisitParams> {
  final RealisasiVisitRepository repository;

  RejectRealisasiVisitUseCase(this.repository);

  @override
  Future<Either<Failure, RealisasiVisitResponse>> call(
      RejectRealisasiVisitParams params) async {
    return await repository.rejectRealisasiVisit(
        params.idAtasan, params.idSchedule);
  }
}

class RejectRealisasiVisitParams extends Equatable {
  final int idAtasan;
  final List<String> idSchedule;

  const RejectRealisasiVisitParams({
    required this.idAtasan,
    required this.idSchedule,
  });

  @override
  List<Object?> get props => [idAtasan, idSchedule];
}
