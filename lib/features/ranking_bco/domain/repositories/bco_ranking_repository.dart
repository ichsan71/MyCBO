import '../entities/bco_ranking_entity.dart';

abstract class BcoRankingRepository {
  Future<List<BcoRankingEntity>> getBcoRanking({
    required String token,
    required String year,
    required String month,
  });
}
