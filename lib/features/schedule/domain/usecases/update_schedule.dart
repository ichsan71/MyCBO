import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/update_schedule_request_model.dart';
import '../repositories/schedule_repository.dart';

class UpdateSchedule implements UseCase<Unit, UpdateScheduleParams> {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateScheduleParams params) async {
    return await repository.updateSchedule(params.requestModel);
  }
}

class UpdateScheduleParams extends Equatable {
  final UpdateScheduleRequestModel requestModel;

  const UpdateScheduleParams({required this.requestModel});

  @override
  List<Object> get props => [requestModel];
}
