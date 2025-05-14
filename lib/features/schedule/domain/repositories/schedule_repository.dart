import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<Schedule>>> getSchedules(int userId);
}
