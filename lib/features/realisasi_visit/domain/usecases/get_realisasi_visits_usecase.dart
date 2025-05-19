import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit.dart';
import '../repositories/realisasi_visit_repository.dart';

class GetRealisasiVisitsUseCase
    implements UseCase<List<RealisasiVisit>, GetRealisasiVisitsParams> {
  final RealisasiVisitRepository repository;

  GetRealisasiVisitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RealisasiVisit>>> call(
      GetRealisasiVisitsParams params) async {
    return await repository.getRealisasiVisits(params.idAtasan);
  }
}

class GetRealisasiVisitsParams extends Equatable {
  final int idAtasan;

  const GetRealisasiVisitsParams({required this.idAtasan});

  @override
  List<Object?> get props => [idAtasan];
}
