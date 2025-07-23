import '../../domain/entities/member_kpi_entity.dart';

class MemberKpiModel extends MemberKpiEntity {
  MemberKpiModel(
      {required String kodeRayon, required List<MemberKpiGrafikModel> grafik})
      : super(kodeRayon: kodeRayon, grafik: grafik);

  factory MemberKpiModel.fromJson(Map<String, dynamic> json) {
    return MemberKpiModel(
      kodeRayon: json['kode_rayon'] ?? '',
      grafik: (json['grafik'] as List<dynamic>?)
              ?.map((e) => MemberKpiGrafikModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MemberKpiGrafikModel extends MemberKpiGrafikEntity {
  MemberKpiGrafikModel({
    required String label,
    required MemberKpiGrafikDataModel data,
    required String backgroundColor,
  }) : super(label: label, data: data, backgroundColor: backgroundColor);

  factory MemberKpiGrafikModel.fromJson(Map<String, dynamic> json) {
    return MemberKpiGrafikModel(
      label: json['label'] ?? '',
      data: MemberKpiGrafikDataModel.fromJson(json['data'] ?? {}),
      backgroundColor: json['backgroundColor'] ?? '',
    );
  }
}

class MemberKpiGrafikDataModel extends MemberKpiGrafikDataEntity {
  MemberKpiGrafikDataModel({
    required String ach,
    required String bobot,
    required String target,
    required String? realisasi,
    required String nilai,
  }) : super(
          ach: ach,
          bobot: bobot,
          target: target,
          realisasi: realisasi,
          nilai: nilai,
        );

  factory MemberKpiGrafikDataModel.fromJson(Map<String, dynamic> json) {
    return MemberKpiGrafikDataModel(
      ach: json['ach'] ?? '',
      bobot: json['bobot'] ?? '',
      target: json['target'] ?? '',
      realisasi: json['realisasi']?.toString(),
      nilai: json['nilai'] ?? '',
    );
  }
}
