import '../entities/bco_ranking_entity.dart';
import '../repositories/bco_ranking_repository.dart';

class GetBcoRanking {
  final BcoRankingRepository repository;
  GetBcoRanking(this.repository);

  Future<List<BcoRankingEntity>> call({
    required String token,
    required String year,
    required String month,
  }) async {
    return await repository.getBcoRanking(
        token: token, year: year, month: month);
  }
}
