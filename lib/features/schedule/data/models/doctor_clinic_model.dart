import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic.dart';

class DoctorClinicModel extends DoctorClinic {
  const DoctorClinicModel({
    required int id,
    required String nama,
    required String alamat,
    required String noTelp,
    required String email,
    required String spesialis,
    required String tipeDokter,
    required String tipeKlinik,
    required String kodeRayon,
  }) : super(
          id: id,
          nama: nama,
          alamat: alamat,
          noTelp: noTelp,
          email: email,
          spesialis: spesialis,
          tipeDokter: tipeDokter,
          tipeKlinik: tipeKlinik,
          kodeRayon: kodeRayon,
        );

  factory DoctorClinicModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse id, handling different types
      int id;
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        id = int.tryParse(json['id']) ?? 0;
      } else if (json['id_dokter'] is int) {
        id = json['id_dokter'];
      } else if (json['id_dokter'] is String) {
        id = int.tryParse(json['id_dokter']) ?? 0;
      } else {
        id = 0;
      }

      // Parse nama, handling different field names
      String nama = '';
      if (json['nama'] != null) {
        nama = json['nama'].toString();
      } else if (json['name'] != null) {
        nama = json['name'].toString();
      } else if (json['nama_dokter'] != null) {
        nama = json['nama_dokter'].toString();
      }

      // Parse alamat
      String alamat = '';
      if (json['alamat'] != null) {
        alamat = json['alamat'].toString();
      } else if (json['address'] != null) {
        alamat = json['address'].toString();
      }

      // Parse noTelp
      String noTelp = '';
      if (json['no_telp'] != null) {
        noTelp = json['no_telp'].toString();
      } else if (json['phone'] != null) {
        noTelp = json['phone'].toString();
      } else if (json['telepon'] != null) {
        noTelp = json['telepon'].toString();
      }

      // Parse email
      String email = '';
      if (json['email'] != null) {
        email = json['email'].toString();
      }

      // Parse spesialis
      String spesialis = '';
      if (json['spesialis'] != null) {
        spesialis = json['spesialis'].toString();
      } else if (json['specialist'] != null) {
        spesialis = json['specialist'].toString();
      } else if (json['nama_spesialis'] != null) {
        spesialis = json['nama_spesialis'].toString();
      }

      // Parse tipeDokter
      String tipeDokter = '';
      if (json['tipe_dokter'] != null) {
        tipeDokter = json['tipe_dokter'].toString();
      } else if (json['doctor_type'] != null) {
        tipeDokter = json['doctor_type'].toString();
      }

      // Parse tipeKlinik
      String tipeKlinik = '';
      if (json['tipe_klinik'] != null) {
        tipeKlinik = json['tipe_klinik'].toString();
      } else if (json['clinic_type'] != null) {
        tipeKlinik = json['clinic_type'].toString();
      }

      // Parse kodeRayon
      String kodeRayon = '';
      if (json['kode_rayon'] != null) {
        kodeRayon = json['kode_rayon'].toString();
      } else if (json['rayon_code'] != null) {
        kodeRayon = json['rayon_code'].toString();
      }

      Logger.info('DoctorClinicModel', 'Parsing data - id: $id, nama: $nama');

      return DoctorClinicModel(
        id: id,
        nama: nama,
        alamat: alamat,
        noTelp: noTelp,
        email: email,
        spesialis: spesialis,
        tipeDokter: tipeDokter,
        tipeKlinik: tipeKlinik,
        kodeRayon: kodeRayon,
      );
    } catch (e) {
      Logger.error('DoctorClinicModel', 'Error parsing DoctorClinicModel: $e');
      Logger.error('DoctorClinicModel', 'JSON data: $json');
      // Return a default model if parsing fails
      return const DoctorClinicModel(
        id: 0,
        nama: 'Error',
        alamat: '',
        noTelp: '',
        email: '',
        spesialis: '',
        tipeDokter: '',
        tipeKlinik: '',
        kodeRayon: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'email': email,
      'spesialis': spesialis,
      'tipe_dokter': tipeDokter,
      'tipe_klinik': tipeKlinik,
      'kode_rayon': kodeRayon,
    };
  }
}
