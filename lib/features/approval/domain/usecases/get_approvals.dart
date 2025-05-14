import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/approval.dart';
import '../repositories/approval_repository.dart';

class GetApprovals implements UseCase<List<Approval>, Params> {
  final ApprovalRepository repository;

  GetApprovals(this.repository);

  @override
  Future<Either<Failure, List<Approval>>> call(Params params) async {
    return await repository.getApprovals(params.userId);
  }
}

class Params extends Equatable {
  final int userId;

  const Params({required this.userId});

  @override
  List<Object?> get props => [userId];
}
