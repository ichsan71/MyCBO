import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/realisasi_visit.dart';
import '../entities/realisasi_visit_gm.dart';

abstract class RealisasiVisitRepository {
  /// Mendapatkan data realisasi visit
  Future<Either<Failure, List<RealisasiVisit>>> getRealisasiVisits(
      int idAtasan);

  /// Menyetujui realisasi visit
  Future<Either<Failure, String>> approveRealisasiVisit({
    required List<int> idRealisasiVisits,
    required int idUser,
  });

  /// Menolak realisasi visit
  Future<Either<Failure, String>> rejectRealisasiVisit({
    required List<int> idRealisasiVisits,
    required int idUser,
    required String reason,
  });

  /// Mendapatkan data realisasi visit khusus GM
  Future<Either<Failure, List<RealisasiVisitGM>>> getRealisasiVisitsGM(
      int idAtasan);

  /// Mendapatkan detail data realisasi visit GM untuk BCO tertentu
  Future<Either<Failure, List<RealisasiVisitGM>>> getRealisasiVisitsGMDetails(
      int idBCO);
}
