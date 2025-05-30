import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../../domain/entities/realisasi_visit_gm.dart';
import '../../domain/entities/realisasi_visit_response.dart';
import '../../domain/repositories/realisasi_visit_repository.dart';
import '../datasources/realisasi_visit_remote_data_source.dart';

class RealisasiVisitRepositoryImpl implements RealisasiVisitRepository {
  final RealisasiVisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RealisasiVisitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RealisasiVisit>>> getRealisasiVisits(
      int idAtasan) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRealisasiVisits =
            await remoteDataSource.getRealisasiVisits(idAtasan);
        return Right(remoteRealisasiVisits);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<RealisasiVisitGM>>> getRealisasiVisitsGM(
      int idAtasan) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRealisasiVisits =
            await remoteDataSource.getRealisasiVisitsGM(idAtasan);
        return Right(remoteRealisasiVisits);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, RealisasiVisitResponse>> approveRealisasiVisit(
      int idAtasan, List<String> idSchedule) async {
    if (await networkInfo.isConnected) {
      try {
        final response =
            await remoteDataSource.approveRealisasiVisit(idAtasan, idSchedule);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, RealisasiVisitResponse>> approveRealisasiVisitGM(
      int idAtasan, List<String> idSchedule) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.approveRealisasiVisitGM(
            idAtasan, idSchedule);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, RealisasiVisitResponse>> rejectRealisasiVisit(
      int idAtasan, List<String> idSchedule) async {
    if (await networkInfo.isConnected) {
      try {
        final response =
            await remoteDataSource.rejectRealisasiVisit(idAtasan, idSchedule);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
