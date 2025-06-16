import 'package:dartz/dartz.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
 
abstract class KpiRepository {
  Future<Either<Failure, KpiResponse>> getKpiData(String userId);
} 