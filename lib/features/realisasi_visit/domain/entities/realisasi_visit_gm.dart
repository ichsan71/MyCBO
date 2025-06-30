import 'package:equatable/equatable.dart';
import 'realisasi_visit.dart';

class RealisasiVisitGM extends Equatable {
  final int id;
  final String name;
  final String kodeRayon;
  final String roleUsers;
  final List<JumlahGM> jumlah;
  final List<RealisasiVisitDetail> details;

  const RealisasiVisitGM({
    required this.id,
    required this.name,
    required this.kodeRayon,
    required this.roleUsers,
    required this.jumlah,
    required this.details,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        kodeRayon,
        roleUsers,
        jumlah,
        details,
      ];
}

class JumlahGM extends Equatable {
  final int total;
  final String realisasi;

  const JumlahGM({
    required this.total,
    required this.realisasi,
  });

  @override
  List<Object?> get props => [total, realisasi];
}
