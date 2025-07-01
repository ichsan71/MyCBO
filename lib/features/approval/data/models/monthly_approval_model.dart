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
    // Helper function untuk parse integer dengan null safety
    int parseIntSafely(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return MonthlyApprovalModel(
      // Support both GM format (id_user, nama) and regular format (id_bawahan, nama_bawahan)
      idBawahan: parseIntSafely(json['id_bawahan'] ?? json['id_user']),
      namaBawahan:
          json['nama_bawahan']?.toString() ?? json['nama']?.toString() ?? '',
      totalSchedule: parseIntSafely(json['total_schedule']),
      year: parseIntSafely(json['year']),
      month: parseIntSafely(json['month']),
      jumlahDokter: json['jumlah_dokter']?.toString() ?? '0',
      jumlahKlinik: json['jumlah_klinik']?.toString() ?? '0',
      approved: parseIntSafely(json['approved']),
      details: (json['details'] as List?)
              ?.map((detail) => MonthlyScheduleDetailModel.fromJson(detail))
              .toList() ??
          [],
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
    // Helper function to parse product data safely
    List<ProductDataModel> parseProductData() {
      if (json.containsKey('product_data') && json['product_data'] is List) {
        // Standard format
        return (json['product_data'] as List)
            .map((product) => ProductDataModel.fromJson(product))
            .toList();
      } else if (json.containsKey('nama_product')) {
        // GM format - single product name
        return [
          ProductDataModel(
            idProduct: 0, // Default value for GM format
            namaProduct: json['nama_product']?.toString() ?? '',
          )
        ];
      }
      return [];
    }

    // Helper function to parse tujuan data safely
    TujuanDataModel parseTujuanData() {
      if (json.containsKey('tujuan_data') && json['tujuan_data'] is Map) {
        // Standard format
        return TujuanDataModel.fromJson(json['tujuan_data']);
      } else if (json.containsKey('nama_tujuan')) {
        // GM format
        return TujuanDataModel(
          idDokter: 0, // Default value for GM format
          namaDokter: json['nama_tujuan']?.toString() ?? '',
        );
      }
      return const TujuanDataModel(idDokter: 0, namaDokter: '');
    }

    // Helper function to parse product list safely
    List<String> parseProductList() {
      if (json.containsKey('product') && json['product'] is String) {
        try {
          return List<String>.from(jsonDecode(json['product']));
        } catch (e) {
          return [json['product']?.toString() ?? ''];
        }
      } else if (json.containsKey('nama_product')) {
        return [json['nama_product']?.toString() ?? ''];
      }
      return [];
    }

    return MonthlyScheduleDetailModel(
      id: json['id'] ?? 0,
      typeSchedule: json['type_schedule']?.toString() ??
          json['tipe_schedule']?.toString() ??
          '',
      tujuan: json['tujuan']?.toString() ?? '',
      idTujuan: json['id_tujuan'] ?? 0,
      tglVisit: json['tgl_visit']?.toString() ?? '',
      product: parseProductList(),
      note: json['note']?.toString() ?? '',
      shift: json['shift']?.toString() ??
          'Full Day', // Default value for GM format
      productData: parseProductData(),
      tujuanData: parseTujuanData(),
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
