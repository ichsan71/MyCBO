import 'package:equatable/equatable.dart';

class Approval extends Equatable {
  final int idBawahan;
  final String namaBawahan;
  final int totalSchedule;
  final int year;
  final int month;
  final String jumlahDokter;
  final String jumlahKlinik;
  final int approved;
  final List<Detail> details;

  const Approval({
    required this.idBawahan,
    required this.namaBawahan,
    required this.totalSchedule,
    required this.year,
    required this.month,
    required this.jumlahDokter,
    required this.jumlahKlinik,
    required this.approved,
    required this.details,
  });

  @override
  List<Object?> get props => [
        idBawahan,
        namaBawahan,
        totalSchedule,
        year,
        month,
        jumlahDokter,
        jumlahKlinik,
        approved,
        details,
      ];
}

class Detail extends Equatable {
  final int id;
  final String typeSchedule;
  final String tujuan;
  final int idTujuan;
  final String tglVisit;
  final String product;
  final String note;
  final String shift;
  final List<ProductData> productData;
  final TujuanData tujuanData;
  final int approved;

  const Detail({
    required this.id,
    required this.typeSchedule,
    required this.tujuan,
    required this.idTujuan,
    required this.tglVisit,
    required this.product,
    required this.note,
    required this.shift,
    required this.productData,
    required this.tujuanData,
    required this.approved,
  });

  @override
  List<Object?> get props => [
        id,
        typeSchedule,
        tujuan,
        idTujuan,
        tglVisit,
        product,
        note,
        shift,
        productData,
        tujuanData,
        approved,
      ];
}

class ProductData extends Equatable {
  final int idProduct;
  final String namaProduct;

  const ProductData({
    required this.idProduct,
    required this.namaProduct,
  });

  @override
  List<Object?> get props => [idProduct, namaProduct];
}

class TujuanData extends Equatable {
  final int idDokter;
  final String namaDokter;
  final String namaKlinik;

  const TujuanData({
    required this.idDokter,
    required this.namaDokter,
    required this.namaKlinik,
  });

  @override
  List<Object?> get props => [idDokter, namaDokter, namaKlinik];
}
