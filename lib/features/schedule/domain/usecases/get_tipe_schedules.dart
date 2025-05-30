import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tipe_schedule.dart';
import '../repositories/tipe_schedule_repository.dart';

class GetTipeSchedules implements UseCase<List<TipeSchedule>, NoParams> {
  final TipeScheduleRepository repository;

  GetTipeSchedules(this.repository);

  @override
  Future<Either<Failure, List<TipeSchedule>>> call(NoParams params) async {
    return await repository.getTipeSchedules();
  }
}
