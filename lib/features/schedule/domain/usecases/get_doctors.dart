import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class GetDoctors implements UseCase<DoctorResponse, NoParams> {
  final AddScheduleRepository repository;

  GetDoctors(this.repository);

  @override
  Future<Either<Failure, DoctorResponse>> call(NoParams params) {
    return repository.getDoctors();
  }
}
