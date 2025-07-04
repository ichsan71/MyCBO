import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/realisasi_visit_repository.dart';

class ApproveRealisasiVisitUseCase
    implements UseCase<String, ApproveRealisasiVisitParams> {
  final RealisasiVisitRepository repository;

  ApproveRealisasiVisitUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(
      ApproveRealisasiVisitParams params) async {
    return await repository.approveRealisasiVisit(
      idRealisasiVisit: params.idRealisasiVisit,
      idUser: params.idUser,
    );
  }
}

class ApproveRealisasiVisitParams extends Equatable {
  final int idRealisasiVisit;
  final int idUser;

  const ApproveRealisasiVisitParams({
    required this.idRealisasiVisit,
    required this.idUser,
  });

  @override
  List<Object?> get props => [idRealisasiVisit, idUser];
}
