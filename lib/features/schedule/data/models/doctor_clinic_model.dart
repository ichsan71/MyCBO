import 'dart:convert';
import 'package:test_cbo/core/utils/logger.dart';
import '../../domain/entities/doctor_clinic_base.dart';

class DoctorClinicModel extends DoctorClinicBase {
  const DoctorClinicModel({
    required int id,
    required String nama,
    required String spesialis,
    String? alamat,
    String? noTelp,
    String? email,
    String? tipeDokter,
    String? tipeKlinik,
    String? kodeRayon,
  }) : super(
          id: id,
          nama: nama,
          spesialis: spesialis,
          alamat: alamat,
          noTelp: noTelp,
          email: email,
          tipeDokter: tipeDokter,
          tipeKlinik: tipeKlinik,
          kodeRayon: kodeRayon,
        );

  factory DoctorClinicModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.debug('DoctorClinicModel', '🔍 Starting to parse doctor data');
      Logger.debug('DoctorClinicModel', '🔍 Input JSON: $json');

      // Parse ID - try different possible field names and handle string IDs
      int id = 0;
      dynamic rawId = json['id_dokter'] ?? json['id'];
      Logger.debug('DoctorClinicModel',
          '🔍 Raw ID value: $rawId (type: ${rawId?.runtimeType})');

      if (rawId != null) {
        if (rawId is int) {
          id = rawId;
          Logger.debug('DoctorClinicModel', '✅ ID is already an integer: $id');
        } else if (rawId is String) {
          // Try to parse string as int, handle both numeric and non-numeric strings
          String cleanId = rawId.replaceAll(RegExp(r'[^0-9]'), '');
          Logger.debug('DoctorClinicModel', '🔍 Cleaned ID string: $cleanId');
          id = int.tryParse(cleanId) ?? 0;
          Logger.debug('DoctorClinicModel', '🔍 Parsed ID result: $id');
        }
      }

      if (id == 0) {
        Logger.warning('DoctorClinicModel',
            '⚠️ No valid ID found in data. Raw ID: $rawId');
        throw const FormatException('Invalid doctor data: ID is missing or invalid');
      }

      // Parse name - try different possible field names
      String nama = '';
      Logger.debug('DoctorClinicModel', '🔍 Checking name fields...');
      Logger.debug(
          'DoctorClinicModel', '  - nama_dokter: ${json['nama_dokter']}');
      Logger.debug('DoctorClinicModel', '  - nama: ${json['nama']}');

      if (json['nama_dokter'] != null &&
          json['nama_dokter'].toString().trim().isNotEmpty) {
        nama = json['nama_dokter'].toString().trim();
        Logger.debug('DoctorClinicModel', '✅ Using nama_dokter: $nama');
      } else if (json['nama'] != null &&
          json['nama'].toString().trim().isNotEmpty) {
        nama = json['nama'].toString().trim();
        Logger.debug('DoctorClinicModel', '✅ Using nama: $nama');
      }

      if (nama.isEmpty) {
        Logger.warning('DoctorClinicModel', '⚠️ No valid name found in data');
        throw const FormatException('Invalid doctor data: Name is missing or empty');
      }

      // Parse specialist information
      String spesialis = '';
      Logger.debug('DoctorClinicModel', '🔍 Checking specialist fields...');
      Logger.debug(
          'DoctorClinicModel', '  - nama_spesialis: ${json['nama_spesialis']}');
      Logger.debug('DoctorClinicModel', '  - spesialis: ${json['spesialis']}');

      if (json['nama_spesialis'] != null &&
          json['nama_spesialis'].toString().trim().isNotEmpty) {
        spesialis = json['nama_spesialis'].toString().trim();
        Logger.debug('DoctorClinicModel', '✅ Using nama_spesialis: $spesialis');
      } else if (json['spesialis'] != null) {
        if (json['spesialis'] is int) {
          final spesialisId = json['spesialis'] as int;
          spesialis = _getSpesialisName(spesialisId);
          Logger.debug('DoctorClinicModel',
              '✅ Using spesialis ID: $spesialisId -> $spesialis');
        } else if (json['spesialis'] is String &&
            json['spesialis'].toString().trim().isNotEmpty) {
          final spesialisId = int.tryParse(json['spesialis'].toString().trim());
          if (spesialisId != null) {
            spesialis = _getSpesialisName(spesialisId);
            Logger.debug('DoctorClinicModel',
                '✅ Parsed spesialis string to ID: $spesialisId -> $spesialis');
          } else {
            spesialis = json['spesialis'].toString().trim();
            Logger.debug('DoctorClinicModel',
                '✅ Using spesialis string directly: $spesialis');
          }
        }
      }

      // Parse doctor type/status
      String? tipeDokter;
      Logger.debug('DoctorClinicModel', '🔍 Checking doctor type fields...');
      Logger.debug(
          'DoctorClinicModel', '  - status_dokter: ${json['status_dokter']}');
      Logger.debug(
          'DoctorClinicModel', '  - tipe_dokter: ${json['tipe_dokter']}');

      if (json['status_dokter'] != null &&
          json['status_dokter'].toString().trim().isNotEmpty) {
        tipeDokter = json['status_dokter'].toString().trim();
        Logger.debug('DoctorClinicModel', '✅ Using status_dokter: $tipeDokter');
      } else if (json['tipe_dokter'] != null &&
          json['tipe_dokter'].toString().trim().isNotEmpty) {
        tipeDokter = json['tipe_dokter'].toString().trim();
        Logger.debug('DoctorClinicModel', '✅ Using tipe_dokter: $tipeDokter');
      }

      // Parse rayon code
      String? kodeRayon;
      Logger.debug('DoctorClinicModel', '🔍 Checking rayon fields...');
      Logger.debug(
          'DoctorClinicModel', '  - kode_rayon: ${json['kode_rayon']}');
      Logger.debug(
          'DoctorClinicModel', '  - rayon_dokter: ${json['rayon_dokter']}');

      if (json['kode_rayon'] != null &&
          json['kode_rayon'].toString().trim().isNotEmpty) {
        kodeRayon = json['kode_rayon'].toString().trim();
        Logger.debug('DoctorClinicModel', '✅ Using kode_rayon: $kodeRayon');
      } else if (json['rayon_dokter'] != null) {
        try {
          final rayonData = json['rayon_dokter'];
          Logger.debug('DoctorClinicModel',
              '🔍 Processing rayon_dokter: $rayonData (type: ${rayonData.runtimeType})');

          if (rayonData is String && rayonData.trim().isNotEmpty) {
            if (rayonData.startsWith('[') && rayonData.endsWith(']')) {
              final List<dynamic> rayonList = jsonDecode(rayonData);
              if (rayonList.isNotEmpty) {
                kodeRayon = rayonList.join(', ');
                Logger.debug('DoctorClinicModel',
                    '✅ Parsed rayon_dokter string to list: $kodeRayon');
              }
            } else {
              kodeRayon = rayonData.trim();
              Logger.debug('DoctorClinicModel',
                  '✅ Using rayon_dokter string directly: $kodeRayon');
            }
          } else if (rayonData is List && rayonData.isNotEmpty) {
            kodeRayon = rayonData.join(', ');
            Logger.debug(
                'DoctorClinicModel', '✅ Joined rayon_dokter list: $kodeRayon');
          }
        } catch (e) {
          Logger.warning(
              'DoctorClinicModel', '⚠️ Error parsing rayon_dokter: $e');
        }
      }

      // Log parsed data
      Logger.info('DoctorClinicModel', '✅ Successfully parsed doctor data:');
      Logger.debug('DoctorClinicModel', '  - ID: $id');
      Logger.debug('DoctorClinicModel', '  - Nama: $nama');
      Logger.debug('DoctorClinicModel', '  - Spesialis: $spesialis');
      Logger.debug('DoctorClinicModel', '  - Tipe Dokter: $tipeDokter');
      Logger.debug('DoctorClinicModel', '  - Kode Rayon: $kodeRayon');

      return DoctorClinicModel(
        id: id,
        nama: nama,
        spesialis: spesialis,
        tipeDokter: tipeDokter,
        kodeRayon: kodeRayon,
        alamat: null,
        noTelp: null,
        email: null,
        tipeKlinik: null,
      );
    } catch (e, stackTrace) {
      Logger.error('DoctorClinicModel', '❌ Error parsing doctor data: $e');
      Logger.error('DoctorClinicModel', '❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  static String _getSpesialisName(int spesialisId) {
    switch (spesialisId) {
      case 1:
        return 'Umum';
      case 2:
        return 'Kandungan';
      case 3:
        return 'Anak';
      case 4:
        return 'Spesialis Kulit';
      case 5:
        return 'Penyakit Dalam';
      case 6:
        return 'Jantung';
      case 7:
        return 'Gigi';
      case 8:
        return 'THT';
      case 9:
        return 'Bedah';
      case 10:
        return 'Mata';
      default:
        return 'Lainnya';
    }
  }
}
