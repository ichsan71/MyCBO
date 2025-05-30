import 'package:equatable/equatable.dart';

class DoctorClinicBase extends Equatable {
  final int id;
  final String nama;
  final String? alamat;
  final String? noTelp;
  final String? email;
  final String spesialis;
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

  @override
  List<Object?> get props => [
        id,
        nama,
        alamat,
        noTelp,
        email,
        spesialis,
        tipeDokter,
        tipeKlinik,
        kodeRayon,
      ];
}
