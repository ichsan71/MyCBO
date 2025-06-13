import 'package:equatable/equatable.dart';

class DoctorClinicBase extends Equatable {
  final int id;
  final String nama;
  final String spesialis;
  final String? alamat;
  final String? noTelp;
  final String? email;
  final String? tipeDokter;
  final String? tipeKlinik;
  final String? kodeRayon;

  const DoctorClinicBase({
    required this.id,
    required this.nama,
    required this.spesialis,
    this.alamat,
    this.noTelp,
    this.email,
    this.tipeDokter,
    this.tipeKlinik,
    this.kodeRayon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'spesialis': spesialis,
      'alamat': alamat,
      'no_telp': noTelp,
      'email': email,
      'tipe_dokter': tipeDokter,
      'tipe_klinik': tipeKlinik,
      'kode_rayon': kodeRayon,
    };
  }

  @override
  List<Object?> get props => [
        id,
        nama,
        spesialis,
        alamat,
        noTelp,
        email,
        tipeDokter,
        tipeKlinik,
        kodeRayon
      ];

  @override
  String toString() {
    return 'DoctorClinicBase(id: $id, nama: $nama, spesialis: $spesialis)';
  }
}
