import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/approval.dart';
import '../repositories/approval_repository.dart';

class GetApprovalsUseCase implements UseCase<List<Approval>, GetApprovalsParams> {
  final ApprovalRepository repository;

  GetApprovalsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Approval>>> call(GetApprovalsParams params) async {
    return await repository.getApprovals(params.userId);
  }
}

class GetApprovalsParams {
  final int userId;

  GetApprovalsParams({required this.userId});
}
