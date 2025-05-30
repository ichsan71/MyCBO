import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetRejectedSchedules
    implements UseCase<List<Schedule>, GetRejectedSchedulesParams> {
  final ScheduleRepository repository;

  GetRejectedSchedules(this.repository);

  @override
  Future<Either<Failure, List<Schedule>>> call(
      GetRejectedSchedulesParams params) async {
    return await repository.getRejectedSchedules(params.userId);
  }
}

class GetRejectedSchedulesParams extends Equatable {
  final int userId;

  const GetRejectedSchedulesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
