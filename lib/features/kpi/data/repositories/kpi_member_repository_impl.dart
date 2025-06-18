import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/kpi_member_repository.dart';
import '../../domain/entities/kpi_member.dart';
import '../datasources/kpi_member_remote_data_source.dart';
import '../models/kpi_model.dart';

class KpiMemberRepositoryImpl implements KpiMemberRepository {
  final KpiMemberRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  KpiMemberRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<KpiMember>>> getKpiMemberData(
    String year,
    String month,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        debugPrint('KPI Member Repository: Checking network connection...');
        final result = await remoteDataSource.getKpiMemberData(year, month);
        debugPrint('KPI Member Repository: Successfully fetched ${result.length} KPI members');
        return Right(result);
      } on ServerException catch (e) {
        debugPrint('KPI Member Repository: Server exception: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } on AuthenticationException catch (e) {
        debugPrint('KPI Member Repository: Authentication exception: ${e.message}');
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        debugPrint('KPI Member Repository: Unexpected error: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      debugPrint('KPI Member Repository: No network connection');
      return const Left(NetworkFailure());
    }
  }
} 