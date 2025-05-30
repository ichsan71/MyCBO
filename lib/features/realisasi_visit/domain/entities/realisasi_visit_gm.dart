import 'package:equatable/equatable.dart';
import 'realisasi_visit.dart';

class RealisasiVisitGM extends Equatable {
  final int idBawahan;
  final String namaBawahan;
  final String kodeRayon;
  final String roleUsers;
  final List<JumlahData> jumlah;
  final List<RealisasiVisitDetail> details;

  const RealisasiVisitGM({
    required this.idBawahan,
    required this.namaBawahan,
    required this.kodeRayon,
    required this.roleUsers,
    required this.jumlah,
    required this.details,
  });

  @override
  List<Object?> get props => [
        idBawahan,
        namaBawahan,
        kodeRayon,
        roleUsers,
        jumlah,
        details,
      ];
}

class JumlahData extends Equatable {
  final int total;
  final String realisasi;

  const JumlahData({
    required this.total,
    required this.realisasi,
  });

  @override
  List<Object?> get props => [total, realisasi];
}
