import 'package:equatable/equatable.dart';

class RealisasiVisit extends Equatable {
  final int idBawahan;
  final String namaBawahan;
  final String role;
  final int totalSchedule;
  final String jumlahDokter;
  final String jumlahKlinik;
  final String totalTerrealisasi;
  final int approved;
  final List<RealisasiVisitDetail> details;

  const RealisasiVisit({
    required this.idBawahan,
    required this.namaBawahan,
    required this.role,
    required this.totalSchedule,
    required this.jumlahDokter,
    required this.jumlahKlinik,
    required this.totalTerrealisasi,
    required this.approved,
    required this.details,
  });

  @override
  List<Object?> get props => [
        idBawahan,
        namaBawahan,
        role,
        totalSchedule,
        jumlahDokter,
        jumlahKlinik,
        totalTerrealisasi,
        approved,
        details,
      ];
}

class RealisasiVisitDetail extends Equatable {
  final int id;
  final String typeSchedule;
  final String tujuan;
  final int idTujuan;
  final String tglVisit;
  final String product;
  final String note;
  final String shift;
  final String jenis;
  final String? checkin;
  final String? fotoSelfie;
  final String? checkout;
  final String? fotoSelfieDua;
  final String statusTerrealisasi;
  final String? realisasiVisitApproved;
  final List<ProductData> productData;
  final TujuanData tujuanData;
  final String? lokasi;

  const RealisasiVisitDetail({
    required this.id,
    required this.typeSchedule,
    required this.tujuan,
    required this.idTujuan,
    required this.tglVisit,
    required this.product,
    required this.note,
    required this.shift,
    required this.jenis,
    this.checkin,
    this.fotoSelfie,
    this.checkout,
    this.fotoSelfieDua,
    required this.statusTerrealisasi,
    this.realisasiVisitApproved,
    required this.productData,
    required this.tujuanData,
    this.lokasi,
  });

  // Fungsi helper untuk mendapatkan daftar nama produk
  List<String> get productNames => productData
      .map((product) => product.namaProduct)
      .where((name) => name.isNotEmpty)
      .toList();

  // Fungsi helper untuk mendapatkan formatted text daftar produk
  String get formattedProductNames {
    if (productData.isEmpty) return '';
    return productNames.join(', ');
  }

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
        jenis,
        checkin,
        fotoSelfie,
        checkout,
        fotoSelfieDua,
        statusTerrealisasi,
        realisasiVisitApproved,
        productData,
        tujuanData,
        lokasi,
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

  const TujuanData({
    required this.idDokter,
    required this.namaDokter,
  });

  @override
  List<Object?> get props => [idDokter, namaDokter];
}
