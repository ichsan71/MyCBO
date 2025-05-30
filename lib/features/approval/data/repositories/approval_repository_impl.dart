import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/approval.dart';
import '../../domain/entities/approval_filter.dart';
import '../../domain/entities/approval_response.dart';
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
        final remoteApprovals = await remoteDataSource.getApprovals(userId);
        return Right(remoteApprovals);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Approval>>> filterApprovals(
      ApprovalFilter filter) async {
    if (await networkInfo.isConnected) {
      try {
        final filteredApprovals =
            await remoteDataSource.filterApprovals(filter);
        return Right(filteredApprovals);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApprovalResponse>> sendApproval(
      int scheduleId, int userId,
      {required bool isApproved}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.sendApproval(scheduleId, userId,
            isApproved: isApproved);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> approveRequest(
      int approvalId, String notes) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.approveRequest(approvalId, notes);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(
      String idSchedule, String idRejecter, String comment) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.rejectRequest(idSchedule, idRejecter, comment);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Approval>> getApprovalDetail(int approvalId) async {
    if (await networkInfo.isConnected) {
      try {
        final approval = await remoteDataSource.getApprovalDetail(approvalId);
        return Right(approval);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<List<RejectedSchedule>> getRejectedSchedules(int userId) async {
    return await remoteDataSource.getRejectedSchedules(userId);
  }
}
