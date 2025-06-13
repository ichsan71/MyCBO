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
    return await repository.getKpiData(params.userId);
  }
}

class Params extends Equatable {
  final String userId;

  const Params({required this.userId});

  @override
  List<Object> get props => [userId];
} 