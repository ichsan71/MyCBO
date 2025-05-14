import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedules(int userId);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  ScheduleRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<List<ScheduleModel>> getSchedules(int userId) async {
    try {
      // Logging untuk debugging
      Logger.info('ScheduleRemoteDataSource', 'Memulai request ke API schedule dengan userId: $userId');
      // Ambil token dari SharedPreferences
      final token = sharedPreferences.getString(Constants.tokenKey);
      
      Logger.info('ScheduleRemoteDataSource', 'Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');
    
      if (token == null) {
        Logger.error('ScheduleRemoteDataSource', 'Token tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Pastikan token tersedia di header
      final options = Options(
        validateStatus: (status) => true, // Terima semua status untuk debugging
        responseType: ResponseType.json, // Coba minta respons dalam format JSON
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Endpoint URL
      final String url = '${Constants.baseUrl}/schedule/$userId';
      Logger.info('ScheduleRemoteDataSource', 'URL request: $url');
    
      // Mengirim request dengan timeout
      final response = await dio
          .get(
        url,
        options: options,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ServerException(
              message:
                  'Waktu permintaan habis. Silakan periksa koneksi Anda dan coba lagi.');
        },
      );

      Logger.info('ScheduleRemoteDataSource', 'Status response: ${response.statusCode}');
      Logger.info('ScheduleRemoteDataSource', 'Response data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final scheduleResponse =
              ScheduleResponseModel.fromJson(response.data);
          return scheduleResponse.data.data;
        } catch (e) {
          Logger.error('ScheduleRemoteDataSource', 'Error parsing response data: $e');
          throw ServerException(
              message: 'Format data jadwal tidak sesuai: ${e.toString()}');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil data jadwal. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.error('ScheduleRemoteDataSource', 'DioError: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }
      throw ServerException(
          message:
              'Terjadi kesalahan saat mengambil data jadwal: ${e.message}');
    } catch (e) {
      Logger.error('ScheduleRemoteDataSource', 'Error tidak terduga: $e');
      throw ServerException(
          message: 'Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }
}
