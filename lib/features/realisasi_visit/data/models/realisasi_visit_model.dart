import 'package:test_cbo/core/utils/logger.dart';

import '../../domain/entities/realisasi_visit.dart';
import '../../../../core/error/exceptions.dart';
import 'dart:convert';

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
      Logger.info('realisasi_visit', 'Parsing RealisasiVisitModel from: $json');

      return RealisasiVisitModel(
        idBawahan: json['id_bawahan'] as int? ?? 0,
        namaBawahan: json['nama_bawahan'] as String? ?? '',
        role: json['role'] as String? ?? '',
        totalSchedule: json['total_schedule'] as int? ?? 0,
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
      Logger.error('realisasi_visit', 'Error parsing RealisasiVisitModel: $e');
      Logger.info('realisasi_visit', 'JSON data: $json');
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

  // Fungsi helper untuk mendapatkan daftar nama produk
  List<String> get productNames => productData
      .map((product) => product.namaProduct)
      .where((name) => name.isNotEmpty)
      .toList();

  // Fungsi helper untuk mendapatkan formatted text daftar produk
  String get formattedProductNames {
    if (productData.isEmpty) return '';
    final result = productNames.join(', ');
    Logger.info('realisasi_visit', 'formattedProductNames: $result');
    return result;
  }

  factory RealisasiVisitDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('realisasi_visit', 'Parsing RealisasiVisitDetailModel from: $json');

      // Tangani tujuan data dengan lebih baik
      TujuanDataModel tujuanData;
      if (json.containsKey('tujuan_data') && json['tujuan_data'] != null) {
        Logger.info('realisasi_visit', 'Menggunakan tujuan_data dari json: ${json['tujuan_data']}');
        tujuanData = TujuanDataModel.fromJson(json['tujuan_data']);
      } else if (json.containsKey('dokter') && json['dokter'] != null) {
        // Format alternatif - gunakan dari field dokter jika ada
        Logger.info('realisasi_visit', 'Menggunakan field dokter: ${json['dokter']}');
        tujuanData = TujuanDataModel(
          idDokter: json['id_tujuan'] as int? ?? 0,
          namaDokter: json['dokter'].toString(),
        );
      } else if (json.containsKey('nama_dokter') &&
          json['nama_dokter'] != null) {
        // Format alternatif - nama dokter langsung di level root
        Logger.info('realisasi_visit', 'Menggunakan nama_dokter dari root: ${json['nama_dokter']}');
        tujuanData = TujuanDataModel(
          idDokter: json['id_tujuan'] as int? ?? 0,
          namaDokter: json['nama_dokter'].toString(),
        );
      } else {
        // Default fallback
        Logger.error(
            'realisasi_visit',
            'Tidak ada data tujuan ditemukan, menggunakan default dengan id_tujuan: ${json['id_tujuan']}');
        tujuanData = TujuanDataModel(
          idDokter: json['id_tujuan'] as int? ?? 0,
          namaDokter: json['tujuan'] == 'Dokter' && json.containsKey('nama')
              ? json['nama'].toString()
              : '',
        );
      }

      // Parse product data dengan lebih baik
      List<ProductDataModel> productDataList = [];

      // PRIORITAS PERTAMA: Cek jika ada atribut nama_product yang bisa langsung digunakan
      if (json.containsKey('nama_product') && json['nama_product'] != null) {
        Logger.info('realisasi_visit', 'Menggunakan nama_product dari API: ${json['nama_product']}');
        String namaProductStr = json['nama_product'].toString();

        // Jika nama produk mengandung koma, bisa jadi berisi beberapa produk
        if (namaProductStr.contains(',')) {
          List<String> productNames = namaProductStr.split(',');
          int counter = 1;
          productDataList = productNames
              .map((name) => ProductDataModel(
                    idProduct: counter++,
                    namaProduct: name.trim(),
                  ))
              .toList();
          Logger.info(
              'realisasi_visit',
              'Berhasil parse ${productDataList.length} produk dari nama_product');
        } else {
          // Hanya satu produk
          productDataList.add(ProductDataModel(
            idProduct: 1,
            namaProduct: namaProductStr.trim(),
          ));
          Logger.info(
              'realisasi_visit',
              'Berhasil parse 1 produk dari nama_product: $namaProductStr');
        }
      }
      // Jika tidak ada nama_product, coba format lain
      else {
        // Cek format pertama: array product_data
        if (json.containsKey('product_data') && json['product_data'] != null) {
          Logger.info(
              'realisasi_visit', 'Parsing product_data dari json: ${json['product_data']}');
          try {
            if (json['product_data'] is List) {
              productDataList = (json['product_data'] as List)
                  .map((product) => ProductDataModel.fromJson(product))
                  .toList();
            } else if (json['product_data'] is String) {
              // Jika product_data adalah string JSON
              try {
                final List<dynamic> productList =
                    jsonDecode(json['product_data'] as String);
                productDataList = productList
                    .map((product) => ProductDataModel.fromJson(product))
                    .toList();
              } catch (e) {
                Logger.error(
                    'realisasi_visit',
                    'Error parsing product_data string as JSON: $e');
              }
            }
          } catch (e) {
            Logger.error(
                'realisasi_visit', 'Error parsing product_data: $e');
          }
        }
        // Cek format alternatif: string product yang mungkin berisi JSON
        else if (json.containsKey('product') && json['product'] != null) {
          final dynamic productValue = json['product'];
          Logger.info(
              'realisasi_visit', 'Mencoba parse dari field product: $productValue');

          if (productValue is String) {
            try {
              if (productValue.startsWith('[') && productValue.endsWith(']')) {
                // Coba parse string JSON ke list
                final List<dynamic> productList = jsonDecode(productValue);
                productDataList = productList
                    .map((product) => ProductDataModel.fromJson(product))
                    .toList();
              } else if (productValue.contains(',')) {
                // Mungkin format string dengan koma sebagai pemisah
                final List<String> productNames = productValue.split(',');
                int counter = 1;
                productDataList = productNames
                    .map((name) => ProductDataModel(
                          idProduct: counter++,
                          namaProduct: name.trim(),
                        ))
                    .toList();
              }
            } catch (e) {
              Logger.error(
                  'realisasi_visit', 'Error parsing product string: $e');
              // Jika gagal parse, tambahkan sebagai satu produk
              if (productValue.isNotEmpty) {
                productDataList.add(ProductDataModel(
                  idProduct: 1,
                  namaProduct: productValue,
                ));
              }
            }
          } else if (productValue is List) {
            try {
              productDataList = (productValue)
                  .map((product) => ProductDataModel.fromJson(product))
                  .toList();
            } catch (e) {
              Logger.error(
                  'realisasi_visit', 'Error parsing product as List: $e');
            }
          }
        }
      }

      // Parse note dengan lebih baik
      String noteValue = '';
      if (json.containsKey('note') && json['note'] != null) {
        noteValue = json['note'].toString();
      } else if (json.containsKey('notes') && json['notes'] != null) {
        noteValue = json['notes'].toString();
      } else if (json.containsKey('keterangan') && json['keterangan'] != null) {
        noteValue = json['keterangan'].toString();
      } else if (json.containsKey('catatan') && json['catatan'] != null) {
        noteValue = json['catatan'].toString();
      }

      return RealisasiVisitDetailModel(
        id: json['id'] as int? ?? 0,
        typeSchedule: (json['type_schedule'] ?? '').toString(),
        tujuan: (json['tujuan'] ?? '').toString(),
        idTujuan: json['id_tujuan'] as int? ?? 0,
        tglVisit: (json['tgl_visit'] ?? '').toString(),
        product: (json['product'] ?? '[]').toString(),
        note: noteValue,
        shift: (json['shift'] ?? '').toString(),
        jenis: (json['jenis'] ?? '').toString(),
        checkin: json['checkin']?.toString(),
        fotoSelfie:
            json['foto_selfie']?.toString(),
        checkout: json['checkout']?.toString(),
        fotoSelfieDua: json['foto_selfie_dua']?.toString(),
        statusTerrealisasi: (json['status_terrealisasi'] ?? '').toString(),
        realisasiVisitApproved: json['realisasi_visit_approved']?.toString(),
        productData: productDataList,
        tujuanData: tujuanData,
      );
    } catch (e) {
      Logger.error(
          'realisasi_visit', 'Error parsing RealisasiVisitDetailModel: $e');
      Logger.info('realisasi_visit', 'JSON data: $json');

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
      // Mendukung berbagai format field
      final idProduct = json.containsKey('id_product')
          ? json['id_product'] is int
              ? json['id_product']
              : int.tryParse(json['id_product'].toString()) ?? 0
          : json.containsKey('id')
              ? json['id'] is int
                  ? json['id']
                  : int.tryParse(json['id'].toString()) ?? 0
              : 0;

      // Mendukung berbagai format nama produk
      final namaProduct = json.containsKey('nama_product')
          ? json['nama_product'].toString()
          : json.containsKey('nama')
              ? json['nama'].toString()
              : json.containsKey('name')
                  ? json['name'].toString()
                  : '';

      return ProductDataModel(
        idProduct: idProduct,
        namaProduct: namaProduct.trim(),
      );
    } catch (e) {
      Logger.error('realisasi_visit', 'Error parsing ProductDataModel: $e');
      Logger.info('realisasi_visit', 'JSON data: $json');

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
      Logger.info('realisasi_visit', 'TujuanDataModel.fromJson input: $json');

      // Mendukung berbagai format ID dokter
      final idDokter = json.containsKey('id_dokter')
          ? json['id_dokter'] is int
              ? json['id_dokter']
              : int.tryParse(json['id_dokter'].toString()) ?? 0
          : json.containsKey('id')
              ? json['id'] is int
                  ? json['id']
                  : int.tryParse(json['id'].toString()) ?? 0
              : 0;

      // Mendukung berbagai format nama dokter
      final namaDokter = json.containsKey('nama_dokter')
          ? json['nama_dokter'].toString()
          : json.containsKey('nama')
              ? json['nama'].toString()
              : json.containsKey('name')
                  ? json['name'].toString()
                  : '';

      final result = TujuanDataModel(
        idDokter: idDokter,
        namaDokter: namaDokter.trim(),
      );
      Logger.info('realisasi_visit',
          'Created TujuanDataModel with namaDokter: ${result.namaDokter}');
      return result;
    } catch (e) {
      Logger.error('realisasi_visit', 'Error parsing TujuanDataModel: $e');
      Logger.info('realisasi_visit', 'JSON input: $json');
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
