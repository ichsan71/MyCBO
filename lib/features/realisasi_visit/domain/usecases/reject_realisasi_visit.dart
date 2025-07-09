import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/realisasi_visit_repository.dart';

class RejectRealisasiVisit
    implements UseCase<String, RejectRealisasiVisitParams> {
  final RealisasiVisitRepository repository;

  RejectRealisasiVisit(this.repository);

  @override
  Future<Either<Failure, String>> call(
      RejectRealisasiVisitParams params) async {
    return await repository.rejectRealisasiVisit(
      idRealisasiVisits: params.idRealisasiVisits,
      idUser: params.idUser,
      reason: params.reason,
    );
  }
}

class RejectRealisasiVisitParams {
  final List<int> idRealisasiVisits;
  final int idUser;
  final String reason;

  RejectRealisasiVisitParams({
    required this.idRealisasiVisits,
    required this.idUser,
    required this.reason,
  });
}
