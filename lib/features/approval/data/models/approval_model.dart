import '../../domain/entities/approval.dart';
import '../../../../core/error/exceptions.dart';

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
    try {
      return ApprovalModel(
        idBawahan: json['id_bawahan'] as int? ??
            (throw ServerException(
                message: 'id_bawahan tidak ditemukan atau invalid')),
        namaBawahan: json['nama_bawahan'] as String? ??
            (throw ServerException(
                message: 'nama_bawahan tidak ditemukan atau invalid')),
        totalSchedule: json['total_schedule'] as int? ??
            (throw ServerException(
                message: 'total_schedule tidak ditemukan atau invalid')),
        year: json['year'] as int? ??
            (throw ServerException(
                message: 'year tidak ditemukan atau invalid')),
        month: json['month'] as int? ??
            (throw ServerException(
                message: 'month tidak ditemukan atau invalid')),
        jumlahDokter: (json['jumlah_dokter'] ?? '0').toString(),
        jumlahKlinik: (json['jumlah_klinik'] ?? '0').toString(),
        approved: json['approved'] as int? ?? 0,
        details: json.containsKey('details') && json['details'] != null
            ? (json['details'] as List)
                .map((detail) => DetailModel.fromJson(detail))
                .toList()
            : [],
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing ApprovalModel: ${e.toString()}');
    }
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
    required int approved,
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
    try {
      return DetailModel(
        id: json['id'] as int? ??
            (throw ServerException(message: 'id tidak ditemukan atau invalid')),
        typeSchedule: (json['type_schedule'] ?? '').toString(),
        tujuan: (json['tujuan'] ?? '').toString(),
        idTujuan: json['id_tujuan'] as int? ??
            (throw ServerException(
                message: 'id_tujuan tidak ditemukan atau invalid')),
        tglVisit: (json['tgl_visit'] ?? '').toString(),
        product: (json['product'] ?? '[]').toString(),
        note: (json['note'] ?? '').toString(),
        shift: (json['shift'] ?? '').toString(),
        productData:
            json.containsKey('product_data') && json['product_data'] != null
                ? (json['product_data'] as List)
                    .map((product) => ProductDataModel.fromJson(product))
                    .toList()
                : [],
        tujuanData:
            json.containsKey('tujuan_data') && json['tujuan_data'] != null
                ? TujuanDataModel.fromJson(json['tujuan_data'])
                : TujuanDataModel(
                    idDokter: json['id_tujuan'] as int? ?? 0,
                    namaDokter: '',
                    namaKlinik: '',
                  ),
        approved: json['approved'] as int? ?? 0,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing DetailModel: ${e.toString()}');
    }
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
    try {
      return ProductDataModel(
        idProduct: json['id_product'] as int? ??
            (throw ServerException(
                message: 'id_product tidak ditemukan atau invalid')),
        namaProduct: (json['nama_product'] ?? '').toString(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing ProductDataModel: ${e.toString()}');
    }
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
    required String namaKlinik,
  }) : super(
          idDokter: idDokter,
          namaDokter: namaDokter,
          namaKlinik: namaKlinik,
        );

  factory TujuanDataModel.fromJson(Map<String, dynamic> json) {
    try {
      return TujuanDataModel(
        idDokter: json['id_dokter'] as int? ?? 0,
        namaDokter: (json['nama_dokter'] ?? '').toString(),
        namaKlinik: (json['nama_klinik'] ?? '').toString(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing TujuanDataModel: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dokter': idDokter,
      'nama_dokter': namaDokter,
      'nama_klinik': namaKlinik,
    };
  }
}
