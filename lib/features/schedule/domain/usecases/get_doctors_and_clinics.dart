import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class GetDoctorsAndClinics implements UseCase<List<DoctorClinic>, Params> {
  final AddScheduleRepository repository;

  GetDoctorsAndClinics(this.repository);

  @override
  Future<Either<Failure, List<DoctorClinic>>> call(Params params) {
    return repository.getDoctorsAndClinics(params.userId);
  }
}

class Params extends Equatable {
  final int userId;

  const Params({required this.userId});

  @override
  List<Object?> get props => [userId];
} 