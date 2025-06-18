import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class KpiResponse {
  final bool status;
  final String periode;
  final List<KpiData> dataKpiAtasan;
  final List<KpiBawahan>? dataKpiBawahan;

  KpiResponse({
    required this.status,
    required this.periode,
    required this.dataKpiAtasan,
    this.dataKpiBawahan,
  });

  factory KpiResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('KpiResponse parsing - status: ${json['status']}');
    debugPrint('KpiResponse parsing - periode: ${json['periode']}');
    
    try {
      return KpiResponse(
        status: json['status'] as bool? ?? false,
        periode: json['periode'] as String? ?? '',
        dataKpiAtasan: (json['data_kpi_atasan'] as List?)
            ?.map((data) => KpiData.fromJson(data))
            .toList() ?? [],
        dataKpiBawahan: json['data_kpi_bawahan'] != null
            ? (json['data_kpi_bawahan'] as List?)
                ?.map((data) => KpiBawahan.fromJson(data))
                .toList()
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing KpiResponse: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  KpiResponse copyWith({
    bool? status,
    String? periode,
    List<KpiData>? dataKpiAtasan,
    List<KpiBawahan>? dataKpiBawahan,
  }) {
    return KpiResponse(
      status: status ?? this.status,
      periode: periode ?? this.periode,
      dataKpiAtasan: dataKpiAtasan ?? List.from(this.dataKpiAtasan),
      dataKpiBawahan: dataKpiBawahan ?? this.dataKpiBawahan,
    );
  }
}

class KpiData {
  final String kodeRayon;
  final List<KpiGrafik> grafik;

  KpiData({
    required this.kodeRayon,
    required this.grafik,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    debugPrint('KpiData parsing - kodeRayon: ${json['kode_rayon']}');
    
    try {
      return KpiData(
        kodeRayon: json['kode_rayon'] as String? ?? '',
        grafik: (json['grafik'] as List?)
            ?.map((grafik) => KpiGrafik.fromJson(grafik))
            .toList() ?? [],
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing KpiData: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  KpiData copyWith({
    String? kodeRayon,
    List<KpiGrafik>? grafik,
  }) {
    return KpiData(
      kodeRayon: kodeRayon ?? this.kodeRayon,
      grafik: grafik ?? List.from(this.grafik),
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
    debugPrint('KpiGrafik parsing - label: ${json['label']}');
    
    try {
      return KpiGrafik(
        label: json['label'] as String? ?? '',
        data: KpiMetrics.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
        backgroundColor: json['backgroundColor'] as String? ?? '#000000',
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing KpiGrafik: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  KpiGrafik copyWith({
    String? label,
    KpiMetrics? data,
    String? backgroundColor,
  }) {
    return KpiGrafik(
      label: label ?? this.label,
      data: data ?? this.data,
      backgroundColor: backgroundColor ?? this.backgroundColor,
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
    debugPrint('KpiMetrics parsing - ach: ${json['ach']}, realisasi: ${json['realisasi']}');
    
    try {
      return KpiMetrics(
        ach: json['ach']?.toString() ?? '0',
        bobot: json['bobot']?.toString() ?? '0',
        target: json['target']?.toString() ?? '0',
        realisasi: json['realisasi']?.toString(),
        nilai: json['nilai']?.toString() ?? '0',
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing KpiMetrics: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  KpiMetrics copyWith({
    String? ach,
    String? bobot,
    String? target,
    String? realisasi,
    String? nilai,
  }) {
    return KpiMetrics(
      ach: ach ?? this.ach,
      bobot: bobot ?? this.bobot,
      target: target ?? this.target,
      realisasi: realisasi ?? this.realisasi,
      nilai: nilai ?? this.nilai,
    );
  }

  @override
  List<Object?> get props => [ach, bobot, target, realisasi, nilai];
}

class KpiBawahan {
  final String idUser;
  final String name;
  final String role;
  final List<KpiGrafik> grafik;

  KpiBawahan({
    required this.idUser,
    required this.name,
    required this.role,
    required this.grafik,
  });

  factory KpiBawahan.fromJson(Map<String, dynamic> json) {
    debugPrint('KpiBawahan parsing - idUser: ${json['id_user']}, name: ${json['name']}');
    
    try {
      return KpiBawahan(
        idUser: json['id_user'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        grafik: (json['grafik'] as List?)
            ?.map((grafik) => KpiGrafik.fromJson(grafik))
            .toList() ?? [],
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing KpiBawahan: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  KpiBawahan copyWith({
    String? idUser,
    String? name,
    String? role,
    List<KpiGrafik>? grafik,
  }) {
    return KpiBawahan(
      idUser: idUser ?? this.idUser,
      name: name ?? this.name,
      role: role ?? this.role,
      grafik: grafik ?? List.from(this.grafik),
    );
  }
} 