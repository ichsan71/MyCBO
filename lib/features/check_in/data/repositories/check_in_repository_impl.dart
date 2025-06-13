import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../../schedule/data/models/checkin_request_model.dart';
import '../../../schedule/data/models/checkout_request_model.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../datasources/check_in_remote_data_source.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CheckInRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> checkIn(CheckinRequestModel request) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.info('CheckInRepository', 'Attempting to check in...');
        await remoteDataSource.checkIn(request);
        Logger.success('CheckInRepository', 'Check-in successful');
        return const Right(null);
      } on ServerException catch (e) {
        Logger.error(
            'CheckInRepository', 'Server error during check-in: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error(
            'CheckInRepository', 'Unexpected error during check-in: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      Logger.error('CheckInRepository', 'No network connection');
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> checkOut(CheckoutRequestModel request) async {
    if (await networkInfo.isConnected) {
      try {
        Logger.info('CheckInRepository', 'Attempting to check out...');
        await remoteDataSource.checkOut(request);
        Logger.success('CheckInRepository', 'Check-out successful');
        return const Right(null);
      } on ServerException catch (e) {
        Logger.error(
            'CheckInRepository', 'Server error during check-out: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error(
            'CheckInRepository', 'Unexpected error during check-out: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      Logger.error('CheckInRepository', 'No network connection');
      return const Left(NetworkFailure());
    }
  }
}
