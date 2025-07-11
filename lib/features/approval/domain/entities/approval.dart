import 'package:equatable/equatable.dart';

class Approval extends Equatable {
  final int id;
  final int userId;
  final String namaBawahan;
  final String tglVisit;
  final String tujuan;
  final String note;
  final bool isApproved;
  final int approved;
  final int idBawahan;
  final int month;
  final int year;
  final int totalSchedule;
  final String jumlahDokter;
  final String jumlahKlinik;
  final List<Detail> details;

  const Approval({
    required this.id,
    required this.userId,
    required this.namaBawahan,
    required this.tglVisit,
    required this.tujuan,
    required this.note,
    required this.isApproved,
    required this.approved,
    required this.idBawahan,
    required this.month,
    required this.year,
    required this.totalSchedule,
    required this.jumlahDokter,
    required this.jumlahKlinik,
    required this.details,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        namaBawahan,
        tglVisit,
        tujuan,
        note,
        isApproved,
        approved,
        idBawahan,
        month,
        year,
        totalSchedule,
        jumlahDokter,
        jumlahKlinik,
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
  final int? realisasiApprove;

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
    this.realisasiApprove,
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
        realisasiApprove,
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
