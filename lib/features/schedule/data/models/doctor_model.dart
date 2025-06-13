import 'dart:convert';

import 'package:test_cbo/core/utils/logger.dart';

class DoctorModel {
  final int id;
  final String kodePelanggan;
  final String nama;
  final List<String> rayonDokter;
  final int spesialis;
  final String? statusDokter;
  final DateTime createdAt;
  final String kodeRayon;
  final String? namaSpesialis;

  const DoctorModel({
    required this.id,
    required this.kodePelanggan,
    required this.nama,
    required this.rayonDokter,
    required this.spesialis,
    this.statusDokter,
    required this.createdAt,
    required this.kodeRayon,
    this.namaSpesialis,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('DoctorModel',
          'Parsing doctor data with keys: ${json.keys.toList()}');

      // Parse ID
      int id;
      if (json['id_dokter'] is int) {
        id = json['id_dokter'];
      } else if (json['id_dokter'] is String) {
        id = int.tryParse(json['id_dokter']) ?? 0;
      } else {
        id = 0;
        Logger.error('DoctorModel', 'Invalid id_dokter: ${json['id_dokter']}');
      }

      // Parse spesialis
      int spesialis;
      if (json['spesialis'] is int) {
        spesialis = json['spesialis'];
      } else if (json['spesialis'] is String) {
        spesialis = int.tryParse(json['spesialis']) ?? 0;
      } else {
        spesialis = 0;
        Logger.error('DoctorModel', 'Invalid spesialis: ${json['spesialis']}');
      }

      return DoctorModel(
        id: id,
        kodePelanggan: json['kode_pelanggan']?.toString() ?? '',
        nama: json['nama_dokter']?.toString() ?? '',
        rayonDokter: _parseRayonDokter(json['rayon_dokter']),
        spesialis: spesialis,
        statusDokter: json['status_dokter']?.toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        kodeRayon: json['kode_rayon']?.toString() ?? '',
        namaSpesialis: json['nama_spesialis']?.toString(),
      );
    } catch (e, stackTrace) {
      Logger.error('DoctorModel', 'Error parsing doctor data: $e');
      Logger.error('DoctorModel', 'Stack trace: $stackTrace');
      Logger.error('DoctorModel', 'JSON data: $json');
      rethrow;
    }
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
      'nama_spesialis': namaSpesialis,
    };
  }
}
