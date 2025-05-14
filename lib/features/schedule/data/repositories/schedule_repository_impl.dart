import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Schedule>>> getSchedules(int userId) async {
    Logger.info('ScheduleRepositoryImpl', 'Memeriksa koneksi jaringan...');

    if (await networkInfo.isConnected) {
      Logger.info('ScheduleRepositoryImpl', 'Koneksi jaringan tersedia, mengambil data dari API...');
      try {
        final schedules = await remoteDataSource.getSchedules(userId);
        Logger.info('ScheduleRepositoryImpl', 'Data jadwal berhasil diambil dari API, jumlah: ${schedules.length}');
        return Right(schedules);
      } on ServerException catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Terjadi ServerException: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Terjadi Exception: $e');
        return Left(ServerFailure(message: 'Error: ${e.toString()}'));
      } catch (e) {
        Logger.error('ScheduleRepositoryImpl', 'Terjadi error tidak terduga: $e');
        return const Left(ServerFailure(
            message: 'Terjadi kesalahan tidak terduga. Silakan coba lagi.'));
      }
    } else {
      Logger.error('ScheduleRepositoryImpl', 'Tidak ada koneksi jaringan!');
      return const Left(NetworkFailure());
    }
  }
}
