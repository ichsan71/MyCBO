import '../../domain/entities/bco_ranking_entity.dart';

class BcoRankingModel {
  final int userId;
  final String name;
  final String kodeRayon;
  final double dataKpi;
  final String roleUser;
  final List<IndikatorModel> indikator;

  BcoRankingModel({
    required this.userId,
    required this.name,
    required this.kodeRayon,
    required this.dataKpi,
    required this.roleUser,
    required this.indikator,
  });

  factory BcoRankingModel.fromJson(Map<String, dynamic> json) {
    return BcoRankingModel(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      kodeRayon: json['kode_rayon'] as String,
      dataKpi: double.tryParse(json['data_kpi'].toString()) ?? 0.0,
      roleUser: json['role_user'] as String,
      indikator: (json['indikator'] as List<dynamic>?)
              ?.map((e) => IndikatorModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  BcoRankingEntity toEntity() {
    return BcoRankingEntity(
      userId: userId,
      name: name,
      kodeRayon: kodeRayon,
      dataKpi: dataKpi,
      roleUser: roleUser,
      indikator: indikator.map((e) => e.toEntity()).toList(),
    );
  }
}

class IndikatorModel {
  final String indikator;
  final String nilai;
  final String target;
  final String bobot;
  final dynamic realisasi;

  IndikatorModel({
    required this.indikator,
    required this.nilai,
    required this.target,
    required this.bobot,
    required this.realisasi,
  });

  factory IndikatorModel.fromJson(Map<String, dynamic> json) {
    return IndikatorModel(
      indikator: json['indikator'] as String,
      nilai: json['nilai'].toString(),
      target: json['target'].toString(),
      bobot: json['bobot'].toString(),
      realisasi: json['realisasi'],
    );
  }

  IndikatorEntity toEntity() {
    return IndikatorEntity(
      indikator: indikator,
      nilai: nilai,
      target: target,
      bobot: bobot,
      realisasi: realisasi,
    );
  }
}
