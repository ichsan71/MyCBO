import 'dart:convert';

import 'package:test_cbo/core/utils/logger.dart';

class DoctorModel {
  final int id;
  final String kodePelanggan;
  final String nama;
  final List<String> rayonDokter;
  final int spesialis;
  final dynamic statusDokter;
  final DateTime createdAt;
  final String kodeRayon;

  const DoctorModel({
    required this.id,
    required this.kodePelanggan,
    required this.nama,
    required this.rayonDokter,
    required this.spesialis,
    required this.statusDokter,
    required this.createdAt,
    required this.kodeRayon,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id_dokter'] as int,
      kodePelanggan: json['kode_pelanggan'] as String,
      nama: json['nama_dokter'] as String,
      rayonDokter: _parseRayonDokter(json['rayon_dokter']),
      spesialis: json['spesialis'] as int,
      statusDokter: json['status_dokter'],
      createdAt: DateTime.parse(json['created_at'] as String),
      kodeRayon: json['kode_rayon'] as String,
    );
  }

  static List<String> _parseRayonDokter(dynamic rayonDokter) {
    if (rayonDokter is String) {
      try {
        final List<dynamic> decoded = json.decode(rayonDokter);
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        Logger.error('DoctorModel', 'Error parsing rayon_dokter: $e');
        return [rayonDokter];
      }
    } else if (rayonDokter is List) {
      return rayonDokter.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dokter': id,
      'kode_pelanggan': kodePelanggan,
      'nama_dokter': nama,
      'rayon_dokter': json.encode(rayonDokter),
      'spesialis': spesialis,
      'status_dokter': statusDokter,
      'created_at': createdAt.toIso8601String(),
      'kode_rayon': kodeRayon,
    };
  }
}
