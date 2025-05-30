import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/schedule.dart';
import '../repositories/schedule_repository.dart';
import 'package:equatable/equatable.dart';

class GetSchedulesByRangeDateUseCase {
  final ScheduleRepository repository;

  GetSchedulesByRangeDateUseCase(this.repository);

  Future<Either<Failure, List<Schedule>>> call(
      ScheduleByRangeDateParams params) async {
    return await repository.getSchedulesByRangeDate(
        params.userId, params.rangeDate);
  }
}

class ScheduleByRangeDateParams extends Equatable {
  final int userId;
  final String rangeDate;

  const ScheduleByRangeDateParams(
      {required this.userId, required this.rangeDate});

  @override
  List<Object?> get props => [userId, rangeDate];
}
