import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kpi_member.dart';
 
abstract class KpiMemberRepository {
  Future<Either<Failure, List<KpiMember>>> getKpiMemberData(String year, String month);
} 