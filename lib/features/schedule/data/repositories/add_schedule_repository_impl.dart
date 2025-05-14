import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/network/network_info.dart';
import 'package:test_cbo/features/schedule/data/datasources/add_schedule_remote_data_source.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class AddScheduleRepositoryImpl implements AddScheduleRepository {
  final AddScheduleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DoctorClinic>>> getDoctorsAndClinics(
      int userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDoctorsAndClinics =
            await remoteDataSource.getDoctorsAndClinics(userId);
        return Right(remoteDoctorsAndClinics);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ScheduleType>>> getScheduleTypes() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteScheduleTypes = await remoteDataSource.getScheduleTypes();
        return Right(remoteScheduleTypes);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts(int userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts(userId);
        return Right(remoteProducts);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.addSchedule(
          typeSchedule: typeSchedule,
          tujuan: tujuan,
          tglVisit: tglVisit,
          product: product,
          note: note,
          idUser: idUser,
          dokter: dokter,
          klinik: klinik,
          productForIdDivisi: productForIdDivisi,
          productForIdSpesialis: productForIdSpesialis,
          shift: shift,
          jenis: jenis,
          productNames: productNames,
          divisiNames: divisiNames,
          spesialisNames: spesialisNames,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DoctorResponse>> getDoctors() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDoctors = await remoteDataSource.getDoctors();
        return Right(remoteDoctors);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
