import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/ranking_achievement/domain/entities/ranking_achievement_entity.dart';
import 'package:test_cbo/features/ranking_achievement/domain/repositories/ranking_achievement_repository.dart';

class GetRankingAchievement
    implements UseCase<List<RankingAchievementEntity>, Params> {
  final RankingAchievementRepository repository;

  GetRankingAchievement(this.repository);

  @override
  Future<Either<Failure, List<RankingAchievementEntity>>> call(
      Params params) async {
    return await repository.getRankingAchievement(params.roleId);
  }
}

class Params extends Equatable {
  final String roleId;

  const Params({required this.roleId});

  @override
  List<Object> get props => [roleId];
}
