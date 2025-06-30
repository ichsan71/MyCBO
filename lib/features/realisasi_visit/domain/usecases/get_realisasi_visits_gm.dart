import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit_gm.dart';
import '../repositories/realisasi_visit_repository.dart';

class GetRealisasiVisitsGM implements UseCase<List<RealisasiVisitGM>, int> {
  final RealisasiVisitRepository repository;

  GetRealisasiVisitsGM(this.repository);

  @override
  Future<Either<Failure, List<RealisasiVisitGM>>> call(int idAtasan) async {
    return await repository.getRealisasiVisitsGM(idAtasan);
  }
} 