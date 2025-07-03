import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class GetFilteredDailySchedule
    implements UseCase<List<Schedule>, FilterDailyScheduleParams> {
  final AddScheduleRepository repository;

  GetFilteredDailySchedule(this.repository);

  @override
  Future<Either<Failure, List<Schedule>>> call(
      FilterDailyScheduleParams params) {
    return repository.getFilteredDailySchedule(params.userId, params.date);
  }
}

class FilterDailyScheduleParams extends Equatable {
  final int userId;
  final String date;

  const FilterDailyScheduleParams({
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [userId, date];
}
