import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/approval.dart';
import '../entities/approval_filter.dart';
import '../repositories/approval_repository.dart';

class FilterApprovalsUseCase
    implements UseCase<List<Approval>, ApprovalFilter> {
  final ApprovalRepository repository;

  FilterApprovalsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Approval>>> call(ApprovalFilter filter) async {
    return await repository.filterApprovals(filter);
  }
}
