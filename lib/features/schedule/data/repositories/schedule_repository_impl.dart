import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/edit_schedule_data_model.dart';
import '../models/edit/edit_schedule_response_model.dart';
import '../models/update_schedule_request_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Schedule>>> getSchedules(int userId,
      {int page = 1}) async {
    Logger.info('ScheduleRepositoryImpl', 'Memeriksa koneksi jaringan...');

    if (await networkInfo.isConnected) {
      Logger.info('ScheduleRepositoryImpl',
          'Koneksi jaringan tersedia, mengambil data dari API...');
      try {
        final schedules =
            await remoteDataSource.getSchedules(userId, page: page);
        Logger.info('ScheduleRepositoryImpl',
            'Data jadwal berhasil diambil dari API, jumlah: ${schedules.length}');
        return Right(schedules);
      } on ServerException catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi ServerException: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi error tidak terduga: $e');
        return const Left(ServerFailure(
            message: 'Terjadi kesalahan tidak terduga. Silakan coba lagi.'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'Tidak ada koneksi jaringan!');
      return const Left(NetworkFailure(
          message:
              'Tidak ada koneksi internet. Silakan periksa koneksi anda dan coba lagi.'));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getSchedulesByRangeDate(
      int userId, String rangeDate, int page) async {
    Logger.info('ScheduleRepositoryImpl',
        'Memeriksa koneksi jaringan untuk filter by range date...');
    if (await networkInfo.isConnected) {
      try {
        final schedules = await remoteDataSource.getSchedulesByRangeDate(
            userId, rangeDate, page);
        Logger.info('ScheduleRepositoryImpl',
            'Data jadwal by range date berhasil diambil dari API, jumlah: ${schedules.length}');
        return Right(schedules);
      } on ServerException catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi ServerException: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi error tidak terduga: $e');
        return const Left(ServerFailure(
            message: 'Terjadi kesalahan tidak terduga. Silakan coba lagi.'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'Tidak ada koneksi jaringan!');
      return const Left(NetworkFailure(
          message:
              'Tidak ada koneksi internet. Silakan periksa koneksi anda dan coba lagi.'));
    }
  }

  @override
  Future<Either<Failure, EditScheduleDataModel>> getEditScheduleData(
      int scheduleId) async {
    Logger.info('ScheduleRepositoryImpl',
        'Memeriksa koneksi jaringan untuk mengambil data edit jadwal...');

    if (await networkInfo.isConnected) {
      Logger.info('ScheduleRepositoryImpl',
          'Koneksi jaringan tersedia, mengambil data edit jadwal dari API...');
      try {
        final editScheduleData =
            await remoteDataSource.getEditScheduleData(scheduleId);
        Logger.info('ScheduleRepositoryImpl',
            'Data edit jadwal berhasil diambil dari API');
        return Right(editScheduleData);
      } on ServerException catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi ServerException: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi error tidak terduga: $e');
        return const Left(ServerFailure(
            message: 'Terjadi kesalahan tidak terduga. Silakan coba lagi.'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'Tidak ada koneksi jaringan!');
      return const Left(NetworkFailure(
          message:
              'Tidak ada koneksi internet. Silakan periksa koneksi anda dan coba lagi.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSchedule(
      UpdateScheduleRequestModel requestModel) async {
    Logger.info('ScheduleRepositoryImpl', 'Memeriksa koneksi jaringan...');

    if (await networkInfo.isConnected) {
      Logger.info('ScheduleRepositoryImpl',
          'Koneksi jaringan tersedia, memperbarui jadwal...');
      try {
        await remoteDataSource.updateSchedule(requestModel);
        Logger.info('ScheduleRepositoryImpl', 'Jadwal berhasil diperbarui');
        return const Right(unit);
      } on ServerException catch (e) {
        Logger.error(
            'ScheduleRepositoryImpl', 'Terjadi ServerException: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        Logger.error('ScheduleRepositoryImpl',
            'Terjadi UnauthorizedException: ${e.message}');
        return Left(UnauthorizedFailure(message: e.message));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'Tidak ada koneksi internet');
      return const Left(NetworkFailure(
          message:
              'Tidak dapat memperbarui jadwal. Periksa koneksi internet Anda.'));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getRejectedSchedules(
      int userId) async {
    Logger.info('ScheduleRepositoryImpl', 'Fetching rejected schedules...');

    if (await networkInfo.isConnected) {
      try {
        final schedules = await remoteDataSource.getRejectedSchedules(userId);
        Logger.info('ScheduleRepositoryImpl',
            'Successfully fetched ${schedules.length} rejected schedules');
        return Right(schedules);
      } on ServerException catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Server error: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Unexpected error: $e');
        return const Left(
            ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'No network connection');
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, EditScheduleDataModel>> getScheduleData(
      int userId) async {
    Logger.info('ScheduleRepositoryImpl', 'Fetching schedule data...');

    if (await networkInfo.isConnected) {
      try {
        final data = await remoteDataSource.getEditScheduleData(userId);
        Logger.info(
            'ScheduleRepositoryImpl', 'Successfully fetched schedule data');
        return Right(data);
      } on ServerException catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Server error: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Unexpected error: $e');
        return const Left(
            ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'No network connection');
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, EditScheduleResponseModel>> fetchEditScheduleData(
      int scheduleId) async {
    Logger.info('ScheduleRepositoryImpl', 'Fetching edit schedule data...');

    if (await networkInfo.isConnected) {
      try {
        final data = await remoteDataSource.fetchEditScheduleData(scheduleId);
        Logger.info('ScheduleRepositoryImpl',
            'Successfully fetched edit schedule data');
        return Right(data);
      } on ServerException catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Server error: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Unexpected error: $e');
        return const Left(
            ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'No network connection');
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveEditedSchedule(Schedule schedule) async {
    Logger.info('ScheduleRepositoryImpl', 'Saving edited schedule...');

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveEditedSchedule(schedule);
        Logger.info(
            'ScheduleRepositoryImpl', 'Successfully saved edited schedule');
        return const Right(unit);
      } on ServerException catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Server error: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Unexpected error: $e');
        return const Left(
            ServerFailure(message: 'An unexpected error occurred'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'No network connection');
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }
}
