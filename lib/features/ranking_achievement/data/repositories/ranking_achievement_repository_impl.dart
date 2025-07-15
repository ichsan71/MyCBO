import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/network/network_info.dart';
import 'package:test_cbo/features/ranking_achievement/data/datasources/ranking_achievement_remote_data_source.dart';
import 'package:test_cbo/features/ranking_achievement/domain/entities/ranking_achievement_entity.dart';
import 'package:test_cbo/features/ranking_achievement/domain/repositories/ranking_achievement_repository.dart';
import 'package:flutter/foundation.dart';

class RankingAchievementRepositoryImpl implements RankingAchievementRepository {
  final RankingAchievementRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RankingAchievementRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RankingAchievementEntity>>> getRankingAchievement(
      String roleId) async {
    try {
      debugPrint(
          'RankingAchievementRepository - Checking network connectivity');

      if (await networkInfo.isConnected) {
        debugPrint(
            'RankingAchievementRepository - Network connected, fetching data');

        final response = await remoteDataSource.getRankingAchievement(roleId);

        // Convert model to entity
        final entities = response.data
            .map((data) => RankingAchievementEntity(
                  idUser: data.idUser,
                  nama: data.nama,
                  kodeRayon: data.kodeRayon,
                  monthlyAchievements: data.monthlyAchievements,
                ))
            .toList();

        debugPrint(
            'RankingAchievementRepository - Successfully fetched ${entities.length} records');
        return Right(entities);
      } else {
        debugPrint('RankingAchievementRepository - No network connection');
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      debugPrint(
          'RankingAchievementRepository - ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      debugPrint('RankingAchievementRepository - CacheException: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      debugPrint('RankingAchievementRepository - Unexpected error: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }
}
