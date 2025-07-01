import '../../domain/entities/approval.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

class ApprovalModel extends Approval {
  const ApprovalModel({
    required int id,
    required int userId,
    required String namaBawahan,
    required String tglVisit,
    required String tujuan,
    required String note,
    required bool isApproved,
    required int approved,
    required int idBawahan,
    required int month,
    required int year,
    required int totalSchedule,
    required String jumlahDokter,
    required String jumlahKlinik,
    required List<Detail> details,
  }) : super(
          id: id,
          userId: userId,
          namaBawahan: namaBawahan,
          tglVisit: tglVisit,
          tujuan: tujuan,
          note: note,
          isApproved: isApproved,
          approved: approved,
          idBawahan: idBawahan,
          month: month,
          year: year,
          totalSchedule: totalSchedule,
          jumlahDokter: jumlahDokter,
          jumlahKlinik: jumlahKlinik,
          details: details,
        );

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse integer fields with proper type conversion
      int parseIntField(dynamic value, String fieldName) {
        Logger.info('ApprovalModel',
            'Parsing $fieldName: value=$value, type=${value?.runtimeType}');
        if (value == null) return 0;
        if (value is int) return value;
        return int.tryParse(value.toString()) ?? 0;
      }

      // Parse all integer fields
      final id = parseIntField(json['id'] ?? json['id_user'], 'id');
      final userId =
          parseIntField(json['user_id'] ?? json['id_user'], 'user_id');
      final approved = parseIntField(json['approved'], 'approved');
      final idBawahan =
          parseIntField(json['id_bawahan'] ?? json['id_user'], 'id_bawahan');
      final month = parseIntField(json['month'], 'month');
      final year = parseIntField(json['year'], 'year');
      final totalSchedule =
          parseIntField(json['total_schedule'], 'total_schedule');

      // Parse details list with null safety
      List<Detail> detailsList = [];
      Logger.info('ApprovalModel', 'Parsing details: ${json['details']}');

      try {
        if (json['details'] != null) {
          if (json['details'] is List) {
            Logger.info('ApprovalModel',
                'Details is a List with ${(json['details'] as List).length} items');

            detailsList = (json['details'] as List)
                .where((detail) => detail != null)
                .map((detail) {
                  try {
                    if (detail is Map<String, dynamic>) {
                      Logger.info(
                          'ApprovalModel', 'Processing detail item: $detail');
                      return DetailModel.fromJson(detail);
                    }
                    Logger.warning('ApprovalModel',
                        'Skipping invalid detail format: $detail (type: ${detail.runtimeType})');
                    return null;
                  } catch (e, stackTrace) {
                    Logger.warning('ApprovalModel',
                        'Error parsing detail item: $e\nStack trace: $stackTrace');
                    return null;
                  }
                })
                .where((detail) => detail != null)
                .cast<Detail>()
                .toList();

            Logger.info('ApprovalModel',
                'Successfully parsed ${detailsList.length} details');
          } else {
            Logger.warning('ApprovalModel',
                'Details is not a List: ${json['details'].runtimeType}');
          }
        } else {
          Logger.info('ApprovalModel', 'Details is null, using empty list');
        }
      } catch (e, stackTrace) {
        Logger.error('ApprovalModel',
            'Error parsing details list: $e\nStack trace: $stackTrace');
      }

      return ApprovalModel(
        id: id,
        userId: userId,
        namaBawahan: (json['nama_bawahan'] ?? json['nama'] ?? '').toString(),
        tglVisit: (json['tgl_visit'] ?? '').toString(),
        tujuan: (json['tujuan'] ?? '').toString(),
        note: (json['note'] ?? '').toString(),
        isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
        approved: approved,
        idBawahan: idBawahan,
        month: month,
        year: year,
        totalSchedule: totalSchedule,
        jumlahDokter: (json['jumlah_dokter'] ?? '0').toString(),
        jumlahKlinik: (json['jumlah_klinik'] ?? '0').toString(),
        details: detailsList,
      );
    } catch (e, stackTrace) {
      Logger.error(
          'ApprovalModel', 'Error in fromJson: $e\nStack trace: $stackTrace');
      Logger.error('ApprovalModel', 'Problematic JSON: $json');
      throw ServerException(
          message: 'Error parsing ApprovalModel: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_bawahan': namaBawahan,
      'tgl_visit': tglVisit,
      'tujuan': tujuan,
      'note': note,
      'is_approved': isApproved ? 1 : 0,
      'approved': approved,
      'id_bawahan': idBawahan,
      'month': month,
      'year': year,
      'total_schedule': totalSchedule,
      'jumlah_dokter': jumlahDokter,
      'jumlah_klinik': jumlahKlinik,
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
    required List<ProductData> productData,
    required TujuanData tujuanData,
    required int approved,
    int? realisasiApprove,
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
          realisasiApprove: realisasiApprove,
        );

  factory DetailModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('DetailModel', 'Starting to parse JSON: $json');

      // Parse product string if it's a JSON string
      String productStr = (json['product'] ?? '[]').toString();
      Logger.info('DetailModel', 'Raw product string: $productStr');

      // Remove escaped quotes if present
      productStr = productStr.replaceAll('\\"', '"');
      Logger.info('DetailModel', 'Unescaped product string: $productStr');

      // Memastikan bahwa product_data adalah array yang valid
      List<ProductDataModel> productDataList = [];
      if (json.containsKey('product_data') && json['product_data'] != null) {
        if (json['product_data'] is List) {
          Logger.info('DetailModel',
              'Processing product_data list: ${json['product_data']}');
          productDataList = (json['product_data'] as List)
              .where((item) => item != null)
              .map((product) {
            try {
              if (product is Map<String, dynamic>) {
                Logger.info('DetailModel', 'Processing product item: $product');
                return ProductDataModel.fromJson(product);
              }
              Logger.error('DetailModel',
                  'Invalid product format: $product (type: ${product.runtimeType})');
              return ProductDataModel(idProduct: 0, namaProduct: 'Unknown');
            } catch (e, stackTrace) {
              Logger.error('DetailModel',
                  'Error parsing product: $e\nStack trace: $stackTrace');
              return ProductDataModel(
                  idProduct: 0, namaProduct: 'Error: ${e.toString()}');
            }
          }).toList();
        } else {
          Logger.error('DetailModel',
              'product_data is not a List: ${json['product_data'].runtimeType}');
        }
      } else if (json.containsKey('nama_product')) {
        // GM format - single product name
        Logger.info('DetailModel',
            'Processing GM format product: ${json['nama_product']}');
        productDataList = [
          ProductDataModel(
            idProduct: 0, // Default value for GM format
            namaProduct: json['nama_product']?.toString() ?? '',
          )
        ];
      }

      // Memastikan bahwa tujuan_data adalah object yang valid
      TujuanDataModel tujuanDataModel;
      if (json.containsKey('tujuan_data') &&
          json['tujuan_data'] != null &&
          json['tujuan_data'] is Map<String, dynamic>) {
        Logger.info(
            'DetailModel', 'Processing tujuan_data: ${json['tujuan_data']}');
        tujuanDataModel = TujuanDataModel.fromJson(json['tujuan_data']);
      } else if (json.containsKey('nama_tujuan')) {
        // GM format
        Logger.info('DetailModel',
            'Processing GM format tujuan: ${json['nama_tujuan']}');
        tujuanDataModel = TujuanDataModel(
          idDokter: 0, // Default value for GM format
          namaDokter: json['nama_tujuan']?.toString() ?? '',
          namaKlinik: '',
        );
      } else {
        Logger.info('DetailModel',
            'Creating default tujuan_data with id_tujuan: ${json['id_tujuan']}');
        tujuanDataModel = TujuanDataModel(
          idDokter: json['id_tujuan'] is int
              ? json['id_tujuan']
              : (int.tryParse(json['id_tujuan']?.toString() ?? '0') ?? 0),
          namaDokter: '',
          namaKlinik: '',
        );
      }

      // Parse id with proper type conversion
      int id = json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0);

      // Parse idTujuan with proper type conversion
      int idTujuan = json['id_tujuan'] is int
          ? json['id_tujuan']
          : (int.tryParse(json['id_tujuan']?.toString() ?? '0') ?? 0);

      // Parse approved with proper type conversion
      int approved = json['approved'] is int
          ? json['approved']
          : (int.tryParse(json['approved']?.toString() ?? '0') ?? 0);

      // Parse realisasiApprove with proper type conversion
      int? realisasiApprove;
      if (json['realisasi_approve'] != null) {
        realisasiApprove = json['realisasi_approve'] is int
            ? json['realisasi_approve']
            : (int.tryParse(json['realisasi_approve'].toString()) ?? 0);
      }

      return DetailModel(
        id: id,
        typeSchedule:
            (json['type_schedule'] ?? json['tipe_schedule'] ?? '').toString(),
        tujuan: (json['tujuan'] ?? '').toString(),
        idTujuan: idTujuan,
        tglVisit: (json['tgl_visit'] ?? '').toString(),
        product: productStr,
        note: (json['note'] ?? '').toString(),
        shift: (json['shift'] ?? 'Full Day')
            .toString(), // Default shift for GM format
        productData: productDataList,
        tujuanData: tujuanDataModel,
        approved: approved,
        realisasiApprove: realisasiApprove,
      );
    } catch (e, stackTrace) {
      Logger.error(
          'DetailModel', 'Error in fromJson: $e\nStack trace: $stackTrace');
      Logger.error('DetailModel', 'Problematic JSON: $json');
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
      if (realisasiApprove != null) 'realisasi_approve': realisasiApprove,
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
      // Parse idProduct with proper type conversion
      int idProduct = json['id_product'] is int
          ? json['id_product']
          : (int.tryParse(json['id_product']?.toString() ?? '0') ?? 0);

      return ProductDataModel(
        idProduct: idProduct,
        namaProduct: (json['nama_product'] ?? '').toString(),
      );
    } catch (e) {
      return const ProductDataModel(
        idProduct: 0,
        namaProduct: 'Error parsing product data',
      );
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
      // Parse idDokter with proper type conversion
      int idDokter = json['id_dokter'] is int
          ? json['id_dokter']
          : (int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0);

      return TujuanDataModel(
        idDokter: idDokter,
        namaDokter: (json['nama_dokter'] ?? '').toString(),
        namaKlinik: (json['nama_klinik'] ?? '').toString(),
      );
    } catch (e) {
      // Sebagai fallback, kembalikan objek default
      return const TujuanDataModel(
        idDokter: 0,
        namaDokter: 'Error parsing dokter data',
        namaKlinik: '',
      );
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
