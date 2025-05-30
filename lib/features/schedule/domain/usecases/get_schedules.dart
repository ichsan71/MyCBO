import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetSchedules implements UseCase<List<Schedule>, GetSchedulesParams> {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  @override
  Future<Either<Failure, List<Schedule>>> call(
      GetSchedulesParams params) async {
    return await repository.getSchedules(params.userId);
  }
}

class GetSchedulesParams extends Equatable {
  final int userId;

  const GetSchedulesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
