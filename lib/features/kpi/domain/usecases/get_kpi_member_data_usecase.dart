import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/kpi_member_repository.dart';
import '../entities/kpi_member.dart';

class GetKpiMemberDataUseCase implements UseCase<List<KpiMember>, KpiMemberParams> {
  final KpiMemberRepository repository;

  GetKpiMemberDataUseCase(this.repository);

  @override
  Future<Either<Failure, List<KpiMember>>> call(KpiMemberParams params) async {
    return await repository.getKpiMemberData(params.year, params.month);
  }
}

class KpiMemberParams extends Equatable {
  final String year;
  final String month;

  const KpiMemberParams({
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [year, month];
} 