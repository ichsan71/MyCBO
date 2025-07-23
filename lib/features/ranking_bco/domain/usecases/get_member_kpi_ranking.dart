import '../entities/member_kpi_entity.dart';
import '../repositories/member_kpi_repository.dart';

class GetMemberKpiRanking {
  final MemberKpiRepository repository;
  GetMemberKpiRanking(this.repository);

  Future<List<MemberKpiEntity>> call({
    required int bcoId,
    required String year,
    required String month,
  }) async {
    return await repository.getMemberKpiRanking(
      bcoId: bcoId,
      year: year,
      month: month,
    );
  }
}
