import '../../domain/entities/approval.dart';

class ApprovalModel extends Approval {
  const ApprovalModel({
    required int idBawahan,
    required String namaBawahan,
    required int totalSchedule,
    required int year,
    required int month,
    required String jumlahDokter,
    required String jumlahKlinik,
    required int approved,
    required List<DetailModel> details,
  }) : super(
          idBawahan: idBawahan,
          namaBawahan: namaBawahan,
          totalSchedule: totalSchedule,
          year: year,
          month: month,
          jumlahDokter: jumlahDokter,
          jumlahKlinik: jumlahKlinik,
          approved: approved,
          details: details,
        );

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      idBawahan: json['id_bawahan'],
      namaBawahan: json['nama_bawahan'],
      totalSchedule: json['total_schedule'],
      year: json['year'],
      month: json['month'],
      jumlahDokter: json['jumlah_dokter'],
      jumlahKlinik: json['jumlah_klinik'],
      approved: json['approved'],
      details: (json['details'] as List)
          .map((detail) => DetailModel.fromJson(detail))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bawahan': idBawahan,
      'nama_bawahan': namaBawahan,
      'total_schedule': totalSchedule,
      'year': year,
      'month': month,
      'jumlah_dokter': jumlahDokter,
      'jumlah_klinik': jumlahKlinik,
      'approved': approved,
      'details':
          details.map((detail) => (detail as DetailModel).toJson()).toList(),
    };
  }
}

class DetailModel extends Detail {
  const DetailModel({
    required int id,
    required String typeSchedule,
    required String tujuan,
    required int idTujuan,
    required String tglVisit,
    required String product,
    required String note,
    required String shift,
    required List<ProductDataModel> productData,
    required TujuanDataModel tujuanData,
    int approved = 0,
  }) : super(
          id: id,
          typeSchedule: typeSchedule,
          tujuan: tujuan,
          idTujuan: idTujuan,
          tglVisit: tglVisit,
          product: product,
          note: note,
          shift: shift,
          productData: productData,
          tujuanData: tujuanData,
          approved: approved,
        );

  factory DetailModel.fromJson(Map<String, dynamic> json) {
    return DetailModel(
      id: json['id'],
      typeSchedule: json['type_schedule'],
      tujuan: json['tujuan'],
      idTujuan: json['id_tujuan'],
      tglVisit: json['tgl_visit'],
      product: json['product'],
      note: json['note'],
      shift: json['shift'],
      productData: (json['product_data'] as List)
          .map((product) => ProductDataModel.fromJson(product))
          .toList(),
      tujuanData: TujuanDataModel.fromJson(json['tujuan_data']),
      approved: json['approved'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_schedule': typeSchedule,
      'tujuan': tujuan,
      'id_tujuan': idTujuan,
      'tgl_visit': tglVisit,
      'product': product,
      'note': note,
      'shift': shift,
      'product_data': productData
          .map((product) => (product as ProductDataModel).toJson())
          .toList(),
      'tujuan_data': (tujuanData as TujuanDataModel).toJson(),
      'approved': approved,
    };
  }
}

class ProductDataModel extends ProductData {
  const ProductDataModel({
    required int idProduct,
    required String namaProduct,
  }) : super(
          idProduct: idProduct,
          namaProduct: namaProduct,
        );

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      idProduct: json['id_product'],
      namaProduct: json['nama_product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'nama_product': namaProduct,
    };
  }
}

class TujuanDataModel extends TujuanData {
  const TujuanDataModel({
    required int idDokter,
    required String namaDokter,
  }) : super(
          idDokter: idDokter,
          namaDokter: namaDokter,
        );

  factory TujuanDataModel.fromJson(Map<String, dynamic> json) {
    return TujuanDataModel(
      idDokter: json['id_dokter'],
      namaDokter: json['nama_dokter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dokter': idDokter,
      'nama_dokter': namaDokter,
    };
  }
}
