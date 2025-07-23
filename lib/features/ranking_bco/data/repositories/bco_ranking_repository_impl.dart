import '../../domain/entities/bco_ranking_entity.dart';
import '../../domain/repositories/bco_ranking_repository.dart';
import '../datasources/bco_ranking_remote_data_source.dart';

class BcoRankingRepositoryImpl implements BcoRankingRepository {
  final BcoRankingRemoteDataSource remoteDataSource;
  BcoRankingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BcoRankingEntity>> getBcoRanking({
    required String token,
    required String year,
    required String month,
  }) async {
    final models = await remoteDataSource.fetchBcoRanking(
        token: token, year: year, month: month);
    return models.map((e) => e.toEntity()).toList();
  }
}
