import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/approval_repository.dart';

class RejectRequestUseCase implements UseCase<void, RejectRequestParams> {
  final ApprovalRepository repository;

  RejectRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RejectRequestParams params) async {
    return await repository.rejectRequest(params.approvalId, params.notes);
  }
}

class RejectRequestParams {
  final int approvalId;
  final String notes;

  RejectRequestParams({
    required this.approvalId,
    required this.notes,
  });
}
