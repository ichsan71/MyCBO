import '../../domain/entities/member_kpi_entity.dart';
import '../../domain/repositories/member_kpi_repository.dart';
import '../datasources/member_kpi_remote_data_source.dart';

class MemberKpiRepositoryImpl implements MemberKpiRepository {
  final MemberKpiRemoteDataSource remoteDataSource;
  MemberKpiRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MemberKpiEntity>> getMemberKpiRanking({
    required int bcoId,
    required String year,
    required String month,
  }) async {
    return await remoteDataSource.fetchMemberKpiRanking(
      bcoId: bcoId,
      year: year,
      month: month,
    );
  }
}
