import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/realisasi_visit_repository.dart';

class RejectRealisasiVisitUseCase
    implements UseCase<String, RejectRealisasiVisitParams> {
  final RealisasiVisitRepository repository;

  RejectRealisasiVisitUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(
      RejectRealisasiVisitParams params) async {
    return await repository.rejectRealisasiVisit(
      idRealisasiVisit: params.idRealisasiVisit,
      idUser: params.idUser,
      reason: params.reason,
    );
  }
}

class RejectRealisasiVisitParams extends Equatable {
  final int idRealisasiVisit;
  final int idUser;
  final String reason;

  const RejectRealisasiVisitParams({
    required this.idRealisasiVisit,
    required this.idUser,
    required this.reason,
  });

  @override
  List<Object?> get props => [idRealisasiVisit, idUser, reason];
}
