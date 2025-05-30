import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/edit_schedule_data_model.dart';
import '../repositories/schedule_repository.dart';

class GetEditScheduleUseCase {
  final ScheduleRepository repository;

  GetEditScheduleUseCase(this.repository);

  Future<Either<Failure, EditScheduleDataModel>> call(int scheduleId) async {
    return await repository.getEditScheduleData(scheduleId);
  }
}
