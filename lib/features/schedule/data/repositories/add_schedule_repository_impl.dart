import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/network/network_info.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/datasources/add_schedule_remote_data_source.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_model.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class AddScheduleRepositoryImpl implements AddScheduleRepository {
  final AddScheduleRemoteDataSource remoteDataSource;
  final AddScheduleLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  static const String _tag = 'AddScheduleRepositoryImpl';

  AddScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DoctorClinicBase>>> getDoctorsAndClinics(
      int userId) async {
    if (await networkInfo.isConnected) {
      try {
        final doctorClinicModels =
            await remoteDataSource.getDoctorsAndClinics(userId);
        await localDataSource.cacheDoctors(doctorClinicModels);
        return Right(doctorClinicModels);
      } on ServerException catch (e) {
        try {
          final cachedDoctors = await localDataSource.getDoctorsAndClinics();
          return Right(cachedDoctors);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } on UnauthorizedException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        try {
          final cachedDoctors = await localDataSource.getDoctorsAndClinics();
          return Right(cachedDoctors);
        } on CacheException {
          return Left(CacheFailure(message: 'Failed to get doctors: $e'));
        }
      }
    } else {
      try {
        final cachedDoctors = await localDataSource.getDoctorsAndClinics();
        return Right(cachedDoctors);
      } on CacheException {
        return const Left(CacheFailure(
          message:
              'No cached doctors data available. Please check your internet connection.',
        ));
      }
    }
  }

  @override
  Future<Either<Failure, List<ScheduleType>>> getScheduleTypes() async {
    Logger.info(_tag, 'Getting schedule types');

    if (await networkInfo.isConnected) {
      Logger.info(_tag, 'Network connected, checking if sync needed');

      try {
        // Cek apakah perlu sinkronisasi
        final syncNeeded = await localDataSource.isScheduleTypesSyncNeeded();

        if (syncNeeded) {
          Logger.info(_tag, 'Schedule types sync needed, fetching from remote');
          try {
            final remoteScheduleTypes =
                await remoteDataSource.getScheduleTypes();
            Logger.success(_tag,
                'Successfully fetched ${remoteScheduleTypes.length} schedule types from remote');

            // Cache data yang baru diambil
            await localDataSource.cacheScheduleTypes(remoteScheduleTypes);

            return Right(remoteScheduleTypes);
          } on ServerException catch (e) {
            Logger.error(_tag,
                'Server error when fetching schedule types: ${e.message}');

            // Jika gagal dari remote, coba ambil dari cache
            try {
              final localTypes = await localDataSource.getScheduleTypes();
              Logger.info(_tag,
                  'Falling back to local data: ${localTypes.length} schedule types');
              return Right(localTypes);
            } on CacheException {
              Logger.error(_tag, 'No local schedule types data available');
              return Left(ServerFailure(message: e.message));
            }
          }
        } else {
          Logger.info(_tag, 'Using cached schedule types data');
          final localTypes = await localDataSource.getScheduleTypes();
          return Right(localTypes);
        }
      } on CacheException {
        Logger.warning(
            _tag, 'No cached schedule types data, fetching from remote');
        try {
          final remoteScheduleTypes = await remoteDataSource.getScheduleTypes();
          await localDataSource.cacheScheduleTypes(remoteScheduleTypes);
          return Right(remoteScheduleTypes);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        Logger.error(_tag, 'Unexpected error checking sync status: $e');
        try {
          final remoteScheduleTypes = await remoteDataSource.getScheduleTypes();
          await localDataSource.cacheScheduleTypes(remoteScheduleTypes);
          return Right(remoteScheduleTypes);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      Logger.warning(
          _tag, 'No network connection, trying to get cached schedule types');
      try {
        final localTypes = await localDataSource.getScheduleTypes();
        return Right(localTypes);
      } on CacheException {
        Logger.error(_tag, 'No cached schedule types data available');
        return const Left(CacheFailure(
            message:
                'Tidak ada data tipe jadwal tersimpan. Periksa koneksi internet Anda.'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts(int userId) async {
    Logger.info(_tag, 'Getting products for user $userId');

    if (await networkInfo.isConnected) {
      Logger.info(_tag, 'Network connected, checking if sync needed');

      try {
        // Cek apakah perlu sinkronisasi
        final syncNeeded = await localDataSource.isProductsSyncNeeded();

        if (syncNeeded) {
          Logger.info(_tag, 'Products sync needed, fetching from remote');
          try {
            final remoteProducts = await remoteDataSource.getProducts(userId);
            Logger.success(_tag,
                'Successfully fetched ${remoteProducts.length} products from remote');

            // Cache data yang baru diambil
            await localDataSource.cacheProducts(remoteProducts);

            return Right(remoteProducts);
          } on ServerException catch (e) {
            Logger.error(
                _tag, 'Server error when fetching products: ${e.message}');

            // Jika gagal dari remote, coba ambil dari cache
            try {
              final localProducts = await localDataSource.getProducts();
              Logger.info(_tag,
                  'Falling back to local data: ${localProducts.length} products');
              return Right(localProducts);
            } on CacheException {
              Logger.error(_tag, 'No local products data available');
              return Left(ServerFailure(message: e.message));
            }
          }
        } else {
          Logger.info(_tag, 'Using cached products data');
          final localProducts = await localDataSource.getProducts();
          return Right(localProducts);
        }
      } on CacheException {
        Logger.warning(_tag, 'No cached products data, fetching from remote');
        try {
          final remoteProducts = await remoteDataSource.getProducts(userId);
          await localDataSource.cacheProducts(remoteProducts);
          return Right(remoteProducts);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        Logger.error(_tag, 'Unexpected error checking sync status: $e');
        try {
          final remoteProducts = await remoteDataSource.getProducts(userId);
          await localDataSource.cacheProducts(remoteProducts);
          return Right(remoteProducts);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      Logger.warning(
          _tag, 'No network connection, trying to get cached products');
      try {
        final localProducts = await localDataSource.getProducts();
        return Right(localProducts);
      } on CacheException {
        Logger.error(_tag, 'No cached products data available');
        return const Left(CacheFailure(
            message:
                'Tidak ada data produk tersimpan. Periksa koneksi internet Anda.'));
      }
    }
  }

  @override
  Future<Either<Failure, DoctorResponse>> getDoctors() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getDoctors();
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get doctors: $e'));
      }
    } else {
      return const Left(CacheFailure(
        message: 'No internet connection available.',
      ));
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
}
