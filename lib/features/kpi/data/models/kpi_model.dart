import 'package:equatable/equatable.dart';

class KpiResponse {
  final bool status;
  final List<KpiData> data;

  KpiResponse({
    required this.status,
    required this.data,
  });

  factory KpiResponse.fromJson(Map<String, dynamic> json) {
    return KpiResponse(
      status: json['status'] as bool,
      data: (json['data'] as List)
          .map((data) => KpiData.fromJson(data))
          .toList(),
    );
  }
}

class KpiData {
  final List<KpiGrafik> grafik;

  KpiData({required this.grafik});

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      grafik: (json['grafik'] as List)
          .map((grafik) => KpiGrafik.fromJson(grafik))
          .toList(),
    );
  }
}

class KpiGrafik extends Equatable {
  final String label;
  final KpiMetrics data;
  final String backgroundColor;

  const KpiGrafik({
    required this.label,
    required this.data,
    required this.backgroundColor,
  });

  factory KpiGrafik.fromJson(Map<String, dynamic> json) {
    return KpiGrafik(
      label: json['label'] as String,
      data: KpiMetrics.fromJson(json['data'] as Map<String, dynamic>),
      backgroundColor: json['backgroundColor'] as String,
    );
  }

  @override
  List<Object?> get props => [label, data, backgroundColor];
}

class KpiMetrics extends Equatable {
  final String ach;
  final String bobot;
  final String target;
  final String? realisasi;
  final String nilai;

  const KpiMetrics({
    required this.ach,
    required this.bobot,
    required this.target,
    this.realisasi,
    required this.nilai,
  });

  factory KpiMetrics.fromJson(Map<String, dynamic> json) {
    return KpiMetrics(
      ach: json['ach'].toString(),
      bobot: json['bobot'].toString(),
      target: json['target'].toString(),
      realisasi: json['realisasi']?.toString(),
      nilai: json['nilai'].toString(),
    );
  }

  @override
  List<Object?> get props => [ach, bobot, target, realisasi, nilai];
} 