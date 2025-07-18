import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetSchedulesByRangeDate
    implements UseCase<List<Schedule>, GetSchedulesByRangeDateParams> {
  final ScheduleRepository repository;

  GetSchedulesByRangeDate(this.repository);

  @override
  Future<Either<Failure, List<Schedule>>> call(
      GetSchedulesByRangeDateParams params) async {
    return await repository.getSchedulesByRangeDate(
        params.userId, params.rangeDate, params.page);
  }
}

class GetSchedulesByRangeDateParams extends Equatable {
  final int userId;
  final String rangeDate;
  final int page;

  const GetSchedulesByRangeDateParams({
    required this.userId,
    required this.rangeDate,
    this.page = 1,
  });

  @override
  List<Object> get props => [userId, rangeDate, page];
}
