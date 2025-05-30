import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/edit/edit_schedule_response_model.dart';
import '../repositories/schedule_repository.dart';

class GetEditScheduleData
    implements UseCase<EditScheduleResponseModel, Params> {
  final ScheduleRepository repository;

  GetEditScheduleData(this.repository);

  @override
  Future<Either<Failure, EditScheduleResponseModel>> call(Params params) async {
    return await repository.fetchEditScheduleData(params.scheduleId);
  }
}

class Params extends Equatable {
  final int scheduleId;

  const Params({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}
