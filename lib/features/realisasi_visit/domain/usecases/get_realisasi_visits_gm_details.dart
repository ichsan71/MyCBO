import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit_gm.dart';
import '../repositories/realisasi_visit_repository.dart';

class GetRealisasiVisitsGMDetails implements UseCase<List<RealisasiVisitGM>, int> {
  final RealisasiVisitRepository repository;

  GetRealisasiVisitsGMDetails(this.repository);

  @override
  Future<Either<Failure, List<RealisasiVisitGM>>> call(int idBCO) async {
    // Get details from repository
    return await repository.getRealisasiVisitsGMDetails(idBCO);
  }
} 