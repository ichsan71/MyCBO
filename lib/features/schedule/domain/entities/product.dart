import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String nama;
  final String keterangan;
  final String kodeRayon;

  const Product({
    required this.id,
    required this.nama,
    required this.keterangan,
    required this.kodeRayon,
  });

  @override
  List<Object?> get props => [id, nama, keterangan, kodeRayon];
} 