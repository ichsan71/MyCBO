import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/approval.dart';
import '../entities/approval_filter.dart';
import '../entities/approval_response.dart';

abstract class ApprovalRepository {
  /// Mendapatkan data persetujuan
  Future<Either<Failure, List<Approval>>> getApprovals(int userId);

  /// Memfilter data persetujuan
  Future<Either<Failure, List<Approval>>> filterApprovals(
      ApprovalFilter filter);

  /// Mengirim persetujuan (setuju atau tolak)
  Future<Either<Failure, ApprovalResponse>> sendApproval(
      int scheduleId, int userId,
      {required bool isApproved});

  Future<Either<Failure, void>> approveRequest(int approvalId, String notes);
  Future<Either<Failure, void>> rejectRequest(int approvalId, String notes);
  Future<Either<Failure, Approval>> getApprovalDetail(int approvalId);
}
