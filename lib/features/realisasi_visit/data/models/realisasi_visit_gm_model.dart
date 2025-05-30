import 'package:test_cbo/core/utils/logger.dart';

import '../../domain/entities/realisasi_visit_gm.dart';
import 'realisasi_visit_model.dart';
import '../../../../core/error/exceptions.dart';

class RealisasiVisitGMModel extends RealisasiVisitGM {
  const RealisasiVisitGMModel({
    required int idBawahan,
    required String namaBawahan,
    required String kodeRayon,
    required String roleUsers,
    required List<JumlahDataModel> jumlah,
    required List<RealisasiVisitDetailModel> details,
  }) : super(
          idBawahan: idBawahan,
          namaBawahan: namaBawahan,
          kodeRayon: kodeRayon,
          roleUsers: roleUsers,
          jumlah: jumlah,
          details: details,
        );

  factory RealisasiVisitGMModel.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('realisasi visit gm', 'RealisasiVisitGMModel.fromJson input: $json');

      // Parsing jumlah data
      List<JumlahDataModel> jumlahList = [];
      if (json['jumlah'] != null) {
        if (json['jumlah'] is List) {
          jumlahList = List<JumlahDataModel>.from(
            (json['jumlah'] as List).map(
              (x) => JumlahDataModel.fromJson(x),
            ),
          );
        } else if (json['jumlah'] is Map) {
          // Jika jumlah berupa objek, konversi ke list dengan satu item
          jumlahList = [JumlahDataModel.fromJson(json['jumlah'])];
        }
      }

      // Parsing detail realisasi visit
      List<RealisasiVisitDetailModel> detailsList = [];
      if (json['detail'] != null) {
        if (json['detail'] is List) {
          Logger.info('realisasi visit gm', 'GM detail list length: ${(json['detail'] as List).length}');
          detailsList = List<RealisasiVisitDetailModel>.from(
            (json['detail'] as List)
                .map((detail) => RealisasiVisitDetailModel.fromJson(detail)),
          );
        } else if (json['detail'] is Map) {
          // Jika detail berupa objek, konversi ke list dengan satu item
          detailsList = [RealisasiVisitDetailModel.fromJson(json['detail'])];
        }
      } else if (json['details'] != null) {
        // Alternatif nama field
        if (json['details'] is List) {
          Logger.info('realisasi_visit', 'GM details list length: ${(json['details'] as List).length}');
          detailsList = List<RealisasiVisitDetailModel>.from(
            (json['details'] as List)
                .map((detail) => RealisasiVisitDetailModel.fromJson(detail)),
          );
        } else if (json['details'] is Map) {
          detailsList = [RealisasiVisitDetailModel.fromJson(json['details'])];
        }
      }

      final result = RealisasiVisitGMModel(
        idBawahan: json['id'] ?? 0,
        namaBawahan: json['name'] ?? '',
        kodeRayon: json['kode_rayon'] ?? '',
        roleUsers: json['role_users'] ?? '',
        jumlah: jumlahList,
        details: detailsList,
      );

      Logger.info('realisasi_visit',
          'Created RealisasiVisitGMModel with ${result.details.length} details');
      return result;
    } catch (e) {
      Logger.error('realisasi_visit', 'Error parsing RealisasiVisitGMModel: $e');
      Logger.info('realisasi_visit', 'JSON data: $json');
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing RealisasiVisitGMModel: ${e.toString()}');
    }
  }
}

class JumlahDataModel extends JumlahData {
  const JumlahDataModel({
    required int total,
    required String realisasi,
  }) : super(
          total: total,
          realisasi: realisasi,
        );

  factory JumlahDataModel.fromJson(Map<String, dynamic> json) {
    try {
      // Menangani berbagai format nilai total
      final totalValue = json.containsKey('total')
          ? json['total'] is int
              ? json['total']
              : int.tryParse(json['total'].toString()) ?? 0
          : 0;

      // Menangani berbagai format nilai realisasi
      final realisasiValue = json.containsKey('realisasi')
          ? json['realisasi'].toString()
          : json.containsKey('terrealisasi')
              ? json['terrealisasi'].toString()
              : '0';

      return JumlahDataModel(
        total: totalValue,
        realisasi: realisasiValue,
      );
    } catch (e) {
      Logger.error('realisasi_visit', 'Error parsing JumlahDataModel: $e');
      Logger.info('realisasi_visit', 'JSON data: $json');
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Error parsing JumlahDataModel: ${e.toString()}');
    }
  }
}
