import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../../domain/entities/realisasi_visit_gm.dart';
import '../../domain/repositories/realisasi_visit_repository.dart';
import '../datasources/realisasi_visit_remote_data_source.dart';

class RealisasiVisitRepositoryImpl implements RealisasiVisitRepository {
  final RealisasiVisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const RealisasiVisitRepositoryImpl({
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
        final remoteRealisasiVisitsGM =
            await remoteDataSource.getRealisasiVisitsGM(idAtasan);
        return Right(remoteRealisasiVisitsGM);
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
  Future<Either<Failure, List<RealisasiVisitGM>>> getRealisasiVisitsGMDetails(
      int idBCO) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRealisasiVisitsGMDetails =
            await remoteDataSource.getRealisasiVisitsGMDetails(idBCO);
        return Right(remoteRealisasiVisitsGMDetails);
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
  Future<Either<Failure, String>> approveRealisasiVisit({
    required int idRealisasiVisit,
    required int idUser,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.approveRealisasiVisit(
          idRealisasiVisit: idRealisasiVisit,
          idUser: idUser,
        );
        return Right(result);
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
  Future<Either<Failure, String>> rejectRealisasiVisit({
    required int idRealisasiVisit,
    required int idUser,
    required String reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.rejectRealisasiVisit(
          idRealisasiVisit: idRealisasiVisit,
          idUser: idUser,
          reason: reason,
        );
        return Right(result);
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
