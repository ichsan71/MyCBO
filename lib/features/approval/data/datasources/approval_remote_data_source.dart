import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/approval_model.dart';
import '../models/approval_response_model.dart';

abstract class ApprovalRemoteDataSource {
  /// Mengambil daftar persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> getApprovals(int userId);

  /// Mengirim persetujuan (setuju atau tolak)
  /// Throws [ServerException] jika terjadi error pada server
  Future<ApprovalResponseModel> sendApproval(int scheduleId, int userId,
      {required bool isApproved});
}

class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final String baseUrl;
  static const String _tag = 'ApprovalRemoteDataSource';

  ApprovalRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
    this.baseUrl = 'https://dev-bco.businesscorporateofficer.com/api',
  });

  @override
  Future<List<ApprovalModel>> getApprovals(int userId) async {
    final url = Uri.parse('$baseUrl/list-approval-dadakan/$userId');

    try {
      Logger.info(_tag, '🔄 Memulai request ke API approval');
      Logger.info(_tag, '🔍 URL: $url');
      Logger.info(_tag, '👤 User ID: $userId');

      // Debug SharedPreferences
      final allKeys = sharedPreferences.getKeys();
      Logger.info(_tag, '🔑 SharedPreferences keys: $allKeys');

      // Ambil token dan data user
      final token = sharedPreferences.getString(Constants.tokenKey);
      final userDataString = sharedPreferences.getString(Constants.userDataKey);

      Logger.info(_tag, '🎫 Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');
      Logger.info(_tag,
          '👤 User data tersedia: ${userDataString != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.error(_tag, '❌ Token tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      if (userDataString == null) {
        Logger.error(_tag, '❌ Data user tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Data pengguna tidak ditemukan. Silakan login kembali.');
      }

      // Validasi data user
      try {
        final userData = json.decode(userDataString);
        final storedUserId = userData['id_user'];
        Logger.info(
            _tag, '🔍 Stored user ID: $storedUserId, Request user ID: $userId');

        if (storedUserId != userId) {
          Logger.warning(_tag, '⚠️ User ID tidak sesuai dengan data tersimpan');
          throw ServerException(
              message: 'ID pengguna tidak valid. Silakan login kembali.');
        }
      } catch (e) {
        Logger.error(_tag, '❌ Error saat memvalidasi data user: $e');
        throw ServerException(
            message: 'Data pengguna tidak valid. Silakan login kembali.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Logger.info(_tag, '📤 Headers request:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          Logger.info(
              _tag, '   $key: Bearer ${value.substring(7, 20)}... (truncated)');
        } else {
          Logger.info(_tag, '   $key: $value');
        }
      });

      final response = await client.get(
        url,
        headers: headers,
      );

      Logger.info(_tag, '📥 Status response: ${response.statusCode}');
      Logger.info(_tag, '📥 Headers response: ${response.headers}');

      if (response.body.isNotEmpty) {
        final truncatedBody = response.body.length > 100
            ? '${response.body.substring(0, 100)}...'
            : response.body;
        Logger.info(_tag, '📥 Body response (truncated): $truncatedBody');
      } else {
        Logger.warning(_tag, '⚠️ Body response kosong');
      }

      // Check if response is JSON
      final contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/json')) {
        Logger.error(_tag, '❌ Content-Type tidak sesuai: $contentType');
        throw ServerException(
          message:
              'Server mengembalikan data bukan dalam format JSON: $contentType',
        );
      }

      if (response.statusCode == 200) {
        try {
          Logger.info(_tag, '🔄 Mencoba parse JSON response');
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          Logger.info(_tag, '✅ Status dari JSON: ${jsonResponse['status']}');

          if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
            final List<dynamic> approvalData = jsonResponse['data'];
            Logger.info(
                _tag, '✅ Jumlah data persetujuan: ${approvalData.length}');

            final result = approvalData
                .map((data) => ApprovalModel.fromJson(data))
                .toList();

            Logger.success(_tag,
                '✅ Berhasil mendapatkan ${result.length} data persetujuan');
            return result;
          } else {
            Logger.info(_tag, '⚠️ Data persetujuan kosong atau status false');
            return [];
          }
        } catch (e) {
          Logger.error(_tag, '❌ Error saat parsing JSON: $e');
          throw ServerException(
            message: 'Gagal memproses data JSON: ${e.toString()}',
          );
        }
      } else if (response.statusCode == 401) {
        Logger.error(_tag, '❌ Error 401 Unauthorized');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        Logger.error(
            _tag, '❌ Error dengan status code: ${response.statusCode}');
        throw ServerException(
          message: _getErrorMessage(response) ??
              'Gagal mendapatkan data persetujuan (${response.statusCode})',
        );
      }
    } catch (e) {
      Logger.error(_tag, '❌ Error dalam getApprovals: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<ApprovalResponseModel> sendApproval(int scheduleId, int userId,
      {required bool isApproved}) async {
    final url = Uri.parse(
        '$baseUrl/approved-suddenly/$scheduleId/$userId?approved=${isApproved ? 1 : 0}');

    try {
      Logger.info(_tag, '🔄 Memulai request persetujuan');
      Logger.info(_tag, '🔍 URL: $url');
      Logger.info(_tag, '👤 User ID: $userId');
      Logger.info(_tag, '📅 Schedule ID: $scheduleId');
      Logger.info(_tag, '✅ isApproved: $isApproved');

      // Debug SharedPreferences
      final allKeys = sharedPreferences.getKeys();
      Logger.info(_tag, '🔑 SharedPreferences keys: $allKeys');

      // Ambil token dan data user
      final token = sharedPreferences.getString(Constants.tokenKey);
      final userDataString = sharedPreferences.getString(Constants.userDataKey);

      Logger.info(_tag, '🎫 Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');
      Logger.info(_tag,
          '👤 User data tersedia: ${userDataString != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.error(_tag, '❌ Token tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      if (userDataString == null) {
        Logger.error(_tag, '❌ Data user tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Data pengguna tidak ditemukan. Silakan login kembali.');
      }

      // Validasi data user
      try {
        final userData = json.decode(userDataString);
        final storedUserId = userData['id_user'];
        Logger.info(
            _tag, '🔍 Stored user ID: $storedUserId, Request user ID: $userId');

        if (storedUserId != userId) {
          Logger.warning(_tag, '⚠️ User ID tidak sesuai dengan data tersimpan');
          throw ServerException(
              message: 'ID pengguna tidak valid. Silakan login kembali.');
        }
      } catch (e) {
        Logger.error(_tag, '❌ Error saat memvalidasi data user: $e');
        throw ServerException(
            message: 'Data pengguna tidak valid. Silakan login kembali.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Logger.info(_tag, '📤 Headers request:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          Logger.info(
              _tag, '   $key: Bearer ${value.substring(7, 20)}... (truncated)');
        } else {
          Logger.info(_tag, '   $key: $value');
        }
      });

      final response = await client.get(
        url,
        headers: headers,
      );

      Logger.info(_tag, '📥 Status response: ${response.statusCode}');
      Logger.info(_tag, '📥 Headers response: ${response.headers}');

      if (response.body.isNotEmpty) {
        final truncatedBody = response.body.length > 100
            ? '${response.body.substring(0, 100)}...'
            : response.body;
        Logger.info(_tag, '📥 Body response (truncated): $truncatedBody');
      } else {
        Logger.warning(_tag, '⚠️ Body response kosong');
      }

      // Check if response is JSON
      final contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/json')) {
        Logger.error(_tag, '❌ Content-Type tidak sesuai: $contentType');
        throw ServerException(
          message:
              'Server mengembalikan data bukan dalam format JSON: $contentType',
        );
      }

      if (response.statusCode == 200) {
        try {
          Logger.info(_tag, '🔄 Mencoba parse JSON response');
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          Logger.success(_tag, '✅ Berhasil mengirim persetujuan');
          return ApprovalResponseModel.fromJson(jsonResponse);
        } catch (e) {
          Logger.error(_tag, '❌ Error saat parsing JSON: $e');
          throw ServerException(
            message: 'Gagal memproses data JSON: ${e.toString()}',
          );
        }
      } else if (response.statusCode == 401) {
        Logger.error(_tag, '❌ Error 401 Unauthorized');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        Logger.error(
            _tag, '❌ Error dengan status code: ${response.statusCode}');
        throw ServerException(
          message: _getErrorMessage(response) ??
              'Gagal mengirim persetujuan (${response.statusCode})',
        );
      }
    } catch (e) {
      Logger.error(_tag, '❌ Error dalam sendApproval: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  String? _getErrorMessage(http.Response response) {
    try {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['message'];
      }
      return 'Status code: ${response.statusCode}, Body: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}';
    } catch (_) {
      return null;
    }
  }
}
