import 'dart:convert';
import '../../domain/entities/monthly_approval.dart';

class MonthlyApprovalModel extends MonthlyApproval {
  const MonthlyApprovalModel({
    required int idBawahan,
    required String namaBawahan,
    required int totalSchedule,
    required int year,
    required int month,
    required String jumlahDokter,
    required String jumlahKlinik,
    required int approved,
    required List<MonthlyScheduleDetailModel> details,
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

  factory MonthlyApprovalModel.fromJson(Map<String, dynamic> json) {
    return MonthlyApprovalModel(
      idBawahan: json['id_bawahan'],
      namaBawahan: json['nama_bawahan'],
      totalSchedule: json['total_schedule'],
      year: json['year'],
      month: json['month'],
      jumlahDokter: json['jumlah_dokter'],
      jumlahKlinik: json['jumlah_klinik'],
      approved: json['approved'],
      details: (json['details'] as List)
          .map((detail) => MonthlyScheduleDetailModel.fromJson(detail))
          .toList(),
    );
  }

  MonthlyApproval toEntity() {
    return MonthlyApproval(
      idBawahan: idBawahan,
      namaBawahan: namaBawahan,
      totalSchedule: totalSchedule,
      year: year,
      month: month,
      jumlahDokter: jumlahDokter,
      jumlahKlinik: jumlahKlinik,
      approved: approved,
      details: details.map((detail) => detail.toEntity()).toList(),
    );
  }
}

class MonthlyScheduleDetailModel extends MonthlyScheduleDetail {
  const MonthlyScheduleDetailModel({
    required int id,
    required String typeSchedule,
    required String tujuan,
    required int idTujuan,
    required String tglVisit,
    required List<String> product,
    required String note,
    required String shift,
    required List<ProductDataModel> productData,
    required TujuanDataModel tujuanData,
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
        );

  factory MonthlyScheduleDetailModel.fromJson(Map<String, dynamic> json) {
    return MonthlyScheduleDetailModel(
      id: json['id'],
      typeSchedule: json['type_schedule'],
      tujuan: json['tujuan'],
      idTujuan: json['id_tujuan'],
      tglVisit: json['tgl_visit'],
      product: List<String>.from(jsonDecode(json['product'])),
      note: json['note'],
      shift: json['shift'],
      productData: (json['product_data'] as List)
          .map((product) => ProductDataModel.fromJson(product))
          .toList(),
      tujuanData: TujuanDataModel.fromJson(json['tujuan_data']),
    );
  }

  MonthlyScheduleDetail toEntity() {
    return MonthlyScheduleDetail(
      id: id,
      typeSchedule: typeSchedule,
      tujuan: tujuan,
      idTujuan: idTujuan,
      tglVisit: tglVisit,
      product: product,
      note: note,
      shift: shift,
      productData: productData.map((data) => data.toEntity()).toList(),
      tujuanData: tujuanData.toEntity(),
    );
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

  ProductData toEntity() {
    return ProductData(
      idProduct: idProduct,
      namaProduct: namaProduct,
    );
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

  TujuanData toEntity() {
    return TujuanData(
      idDokter: idDokter,
      namaDokter: namaDokter,
    );
  }
}
