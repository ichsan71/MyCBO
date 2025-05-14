import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class GetScheduleTypes implements UseCase<List<ScheduleType>, NoParams> {
  final AddScheduleRepository repository;

  GetScheduleTypes(this.repository);

  @override
  Future<Either<Failure, List<ScheduleType>>> call(NoParams params) {
    return repository.getScheduleTypes();
  }
}
