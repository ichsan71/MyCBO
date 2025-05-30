import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit_gm.dart';
import '../repositories/realisasi_visit_repository.dart';

class GetRealisasiVisitsGMUseCase
    implements UseCase<List<RealisasiVisitGM>, GetRealisasiVisitsGMParams> {
  final RealisasiVisitRepository repository;

  GetRealisasiVisitsGMUseCase(this.repository);

  @override
  Future<Either<Failure, List<RealisasiVisitGM>>> call(
      GetRealisasiVisitsGMParams params) async {
    return await repository.getRealisasiVisitsGM(params.idAtasan);
  }
}

class GetRealisasiVisitsGMParams extends Equatable {
  final int idAtasan;

  const GetRealisasiVisitsGMParams({required this.idAtasan});

  @override
  List<Object?> get props => [idAtasan];
}
