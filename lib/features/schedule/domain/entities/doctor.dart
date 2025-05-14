import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final int id;
  final String kodePelanggan;
  final String nama;
  final List<String> rayonDokter;
  final int spesialis;
  final String? statusDokter;
  final DateTime createdAt;
  final String kodeRayon;

  const Doctor({
    required this.id,
    required this.kodePelanggan,
    required this.nama,
    required this.rayonDokter,
    required this.spesialis,
    required this.statusDokter,
    required this.createdAt,
    required this.kodeRayon,
  });

  @override
  List<Object?> get props => [
        id,
        kodePelanggan,
        nama,
        rayonDokter,
        spesialis,
        statusDokter,
        createdAt,
        kodeRayon,
      ];
}
