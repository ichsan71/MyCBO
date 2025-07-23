import 'package:equatable/equatable.dart';

class BcoRankingEntity extends Equatable {
  final int userId;
  final String name;
  final String kodeRayon;
  final double dataKpi;
  final String roleUser;
  final List<IndikatorEntity> indikator;

  const BcoRankingEntity({
    required this.userId,
    required this.name,
    required this.kodeRayon,
    required this.dataKpi,
    required this.roleUser,
    required this.indikator,
  });

  @override
  List<Object?> get props =>
      [userId, name, kodeRayon, dataKpi, roleUser, indikator];
}

class IndikatorEntity extends Equatable {
  final String indikator;
  final String nilai;
  final String target;
  final String bobot;
  final dynamic realisasi;

  const IndikatorEntity({
    required this.indikator,
    required this.nilai,
    required this.target,
    required this.bobot,
    required this.realisasi,
  });

  @override
  List<Object?> get props => [indikator, nilai, target, bobot, realisasi];
}
