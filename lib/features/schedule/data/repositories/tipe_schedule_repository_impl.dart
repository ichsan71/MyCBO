import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/tipe_schedule.dart';
import '../../domain/repositories/tipe_schedule_repository.dart';
import '../datasources/tipe_schedule_remote_data_source.dart';

class TipeScheduleRepositoryImpl implements TipeScheduleRepository {
  final TipeScheduleRemoteDataSource remoteDataSource;

  TipeScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TipeSchedule>>> getTipeSchedules() async {
    try {
      final result = await remoteDataSource.getTipeSchedules();
      return Right(result
          .map((model) => TipeSchedule(
                id: model.id,
                name: model.name,
                createdAt: model.createdAt,
              ))
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }
}
