import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/realisasi_visit_repository.dart';

class ApproveRealisasiVisit
    implements UseCase<String, ApproveRealisasiVisitParams> {
  final RealisasiVisitRepository repository;

  ApproveRealisasiVisit(this.repository);

  @override
  Future<Either<Failure, String>> call(
      ApproveRealisasiVisitParams params) async {
    return await repository.approveRealisasiVisit(
      idRealisasiVisits: params.idRealisasiVisits,
      idUser: params.idUser,
    );
  }
}

class ApproveRealisasiVisitParams {
  final List<int> idRealisasiVisits;
  final int idUser;

  const ApproveRealisasiVisitParams({
    required this.idRealisasiVisits,
    required this.idUser,
  });
}
