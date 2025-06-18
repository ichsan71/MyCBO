import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
import 'package:test_cbo/features/kpi/domain/repositories/kpi_repository.dart';

class GetKpiData implements UseCase<KpiResponse, Params> {
  final KpiRepository repository;

  GetKpiData(this.repository);

  @override
  Future<Either<Failure, KpiResponse>> call(Params params) async {
    return await repository.getKpiData(params.userId, params.year, params.month);
  }
}

class Params extends Equatable {
  final String userId;
  final String year;
  final String month;

  const Params({
    required this.userId,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [userId, year, month];
} 