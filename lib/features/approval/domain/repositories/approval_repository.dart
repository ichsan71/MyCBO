import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/approval.dart';
import '../entities/approval_filter.dart';
import '../entities/approval_response.dart';
import '../entities/monthly_approval.dart';
import '../../../approval/data/datasources/approval_remote_data_source.dart';

abstract class ApprovalRepository {
  /// Mendapatkan data persetujuan
  Future<Either<Failure, List<Approval>>> getApprovals(int userId);

  /// Mendapatkan data persetujuan bulanan
  Future<Either<Failure, List<MonthlyApproval>>> getMonthlyApprovals(
      int userId);

  /// Memfilter data persetujuan
  Future<Either<Failure, List<Approval>>> filterApprovals(
      ApprovalFilter filter);

  /// Mengirim persetujuan (setuju atau tolak)
  Future<Either<Failure, ApprovalResponse>> sendApproval(
      int scheduleId, int userId,
      {required bool isApproved, String? joinScheduleId});

  /// Mengirim persetujuan bulanan
  Future<Either<Failure, String>> sendMonthlyApproval({
    required List<int> scheduleIds,
    required List<String> scheduleJoinVisitIds,
    required int userId,
    required int userAtasanId,
    bool isRejected = false,
    String? comment,
  });

  Future<Either<Failure, void>> approveRequest(int approvalId, String notes);
  Future<Either<Failure, void>> rejectRequest(
      String idSchedule, String idRejecter, String comment);
  Future<Either<Failure, Approval>> getApprovalDetail(int approvalId);
  Future<Either<Failure, List<RejectedSchedule>>> getRejectedSchedules(
      int userId);

  /// Mengambil detail persetujuan bulanan untuk GM
  Future<Either<Failure, dynamic>> getMonthlyApprovalDetailGM(
      int userId, int year, int month);

  /// Mengambil detail persetujuan dadakan untuk GM
  Future<Either<Failure, dynamic>> getSuddenlyApprovalDetailGM(
      int userId, int year, int month);

  /// Menyetujui beberapa permintaan sekaligus
  Future<Either<Failure, void>> batchApproveRequest(
      List<int> scheduleIds, String notes);
}
