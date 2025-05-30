import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tipe_schedule_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';

abstract class TipeScheduleRemoteDataSource {
  /// Mengambil list tipe schedule dari API
  /// Throws [ServerException] jika terjadi kesalahan saat request
  Future<List<TipeScheduleModel>> getTipeSchedules();
}

class TipeScheduleRemoteDataSourceImpl implements TipeScheduleRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  static const String _tag = 'TipeScheduleRemoteDataSource';

  TipeScheduleRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<List<TipeScheduleModel>> getTipeSchedules() async {
    try {
      Logger.info(_tag, '🔄 Memulai request ke API tipe jadwal');

      // Ambil token dari SharedPreferences
      final token = sharedPreferences.getString(Constants.tokenKey);
      Logger.info(_tag, '🔄 Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.warning(_tag, '❌ Token tidak ditemukan di SharedPreferences');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/tipe-schedule/get'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info(_tag, '🔄 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          Logger.info(_tag, '✅ Berhasil decode response JSON');

          if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
            final tipeSchedules =
                TipeScheduleModel.fromJsonList(jsonResponse['data']);
            Logger.success(
                _tag, '✅ Berhasil parse ${tipeSchedules.length} tipe jadwal');
            return tipeSchedules;
          } else {
            final message = jsonResponse['message'] ??
                'Gagal mendapatkan data tipe schedule';
            Logger.error(_tag, '❌ API Error: $message');
            throw ServerException(message: message);
          }
        } catch (e) {
          Logger.error(_tag, '❌ Error parsing response: $e');
          throw ServerException(
              message: 'Gagal memproses response dari server');
        }
      } else if (response.statusCode == 401) {
        Logger.error(_tag, '❌ Unauthorized: ${response.statusCode}');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        Logger.error(_tag, '❌ Server error: ${response.statusCode}');
        throw ServerException(
            message: 'Gagal terhubung dengan server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        rethrow;
      }
      Logger.error(_tag, '❌ Exception: $e');
      throw ServerException(message: e.toString());
    }
  }
}
