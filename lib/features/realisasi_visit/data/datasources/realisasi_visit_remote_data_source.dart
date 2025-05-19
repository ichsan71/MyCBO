import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/realisasi_visit_model.dart';
import '../models/realisasi_visit_response_model.dart';

abstract class RealisasiVisitRemoteDataSource {
  /// Mengambil daftar realisasi visit
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<RealisasiVisitModel>> getRealisasiVisits(int idAtasan);

  /// Menyetujui realisasi visit
  /// Throws [ServerException] jika terjadi error pada server
  Future<RealisasiVisitResponseModel> approveRealisasiVisit(
      int idAtasan, List<String> idSchedule);

  /// Menolak realisasi visit
  /// Throws [ServerException] jika terjadi error pada server
  Future<RealisasiVisitResponseModel> rejectRealisasiVisit(
      int idAtasan, List<String> idSchedule);
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
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        Logger.info(_tag, 'Response Structure: ${jsonResponse.keys}');

        if (!jsonResponse.containsKey('data')) {
          throw ServerException(
              message: 'Format response tidak valid: data tidak ditemukan');
        }

        final data = jsonResponse['data'];
        if (data is! List) {
          throw ServerException(
              message: 'Format response tidak valid: data bukan array');
        }

        final List<dynamic> realisasiVisitsJson = data;
        return realisasiVisitsJson
            .map((json) => RealisasiVisitModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message:
                'Gagal memuat data realisasi visit: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getRealisasiVisits', e.toString());
      rethrow;
    }
  }

  @override
  Future<RealisasiVisitResponseModel> approveRealisasiVisit(
      int idAtasan, List<String> idSchedule) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/realisasi-visit-approved/',
      );

      Logger.info(
          _tag, 'Menyetujui realisasi visit untuk id_atasan: $idAtasan');
      Logger.info(_tag, 'URL: $uri');

      final formData = {
        'id_atasan': idAtasan.toString(),
        'id_schedule': idSchedule,
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
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return RealisasiVisitResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message:
                'Gagal menyetujui realisasi visit: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'approveRealisasiVisit', e.toString());
      rethrow;
    }
  }

  @override
  Future<RealisasiVisitResponseModel> rejectRealisasiVisit(
      int idAtasan, List<String> idSchedule) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/realisasi-visit-rejected/',
      );

      Logger.info(_tag, 'Menolak realisasi visit untuk id_atasan: $idAtasan');
      Logger.info(_tag, 'URL: $uri');

      final formData = {
        'id_atasan': idAtasan.toString(),
        'id_schedule': idSchedule,
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
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return RealisasiVisitResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal menolak realisasi visit: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'rejectRealisasiVisit', e.toString());
      rethrow;
    }
  }
}
