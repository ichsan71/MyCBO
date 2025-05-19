import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/approval_filter.dart';
import '../models/approval_model.dart';
import '../models/approval_response_model.dart';

abstract class ApprovalRemoteDataSource {
  /// Mengambil daftar persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> getApprovals(int userId);

  /// Memfilter daftar persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> filterApprovals(ApprovalFilter filter);

  /// Mengirim persetujuan (setuju atau tolak)
  /// Throws [ServerException] jika terjadi error pada server
  Future<ApprovalResponseModel> sendApproval(int scheduleId, int userId,
      {required bool isApproved});

  /// Menyetujui permintaan
  /// Throws [ServerException] jika terjadi error pada server
  Future<void> approveRequest(int approvalId, String notes);

  /// Menolak permintaan
  /// Throws [ServerException] jika terjadi error pada server
  Future<void> rejectRequest(int approvalId, String notes);

  /// Mengambil detail persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<ApprovalModel> getApprovalDetail(int approvalId);
}

class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final String baseUrl;
  static const String _tag = 'ApprovalRemoteDataSource';

  ApprovalRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? Constants.baseUrl;

  @override
  Future<List<ApprovalModel>> getApprovals(int userId) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-dadakan/$userId',
      );

      Logger.info(_tag, 'Mengambil data approval untuk user_id: $userId');
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

        final List<dynamic> approvalsJson = data;
        return approvalsJson
            .map((json) => ApprovalModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal memuat data persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getApprovals', e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ApprovalModel>> filterApprovals(ApprovalFilter filter) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final queryParams = <String, String>{};
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery!;
      }
      if (filter.month != null) {
        queryParams['month'] = filter.month.toString();
      }
      if (filter.year != null) {
        queryParams['year'] = filter.year.toString();
      }
      if (filter.status != null) {
        queryParams['status'] = filter.status.toString();
      }
      if (filter.userId != null) {
        queryParams['user_id'] = filter.userId.toString();
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-dadakan',
        queryParameters: queryParams,
      );

      Logger.info(
          _tag, 'Memfilter data approval dengan parameter: $queryParams');
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

        if (!jsonResponse.containsKey('data')) {
          throw ServerException(
              message: 'Format response tidak valid: data tidak ditemukan');
        }

        final data = jsonResponse['data'];
        if (data is! List) {
          throw ServerException(
              message: 'Format response tidak valid: data bukan array');
        }

        final List<dynamic> approvalsJson = data;
        return approvalsJson
            .map((json) => ApprovalModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message:
                'Gagal memfilter data persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'filterApprovals', e.toString());
      rethrow;
    }
  }

  @override
  Future<ApprovalResponseModel> sendApproval(int scheduleId, int userId,
      {required bool isApproved}) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path:
            '${Uri.parse(baseUrl).path}/approved-suddenly/$scheduleId/$userId',
        queryParameters: {
          'is_approved': isApproved.toString(),
        },
      );

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
        return ApprovalResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal mengirim persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'sendApproval', e.toString());
      rethrow;
    }
  }

  @override
  Future<void> approveRequest(int approvalId, String notes) async {
    await sendApproval(approvalId, approvalId, isApproved: true);
  }

  @override
  Future<void> rejectRequest(int approvalId, String notes) async {
    await sendApproval(approvalId, approvalId, isApproved: false);
  }

  @override
  Future<ApprovalModel> getApprovalDetail(int approvalId) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final userDataString = sharedPreferences.getString(Constants.userDataKey);
      if (userDataString == null) {
        throw UnauthorizedException(message: 'Data user tidak ditemukan');
      }

      final userData = json.decode(userDataString);
      final userId = userData['id_user'] as int;

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-dadakan/$userId',
      );

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

        if (!jsonResponse.containsKey('data')) {
          throw ServerException(
              message: 'Format response tidak valid: data tidak ditemukan');
        }

        return ApprovalModel.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal memuat detail persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getApprovalDetail', e.toString());
      rethrow;
    }
  }
}
