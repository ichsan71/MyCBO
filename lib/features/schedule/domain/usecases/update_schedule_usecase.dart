import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/update_schedule_request_model.dart';
import '../repositories/schedule_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateScheduleUseCase {
  final ScheduleRepository repository;

  UpdateScheduleUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UpdateScheduleParams params) async {
    return await repository.updateSchedule(params.requestModel);
  }
}

class UpdateScheduleParams extends Equatable {
  final UpdateScheduleRequestModel requestModel;

  const UpdateScheduleParams({required this.requestModel});

  @override
  List<Object?> get props => [requestModel];
}
