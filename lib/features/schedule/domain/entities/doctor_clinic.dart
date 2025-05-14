import 'package:equatable/equatable.dart';

class DoctorClinic extends Equatable {
  final int id;
  final String nama;
  final String alamat;
  final String noTelp;
  final String email;
  final String spesialis;
  final String tipeDokter;
  final String tipeKlinik;
  final String kodeRayon;

  const DoctorClinic({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.noTelp,
    required this.email,
    required this.spesialis,
    required this.tipeDokter,
    required this.tipeKlinik,
    required this.kodeRayon,
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
