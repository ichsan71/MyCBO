import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetSchedulesUseCase implements UseCase<List<Schedule>, ScheduleParams> {
  final ScheduleRepository repository;

  GetSchedulesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Schedule>>> call(ScheduleParams params) async {
    return await repository.getSchedules(params.userId, page: params.page);
  }
}

class ScheduleParams extends Equatable {
  final int userId;
  final int page;

  const ScheduleParams({required this.userId, this.page = 1});

  @override
  List<Object?> get props => [userId, page];
}

class GetSchedulesByRangeDateUseCase
    implements UseCase<List<Schedule>, ScheduleByRangeDateParams> {
  final ScheduleRepository repository;
  GetSchedulesByRangeDateUseCase(this.repository);
  @override
  Future<Either<Failure, List<Schedule>>> call(
      ScheduleByRangeDateParams params) async {
    return await repository.getSchedulesByRangeDate(
        params.userId, params.rangeDate, params.page);
  }
}

class ScheduleByRangeDateParams extends Equatable {
  final int userId;
  final String rangeDate;
  final int page;
  const ScheduleByRangeDateParams({
    required this.userId,
    required this.rangeDate,
    this.page = 1,
  });
  @override
  List<Object?> get props => [userId, rangeDate, page];
}
