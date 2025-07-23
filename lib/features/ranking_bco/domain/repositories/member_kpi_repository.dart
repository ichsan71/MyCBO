import '../entities/member_kpi_entity.dart';

abstract class MemberKpiRepository {
  Future<List<MemberKpiEntity>> getMemberKpiRanking({
    required int bcoId,
    required String year,
    required String month,
  });
}
