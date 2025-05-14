import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/approval_response.dart';
import '../repositories/approval_repository.dart';

class SendApproval implements UseCase<ApprovalResponse, SendApprovalParams> {
  final ApprovalRepository repository;

  SendApproval(this.repository);

  @override
  Future<Either<Failure, ApprovalResponse>> call(
      SendApprovalParams params) async {
    return await repository.sendApproval(
      params.scheduleId,
      params.userId,
      isApproved: params.isApproved,
    );
  }
}

class SendApprovalParams extends Equatable {
  final int scheduleId;
  final int userId;
  final bool isApproved;

  const SendApprovalParams({
    required this.scheduleId,
    required this.userId,
    required this.isApproved,
  });

  @override
  List<Object?> get props => [scheduleId, userId, isApproved];
}
