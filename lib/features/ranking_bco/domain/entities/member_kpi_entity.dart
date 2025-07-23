class MemberKpiEntity {
  final String kodeRayon;
  final List<MemberKpiGrafikEntity> grafik;

  MemberKpiEntity({required this.kodeRayon, required this.grafik});
}

class MemberKpiGrafikEntity {
  final String label;
  final MemberKpiGrafikDataEntity data;
  final String backgroundColor;

  MemberKpiGrafikEntity({
    required this.label,
    required this.data,
    required this.backgroundColor,
  });
}

class MemberKpiGrafikDataEntity {
  final String ach;
  final String bobot;
  final String target;
  final String? realisasi;
  final String nilai;

  MemberKpiGrafikDataEntity({
    required this.ach,
    required this.bobot,
    required this.target,
    required this.realisasi,
    required this.nilai,
  });
}
