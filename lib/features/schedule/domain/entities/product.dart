import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int idProduct;
  final String? kode;
  final String namaProduct;
  final String? idDivisiSales;
  final String? idSpesialis;
  final int? hargaNormal;
  final String? desc;
  final String? image;
  final String? createdAt;
  final String nama;
  final String keterangan;
  final int id;

  const Product({
    required this.idProduct,
    this.kode,
    required this.namaProduct,
    this.idDivisiSales,
    this.idSpesialis,
    this.hargaNormal,
    this.desc,
    this.image,
    this.createdAt,
    required this.nama,
    required this.keterangan,
    required this.id,
  });

  @override
  List<Object?> get props => [
        idProduct,
        kode,
        namaProduct,
        idDivisiSales,
        idSpesialis,
        hargaNormal,
        desc,
        image,
        createdAt,
        nama,
        keterangan,
        id,
      ];
}
