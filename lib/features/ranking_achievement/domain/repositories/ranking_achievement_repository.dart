import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/features/ranking_achievement/domain/entities/ranking_achievement_entity.dart';

abstract class RankingAchievementRepository {
  Future<Either<Failure, List<RankingAchievementEntity>>> getRankingAchievement(
      String roleId);
}
