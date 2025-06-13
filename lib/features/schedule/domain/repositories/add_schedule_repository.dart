import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';

abstract class AddScheduleRepository {
  Future<Either<Failure, List<DoctorClinicBase>>> getDoctorsAndClinics(int userId);
  Future<Either<Failure, List<ScheduleType>>> getScheduleTypes();
  Future<Either<Failure, List<Product>>> getProducts(int userId);
  Future<Either<Failure, DoctorResponse>> getDoctors();
  Future<Either<Failure, bool>> addSchedule({
    required int typeSchedule,
    required String tujuan,
    required String tglVisit,
    required List<int> product,
    required String note,
    required int idUser,
    required int dokter,
    required String klinik,
    required List<int> productForIdDivisi,
    required List<int> productForIdSpesialis,
    required String shift,
    required String jenis,
    required List<String> productNames,
    required List<String> divisiNames,
    required List<String> spesialisNames,
  });
}
