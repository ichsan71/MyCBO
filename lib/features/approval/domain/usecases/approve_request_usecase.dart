import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/approval_repository.dart';

class ApproveRequestUseCase implements UseCase<void, ApproveRequestParams> {
  final ApprovalRepository repository;

  ApproveRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ApproveRequestParams params) async {
    return await repository.approveRequest(params.approvalId, params.notes);
  }
}

class ApproveRequestParams {
  final int approvalId;
  final String notes;

  ApproveRequestParams({
    required this.approvalId,
    required this.notes,
  });
}
