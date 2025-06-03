import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/approval.dart';
import '../../domain/entities/approval_filter.dart';
import '../../domain/entities/approval_response.dart';
import '../../domain/entities/monthly_approval.dart';
import '../../domain/repositories/approval_repository.dart';
import '../datasources/approval_remote_data_source.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  final ApprovalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ApprovalRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Approval>>> getApprovals(int userId) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('GET', '/approvals/$userId');
        final approvals = await remoteDataSource.getApprovals(userId);
        Logger.api('GET', '/approvals/$userId', response: approvals);
        return Right(approvals);
      } catch (e) {
        Logger.error('ApprovalRepository', 'Error getting approvals: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<MonthlyApproval>>> getMonthlyApprovals(
      int userId) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('GET', '/monthly-approvals/$userId');
        final approvals = await remoteDataSource.getMonthlyApprovals(userId);
        Logger.api('GET', '/monthly-approvals/$userId', response: approvals);
        return Right(approvals);
      } catch (e) {
        Logger.error(
            'ApprovalRepository', 'Error getting monthly approvals: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Approval>>> filterApprovals(
      ApprovalFilter filter) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('POST', '/approvals/filter', body: filter);
        final approvals = await remoteDataSource.filterApprovals(filter);
        Logger.api('POST', '/approvals/filter', response: approvals);
        return Right(approvals);
      } catch (e) {
        Logger.error('ApprovalRepository', 'Error filtering approvals: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApprovalResponse>> sendApproval(
    int scheduleId,
    int userId, {
    required bool isApproved,
    String? joinScheduleId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.sendApproval(
          scheduleId,
          userId,
          isApproved: isApproved,
          joinScheduleId: joinScheduleId,
        );
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.toString()));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failure, void>> approveRequest(
      int approvalId, String notes) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('POST', '/approvals/$approvalId/approve',
            body: {'notes': notes});
        await remoteDataSource.approveRequest(approvalId, notes);
        Logger.success('ApprovalRepository', 'Request approved successfully');
        return const Right(null);
      } catch (e) {
        Logger.error('ApprovalRepository', 'Error approving request: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(
      String idSchedule, String idRejecter, String comment) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('POST', '/approvals/$idSchedule/reject', body: {
          'idRejecter': idRejecter,
          'comment': comment,
        });
        await remoteDataSource.rejectRequest(idSchedule, idRejecter, comment);
        Logger.success('ApprovalRepository', 'Request rejected successfully');
        return const Right(null);
      } catch (e) {
        Logger.error('ApprovalRepository', 'Error rejecting request: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Approval>> getApprovalDetail(int approvalId) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('GET', '/approvals/$approvalId/detail');
        final approval = await remoteDataSource.getApprovalDetail(approvalId);
        Logger.api('GET', '/approvals/$approvalId/detail', response: approval);
        return Right(approval);
      } catch (e) {
        Logger.error('ApprovalRepository', 'Error getting approval detail: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<RejectedSchedule>>> getRejectedSchedules(
      int userId) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('GET', '/approvals/$userId/rejected');
        final schedules = await remoteDataSource.getRejectedSchedules(userId);
        Logger.api('GET', '/approvals/$userId/rejected', response: schedules);
        return Right(schedules);
      } catch (e) {
        Logger.error(
            'ApprovalRepository', 'Error getting rejected schedules: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendMonthlyApproval({
    required List<int> scheduleIds,
    required List<String> scheduleJoinVisitIds,
    required int userId,
    required int userAtasanId,
    bool isRejected = false,
    String? comment,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.api('POST', '/monthly-approvals/send', body: {
          'scheduleIds': scheduleIds,
          'scheduleJoinVisitIds': scheduleJoinVisitIds,
          'userId': userId,
          'userAtasanId': userAtasanId,
          'isRejected': isRejected,
          'comment': comment,
        });

        final result = await remoteDataSource.sendMonthlyApproval(
          scheduleIds: scheduleIds,
          scheduleJoinVisitIds: scheduleJoinVisitIds,
          userId: userId,
          userAtasanId: userAtasanId,
          isRejected: isRejected,
          comment: comment,
        );

        Logger.success(
            'ApprovalRepository', 'Monthly approval sent successfully');
        return Right(result);
      } catch (e) {
        Logger.error(
            'ApprovalRepository', 'Error sending monthly approval: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }
}
