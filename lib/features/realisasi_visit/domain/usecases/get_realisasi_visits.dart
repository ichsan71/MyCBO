import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/realisasi_visit.dart';
import '../repositories/realisasi_visit_repository.dart';

class GetRealisasiVisits implements UseCase<List<RealisasiVisit>, int> {
  final RealisasiVisitRepository repository;

  GetRealisasiVisits(this.repository);

  @override
  Future<Either<Failure, List<RealisasiVisit>>> call(int idAtasan) async {
    return await repository.getRealisasiVisits(idAtasan);
  }
} 