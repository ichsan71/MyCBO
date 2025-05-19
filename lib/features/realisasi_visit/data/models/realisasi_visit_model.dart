import '../../domain/entities/realisasi_visit.dart';
import '../../../../core/error/exceptions.dart';

class RealisasiVisitModel extends RealisasiVisit {
  const RealisasiVisitModel({
    required int idBawahan,
    required String namaBawahan,
    required String role,
    required int totalSchedule,
    required String jumlahDokter,
    required String jumlahKlinik,
    required String totalTerrealisasi,
    required int approved,
    required List<RealisasiVisitDetailModel> details,
  }) : super(
          idBawahan: idBawahan,
          namaBawahan: namaBawahan,
          role: role,
          totalSchedule: totalSchedule,
          jumlahDokter: jumlahDokter,
          jumlahKlinik: jumlahKlinik,
          totalTerrealisasi: totalTerrealisasi,
          approved: approved,
          details: details,
        );

  factory RealisasiVisitModel.fromJson(Map<String, dynamic> json) {
    try {
      return RealisasiVisitModel(
        idBawahan: json['id_bawahan'] as int? ??
            (throw ServerException(
                message: 'id_bawahan tidak ditemukan atau invalid')),
        namaBawahan: json['nama_bawahan'] as String? ??
            (throw ServerException(
                message: 'nama_bawahan tidak ditemukan atau invalid')),
        role: json['role'] as String? ?? '',
        totalSchedule: json['total_schedule'] as int? ??
            (throw ServerException(
                message: 'total_schedule tidak ditemukan atau invalid')),
        jumlahDokter: (json['jumlah_dokter'] ?? '0').toString(),
        jumlahKlinik: (json['jumlah_klinik'] ?? '0').toString(),
        totalTerrealisasi: (json['total_terrealisasi'] ?? '0').toString(),
        approved: json['approved'] as int? ?? 0,
        details: json.containsKey('details') && json['details'] != null
            ? (json['details'] as List)
                .map((detail) => RealisasiVisitDetailModel.fromJson(detail))
                .toList()
            : [],
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing RealisasiVisitModel: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bawahan': idBawahan,
      'nama_bawahan': namaBawahan,
      'role': role,
      'total_schedule': totalSchedule,
      'jumlah_dokter': jumlahDokter,
      'jumlah_klinik': jumlahKlinik,
      'total_terrealisasi': totalTerrealisasi,
      'approved': approved,
      'details': details
          .map((detail) => (detail as RealisasiVisitDetailModel).toJson())
          .toList(),
    };
  }
}

class RealisasiVisitDetailModel extends RealisasiVisitDetail {
  const RealisasiVisitDetailModel({
    required int id,
    required String typeSchedule,
    required String tujuan,
    required int idTujuan,
    required String tglVisit,
    required String product,
    required String note,
    required String shift,
    required String jenis,
    String? checkin,
    String? fotoSelfie,
    String? checkout,
    String? fotoSelfieDua,
    required String statusTerrealisasi,
    String? realisasiVisitApproved,
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
          jenis: jenis,
          checkin: checkin,
          fotoSelfie: fotoSelfie,
          checkout: checkout,
          fotoSelfieDua: fotoSelfieDua,
          statusTerrealisasi: statusTerrealisasi,
          realisasiVisitApproved: realisasiVisitApproved,
          productData: productData,
          tujuanData: tujuanData,
        );

  factory RealisasiVisitDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      return RealisasiVisitDetailModel(
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
        jenis: (json['jenis'] ?? '').toString(),
        checkin: json['checkin'] as String?,
        fotoSelfie: json['foto_selfie'] as String?,
        checkout: json['checkout'] as String?,
        fotoSelfieDua: json['foto_selfie_dua'] as String?,
        statusTerrealisasi: (json['status_terrealisasi'] ?? '').toString(),
        realisasiVisitApproved: json['realisasi_visit_approved'] as String?,
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
                  ),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing RealisasiVisitDetailModel: ${e.toString()}');
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
      'jenis': jenis,
      'checkin': checkin,
      'foto_selfie': fotoSelfie,
      'checkout': checkout,
      'foto_selfie_dua': fotoSelfieDua,
      'status_terrealisasi': statusTerrealisasi,
      'realisasi_visit_approved': realisasiVisitApproved,
      'product_data': productData
          .map((product) => (product as ProductDataModel).toJson())
          .toList(),
      'tujuan_data': (tujuanData as TujuanDataModel).toJson(),
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
  }) : super(
          idDokter: idDokter,
          namaDokter: namaDokter,
        );

  factory TujuanDataModel.fromJson(Map<String, dynamic> json) {
    try {
      return TujuanDataModel(
        idDokter: json['id_dokter'] as int? ?? 0,
        namaDokter: (json['nama_dokter'] ?? '').toString(),
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
    };
  }
}
