import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/approval.dart';
import '../entities/approval_response.dart';

abstract class ApprovalRepository {
  /// Mendapatkan data persetujuan
  Future<Either<Failure, List<Approval>>> getApprovals(int userId);

  /// Mengirim persetujuan (setuju atau tolak)
  Future<Either<Failure, ApprovalResponse>> sendApproval(
      int scheduleId, int userId,
      {required bool isApproved});
}
