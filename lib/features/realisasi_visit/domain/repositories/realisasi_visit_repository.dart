import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/realisasi_visit.dart';
import '../entities/realisasi_visit_response.dart';

abstract class RealisasiVisitRepository {
  /// Mendapatkan data realisasi visit
  Future<Either<Failure, List<RealisasiVisit>>> getRealisasiVisits(
      int idAtasan);

  /// Menyetujui realisasi visit
  Future<Either<Failure, RealisasiVisitResponse>> approveRealisasiVisit(
      int idAtasan, List<String> idSchedule);

  /// Menolak realisasi visit
  Future<Either<Failure, RealisasiVisitResponse>> rejectRealisasiVisit(
      int idAtasan, List<String> idSchedule);
}
