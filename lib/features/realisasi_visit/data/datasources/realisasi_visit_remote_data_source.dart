import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/realisasi_visit_model.dart';
import '../models/realisasi_visit_gm_model.dart';
import '../models/realisasi_visit_response_model.dart';

abstract class RealisasiVisitRemoteDataSource {
  /// Mengambil daftar realisasi visit
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<RealisasiVisitModel>> getRealisasiVisits(int idAtasan);

  /// Mengambil daftar realisasi visit khusus GM
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<RealisasiVisitGMModel>> getRealisasiVisitsGM(int idAtasan);

  /// Mengambil detail realisasi visit GM untuk BCO tertentu
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<RealisasiVisitGMModel>> getRealisasiVisitsGMDetails(int idBCO);

  /// Menyetujui realisasi visit
  /// Throws [ServerException] jika terjadi error pada server
  Future<String> approveRealisasiVisit({
    required int idRealisasiVisit,
    required int idUser,
  });

  /// Menolak realisasi visit
  /// Throws [ServerException] jika terjadi error pada server
  Future<String> rejectRealisasiVisit({
    required int idRealisasiVisit,
    required int idUser,
    required String reason,
  });
}

class RealisasiVisitRemoteDataSourceImpl
    implements RealisasiVisitRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final String baseUrl;
  static const String _tag = 'RealisasiVisitRemoteDataSource';

  RealisasiVisitRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? Constants.baseUrl;

  @override
  Future<List<RealisasiVisitModel>> getRealisasiVisits(int idAtasan) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token tidak ditemukan');
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path:
            '${Uri.parse(baseUrl).path}/list-approval-realisasi-visit/$idAtasan',
      );

      Logger.info(
          _tag, 'Mengambil data realisasi visit untuk id_atasan: $idAtasan');
      Logger.info(_tag, 'URL: $uri');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.info(_tag, 'Data parsed: $data');
        Logger.info(_tag, 'Success flag: ${data['success']}');
        Logger.info(_tag, 'Has data: ${data['data'] != null}');

        if (data['data'] != null) {
          try {
            final List<RealisasiVisitModel> result = (data['data'] as List)
                .map((item) => RealisasiVisitModel.fromJson(item))
                .toList();
            Logger.info(
                _tag, 'Berhasil parse ${result.length} item realisasi visit');
            return result;
          } catch (parseError) {
            Logger.error(_tag, 'Error saat parsing data: $parseError');
            throw ServerException(
              message: 'Gagal memproses data dari server: $parseError',
            );
          }
        } else {
          Logger.error(_tag,
              'Respons berhasil tapi tidak ada data. Message: ${data['message'] ?? 'Tidak ada pesan'}');
          throw ServerException(
            message: data['message'] ?? 'Tidak ada data realisasi visit',
          );
        }
      } else if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: 401');
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        Logger.error(_tag, 'Server error: ${response.statusCode}');
        throw ServerException(
          message: 'Server error dengan kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(_tag, 'Error umum: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      Logger.error(_tag, 'Error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<RealisasiVisitGMModel>> getRealisasiVisitsGM(int idAtasan) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token tidak ditemukan');
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-realisasi-visit-gm',
      );

      Logger.info(
          _tag, 'Mengambil data realisasi visit GM untuk id_atasan: $idAtasan');
      Logger.info(_tag, 'URL: $uri');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.info(_tag, 'Data GM parsed: $data');
        Logger.info(_tag, 'Success flag: ${data['success']}');
        Logger.info(_tag, 'Has data: ${data['data'] != null}');

        if (data['data'] != null) {
          try {
            final List<RealisasiVisitGMModel> result = (data['data'] as List)
                .map((item) => RealisasiVisitGMModel.fromJson(item))
                .toList();
            Logger.info(_tag,
                'Berhasil parse ${result.length} item realisasi visit GM');
            return result;
          } catch (parseError) {
            Logger.error(_tag, 'Error saat parsing data GM: $parseError');
            throw ServerException(
              message: 'Gagal memproses data GM dari server: $parseError',
            );
          }
        } else {
          Logger.error(_tag,
              'Respons GM berhasil tapi tidak ada data. Message: ${data['message'] ?? 'Tidak ada pesan'}');
          throw ServerException(
            message: data['message'] ?? 'Tidak ada data realisasi visit GM',
          );
        }
      } else if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: 401');
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        Logger.error(_tag, 'Server error: ${response.statusCode}');
        throw ServerException(
          message: 'Server error dengan kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(_tag, 'Error umum GM: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      Logger.error(_tag, 'Error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<RealisasiVisitGMModel>> getRealisasiVisitsGMDetails(int idBCO) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token tidak ditemukan');
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-gm-all/$idBCO',
      );

      Logger.info(
          _tag, 'Mengambil detail realisasi visit GM untuk id_bco: $idBCO');
      Logger.info(_tag, 'URL: $uri');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.info(_tag, 'Data GM parsed: $data');
        Logger.info(_tag, 'Success flag: ${data['success']}');
        Logger.info(_tag, 'Has data: ${data['data'] != null}');

        if (data['data'] != null) {
          try {
            final List<RealisasiVisitGMModel> result = (data['data'] as List)
                .map((item) => RealisasiVisitGMModel.fromJson(item))
                .toList();
            Logger.info(_tag,
                'Berhasil parse ${result.length} item realisasi visit GM');
            return result;
          } catch (parseError) {
            Logger.error(_tag, 'Error saat parsing data GM: $parseError');
            throw ServerException(
              message: 'Gagal memproses data GM dari server: $parseError',
            );
          }
        } else {
          Logger.error(_tag,
              'Respons GM berhasil tapi tidak ada data. Message: ${data['message'] ?? 'Tidak ada pesan'}');
          throw ServerException(
            message: data['message'] ?? 'Tidak ada data realisasi visit GM',
          );
        }
      } else if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: 401');
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        Logger.error(_tag, 'Server error: ${response.statusCode}');
        throw ServerException(
          message: 'Server error dengan kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(_tag, 'Error umum GM: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      Logger.error(_tag, 'Error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> approveRealisasiVisit({
    required int idRealisasiVisit,
    required int idUser,
  }) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token tidak ditemukan');
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/realisasi-visit-approved',
      );

      Logger.info(_tag,
          'Menyetujui realisasi visit - idRealisasiVisit: $idRealisasiVisit, idUser: $idUser');
      Logger.info(_tag, 'URL: $uri');

      final formData = {
        'id_realisasi_visit': idRealisasiVisit.toString(),
        'id_user': idUser.toString(),
      };

      Logger.info(_tag, 'Form Data: $formData');

      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: formData,
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info(_tag, 'Approve response data: $data');
        return data['message'] ?? 'Realisasi visit berhasil disetujui';
      } else if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: 401');
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        Logger.error(_tag, 'Server error: ${response.statusCode}');
        throw ServerException(
          message: 'Server error dengan kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(_tag, 'Error approve realisasi visit: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      Logger.error(_tag, 'Error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> rejectRealisasiVisit({
    required int idRealisasiVisit,
    required int idUser,
    required String reason,
  }) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token tidak ditemukan');
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/rejected-realisasi-visit',
      );

      Logger.info(_tag,
          'Menolak realisasi visit - idRealisasiVisit: $idRealisasiVisit, idUser: $idUser, reason: $reason');
      Logger.info(_tag, 'URL: $uri');

      final formData = {
        'id_realisasi_visit': idRealisasiVisit.toString(),
        'id_user': idUser.toString(),
        'reason': reason,
      };

      Logger.info(_tag, 'Form Data: $formData');

      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: formData,
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Realisasi visit berhasil ditolak';
      } else if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: 401');
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        Logger.error(_tag, 'Server error: ${response.statusCode}');
        throw ServerException(
          message: 'Server error dengan kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(_tag, 'Error reject realisasi visit: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      Logger.error(_tag, 'Error: $e');
      throw ServerException(message: e.toString());
    }
  }
}