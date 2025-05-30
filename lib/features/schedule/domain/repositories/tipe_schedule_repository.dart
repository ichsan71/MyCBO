import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tipe_schedule.dart';

abstract class TipeScheduleRepository {
  Future<Either<Failure, List<TipeSchedule>>> getTipeSchedules();
}
