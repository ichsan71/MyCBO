import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/realisasi_visit_gm_model.dart';
import '../models/realisasi_visit_model.dart';
import 'realisasi_visit_remote_data_source.dart';

class RealisasiVisitRemoteDataSourceImpl
    implements RealisasiVisitRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SharedPreferences sharedPreferences;

  RealisasiVisitRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.sharedPreferences,
  });

  @override
  Future<List<RealisasiVisitModel>> getRealisasiVisits(int idAtasan) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final response = await client.get(
        Uri.parse('$baseUrl/list-approval/$idAtasan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          if (jsonResponse['data'] is List) {
            return List<RealisasiVisitModel>.from(
              (jsonResponse['data'] as List).map(
                (x) => RealisasiVisitModel.fromJson(x),
              ),
            );
          } else {
            // Jika data adalah objek tunggal, bungkus dalam list
            return [RealisasiVisitModel.fromJson(jsonResponse['data'])];
          }
        } else {
          throw ServerException(
            message: jsonResponse['message'] ?? 'Unknown error occurred',
          );
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      Logger.error(
          'realisasi_visit_remote_ds', 'Error getting realisasi visits: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<RealisasiVisitGMModel>> getRealisasiVisitsGM(int idAtasan) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final response = await client.get(
        Uri.parse('$baseUrl/list-approval-gm/$idAtasan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          if (jsonResponse['data'] is List) {
            return List<RealisasiVisitGMModel>.from(
              (jsonResponse['data'] as List).map(
                (x) => RealisasiVisitGMModel.fromJson(x),
              ),
            );
          } else {
            // Jika data adalah objek tunggal, bungkus dalam list
            return [RealisasiVisitGMModel.fromJson(jsonResponse['data'])];
          }
        } else {
          throw ServerException(
            message: jsonResponse['message'] ?? 'Unknown error occurred',
          );
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      Logger.error(
          'realisasi_visit_remote_ds', 'Error getting GM realisasi visits: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<RealisasiVisitGMModel>> getRealisasiVisitsGMDetails(
      int idBCO) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final response = await client.get(
        Uri.parse('$baseUrl/list-approval-gm-all/$idBCO'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info(
          'realisasi_visit_remote_ds', '=== API Kedua - Detail BCO ===');
      Logger.info('realisasi_visit_remote_ds',
          'URL: $baseUrl/list-approval-gm-all/$idBCO');
      Logger.info('realisasi_visit_remote_ds',
          'Response status: ${response.statusCode}');
      Logger.info(
          'realisasi_visit_remote_ds', 'Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        Logger.info(
            'realisasi_visit_remote_ds', 'Success: ${jsonResponse['success']}');
        Logger.info(
            'realisasi_visit_remote_ds', 'Message: ${jsonResponse['message']}');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          Logger.info(
              'realisasi_visit_remote_ds', 'Data type: ${data.runtimeType}');
          Logger.info('realisasi_visit_remote_ds', 'Data content: $data');

          if (data is List) {
            final List<RealisasiVisitGMModel> models =
                List<RealisasiVisitGMModel>.from(
              data.map((x) => RealisasiVisitGMModel.fromJson(x)),
            );

            Logger.info('realisasi_visit_remote_ds',
                'Number of models: ${models.length}');
            for (var i = 0; i < models.length; i++) {
              Logger.info('realisasi_visit_remote_ds', 'Model $i:');
              Logger.info(
                  'realisasi_visit_remote_ds', '  - ID: ${models[i].id}');
              Logger.info(
                  'realisasi_visit_remote_ds', '  - Name: ${models[i].name}');
              Logger.info('realisasi_visit_remote_ds',
                  '  - Role: ${models[i].roleUsers}');
              Logger.info('realisasi_visit_remote_ds',
                  '  - Details count: ${models[i].details.length}');
            }

            return models;
          } else {
            // If the response is a single object, wrap it in a list
            final model = RealisasiVisitGMModel.fromJson(data);
            Logger.info('realisasi_visit_remote_ds', 'Single model data');
            Logger.info('realisasi_visit_remote_ds', '  - ID: ${model.id}');
            Logger.info('realisasi_visit_remote_ds', '  - Name: ${model.name}');
            Logger.info('realisasi_visit_remote_ds',
                '  - Details count: ${model.details.length}');
            return [model];
          }
        } else {
          throw ServerException(
            message: jsonResponse['message'] ?? 'No data available',
          );
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      Logger.error('realisasi_visit_remote_ds', 'Error getting GM details: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> approveRealisasiVisit({
    required List<int> idRealisasiVisits,
    required int idUser,
  }) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final response = await client.post(
        Uri.parse('$baseUrl/realisasi-visit-approved/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id_atasan': idUser.toString(),
          'id_schedule': idRealisasiVisits.map((id) => id.toString()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['message'] ??
              'Realisasi visit berhasil disetujui';
        } else {
          throw ServerException(
            message: jsonResponse['message'] ?? 'Unknown error occurred',
          );
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      Logger.error(
          'realisasi_visit_remote_ds', 'Error approving realisasi visit: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> rejectRealisasiVisit({
    required List<int> idRealisasiVisits,
    required int idUser,
    required String reason,
  }) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final response = await client.post(
        Uri.parse('$baseUrl/reject-realisasi-visit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id_atasan': idUser.toString(),
          'id_schedule': idRealisasiVisits.map((id) => id.toString()).toList(),
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['message'] ?? 'Berhasil menolak realisasi visit';
        } else {
          throw ServerException(
            message: jsonResponse['message'] ?? 'Unknown error occurred',
          );
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized');
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
