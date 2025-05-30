import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/approval_repository.dart';

class RejectRequestUseCase implements UseCase<void, RejectRequestParams> {
  final ApprovalRepository repository;

  RejectRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RejectRequestParams params) async {
    return await repository.rejectRequest(
        params.idSchedule, params.idRejecter, params.comment);
  }
}

class RejectRequestParams {
  final String idSchedule;
  final String idRejecter;
  final String comment;

  RejectRequestParams({
    required this.idSchedule,
    required this.idRejecter,
    required this.comment,
  });
}
