import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/schedule.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response_model.dart';
import '../models/edit_schedule_data_model.dart';
import '../models/edit/edit_schedule_response_model.dart';
import '../models/update_schedule_request_model.dart';
import 'package:intl/intl.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedules(int userId);
  Future<List<ScheduleModel>> getSchedulesByRangeDate(
      int userId, String rangeDate);
  Future<EditScheduleDataModel> getEditScheduleData(int scheduleId);
  Future<void> updateSchedule(UpdateScheduleRequestModel requestModel);
  Future<List<ScheduleModel>> getRejectedSchedules(int userId);
  Future<EditScheduleResponseModel> fetchEditScheduleData(int scheduleId);
  Future<void> saveEditedSchedule(Schedule schedule);
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
      Logger.info('ScheduleRemoteDataSource',
          'Memulai request ke API schedule dengan userId: $userId');
      // Ambil token dari SharedPreferences
      final token = sharedPreferences.getString(Constants.tokenKey);

      Logger.info('ScheduleRemoteDataSource',
          'Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.error('ScheduleRemoteDataSource',
            'Token tidak ditemukan di SharedPreferences');
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

      Logger.info('ScheduleRemoteDataSource',
          'Status response: ${response.statusCode}');
      Logger.info(
          'ScheduleRemoteDataSource', 'Response data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final dynamic rawData = response.data;
          Logger.info('ScheduleRemoteDataSource',
              'Tipe response.data: ${rawData.runtimeType}');

          // Log raw data structure
          if (rawData is Map<String, dynamic>) {
            Logger.info('ScheduleRemoteDataSource',
                'Keys in response: ${rawData.keys.toList()}');
            if (rawData['data'] != null) {
              Logger.info('ScheduleRemoteDataSource',
                  'Data type: ${rawData['data'].runtimeType}');

              // Log the first item in data array if it exists
              if (rawData['data'] is List &&
                  (rawData['data'] as List).isNotEmpty) {
                final firstItem = (rawData['data'] as List).first;
                Logger.info('ScheduleRemoteDataSource',
                    'First item in data: $firstItem');
                if (firstItem is Map<String, dynamic>) {
                  Logger.info('ScheduleRemoteDataSource',
                      'type_schedule value: ${firstItem['type_schedule']}');
                  Logger.info('ScheduleRemoteDataSource',
                      'nama_type_schedule value: ${firstItem['nama_type_schedule']}');
                }
              }
            }
          }

          final scheduleResponse = rawData is List
              ? ScheduleResponseModel.fromJson({'data': rawData})
              : ScheduleResponseModel.fromJson(rawData);

          // Log processed data
          Logger.info('ScheduleRemoteDataSource',
              'Number of schedules: ${scheduleResponse.data.data.length}');
          for (var schedule in scheduleResponse.data.data.take(1)) {
            Logger.info('ScheduleRemoteDataSource',
                'Sample schedule - tipeSchedule: ${schedule.tipeSchedule}, namaTipeSchedule: ${schedule.namaTipeSchedule}');
          }

          return scheduleResponse.data.data;
        } catch (e) {
          Logger.error(
              'ScheduleRemoteDataSource', 'Error parsing response data: $e');
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

  @override
  Future<List<ScheduleModel>> getSchedulesByRangeDate(
      int userId, String rangeDate) async {
    try {
      Logger.info('ScheduleRemoteDataSource',
          'Request jadwal by range date: userId=$userId, rangeDate=$rangeDate');
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }
      final options = Options(
        validateStatus: (status) => true,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Convert date format if needed (yyyy-MM-dd to MM/dd/yyyy)
      final dates = rangeDate.split(' - ');
      if (dates.length == 2) {
        try {
          final startDate = DateTime.parse(dates[0]);
          final endDate = DateTime.parse(dates[1]);
          rangeDate =
              "${DateFormat('MM/dd/yyyy').format(startDate)} - ${DateFormat('MM/dd/yyyy').format(endDate)}";
          Logger.info(
              'ScheduleRemoteDataSource', 'Converted date range: $rangeDate');
        } catch (e) {
          Logger.error(
              'ScheduleRemoteDataSource', 'Error converting date format: $e');
        }
      }

      final data = {
        'id_user': userId,
        'range_date': rangeDate,
      };

      const String url = '${Constants.baseUrl}/filter-schedule';
      Logger.info('ScheduleRemoteDataSource', 'Request URL: $url');
      Logger.info('ScheduleRemoteDataSource', 'Request data: $data');

      final response =
          await dio.post(url, data: data, options: options).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ServerException(
              message:
                  'Waktu permintaan habis. Silakan periksa koneksi Anda dan coba lagi.');
        },
      );

      Logger.info('ScheduleRemoteDataSource',
          'Response status: ${response.statusCode}');
      Logger.info(
          'ScheduleRemoteDataSource', 'Response data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final dynamic rawData = response.data;
          Logger.info('ScheduleRemoteDataSource', 'Raw API response: $rawData');

          List<ScheduleModel> schedules = [];

          if (rawData is Map<String, dynamic> && rawData['data'] is List) {
            final List<dynamic> scheduleList = rawData['data'];
            Logger.info(
                'ScheduleRemoteDataSource', 'Raw schedule list: $scheduleList');

            // Log first schedule data if available
            if (scheduleList.isNotEmpty) {
              Logger.info('ScheduleRemoteDataSource', 'First schedule data:');
              Logger.info('ScheduleRemoteDataSource',
                  '  Raw data: ${scheduleList.first}');
              Logger.info('ScheduleRemoteDataSource',
                  '  Shift value: ${scheduleList.first['shift']}');
            }

            schedules = scheduleList
                .map((schedule) {
                  try {
                    Logger.info('ScheduleRemoteDataSource',
                        'Processing schedule with shift: ${schedule['shift']}');
                    return ScheduleModel.fromJson(schedule);
                  } catch (e) {
                    Logger.error('ScheduleRemoteDataSource',
                        'Error parsing schedule: $e');
                    return ScheduleModel
                        .empty(); // Return empty model instead of throwing
                  }
                })
                .where((schedule) => schedule.id != 0)
                .toList(); // Filter out empty models

            Logger.info('ScheduleRemoteDataSource',
                'Processed schedules count: ${schedules.length}');
          } else {
            Logger.warning('ScheduleRemoteDataSource',
                'Invalid response format or empty data');
          }

          return schedules;
        } catch (e) {
          Logger.error(
              'ScheduleRemoteDataSource', 'Error parsing response: $e');
          return []; // Return empty list instead of throwing
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Gagal mengambil data jadwal'
            : 'Gagal mengambil data jadwal';
        throw ServerException(
            message: '$errorMessage. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.error('ScheduleRemoteDataSource', 'DioError: ${e.toString()}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }
      final errorMessage =
          e.response?.data is Map ? e.response?.data['message'] : null;
      throw ServerException(
          message: errorMessage ??
              'Terjadi kesalahan saat mengambil data jadwal: ${e.message}');
    } catch (e) {
      Logger.error(
          'ScheduleRemoteDataSource', 'Unexpected error: ${e.toString()}');
      throw ServerException(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<EditScheduleDataModel> getEditScheduleData(int scheduleId) async {
    try {
      Logger.info('ScheduleRemoteDataSource',
          'Memulai request ke API form-update-schedule dengan scheduleId: $scheduleId');

      final token = sharedPreferences.getString(Constants.tokenKey);

      Logger.info('ScheduleRemoteDataSource',
          'Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.error('ScheduleRemoteDataSource',
            'Token tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      final options = Options(
        validateStatus: (status) => true,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final String url =
          '${Constants.baseUrl}/form-update-schedule/$scheduleId';
      Logger.info('ScheduleRemoteDataSource', 'URL request: $url');

      final response = await dio.get(url, options: options).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ServerException(
              message:
                  'Waktu permintaan habis. Silakan periksa koneksi Anda dan coba lagi.');
        },
      );

      Logger.info('ScheduleRemoteDataSource',
          'Status response: ${response.statusCode}');
      Logger.info(
          'ScheduleRemoteDataSource', 'Response data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final dynamic rawData = response.data;
          if (rawData is Map<String, dynamic>) {
            // Check if the status is true before parsing data
            if (rawData['status'] == true) {
              return EditScheduleDataModel.fromJson(rawData);
            } else {
              // Handle API response where status is false
              String message =
                  rawData['message'] ?? 'Gagal mengambil data edit jadwal';
              Logger.error('ScheduleRemoteDataSource',
                  'API response status false: $message');
              throw ServerException(message: message);
            }
          } else {
            Logger.error('ScheduleRemoteDataSource',
                'Unexpected response data format: ${rawData.runtimeType}');
            throw ServerException(
                message: 'Format data edit jadwal tidak sesuai.');
          }
        } catch (e) {
          Logger.error('ScheduleRemoteDataSource',
              'Error parsing edit schedule data: $e');
          // Re-throw if it's already a ServerException or UnauthorizedException
          if (e is ServerException || e is UnauthorizedException) {
            rethrow;
          }
          throw ServerException(
              message: 'Gagal memproses data edit jadwal: ${e.toString()}');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil data edit jadwal. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.error('ScheduleRemoteDataSource',
          'DioError fetching edit schedule data: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }
      throw ServerException(
          message:
              'Terjadi kesalahan saat mengambil data edit jadwal: ${e.message}');
    } catch (e) {
      Logger.error('ScheduleRemoteDataSource',
          'Error tidak terduga saat mengambil data edit schedule: $e');
      throw ServerException(
          message:
              'Terjadi kesalahan tidak terduga saat mengambil data edit jadwal: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSchedule(UpdateScheduleRequestModel requestModel) async {
    try {
      Logger.info('ScheduleRemoteDataSource',
          'Memulai request update jadwal dengan ID: ${requestModel.id}');

      // Log raw product data
      Logger.info('ScheduleRemoteDataSource',
          'Raw product data: ${requestModel.product}');

      final token = sharedPreferences.getString(Constants.tokenKey);

      if (token == null) {
        Logger.error('ScheduleRemoteDataSource', 'Token tidak ditemukan');
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Convert date format from DD/MM/YYYY to YYYY-MM-DD
      String formattedDate = requestModel.tglVisit;
      try {
        final parts = requestModel.tglVisit.split('/');
        if (parts.length == 3) {
          formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      } catch (e) {
        Logger.error('ScheduleRemoteDataSource', 'Error formatting date: $e');
      }

      // Handle product data
      List<String> products = requestModel.product;
      String productValue = '[]';

      if (products.isNotEmpty) {
        // Remove any empty strings and trim whitespace
        products = products.where((p) => p.trim().isNotEmpty).toList();
        if (products.isNotEmpty) {
          // Convert list to JSON array string
          productValue = json.encode(products);
        }
      }

      Logger.info(
          'ScheduleRemoteDataSource', 'Processed product value: $productValue');

      // Create request map first for logging
      final Map<String, dynamic> requestMap = {
        'id_schedule': requestModel.id.toString(),
        'jenis-schedule': requestModel.jenis,
        'type-schedule': requestModel.typeSchedule.toString(),
        'tujuan': requestModel.tujuan,
        'tgl-visit': formattedDate,
        'shift': requestModel.shift,
        'catatan': requestModel.note,
        'id_user': requestModel.idUser.toString(),
        'dokter': requestModel.dokter.toString(),
        'klinik': requestModel.klinik,
        'product': productValue,
        'id_divisi_sales': requestModel.productForIdDivisi.join(','),
        'id_spesialis': requestModel.productForIdSpesialis.join(','),
      };

      // Log the complete request map
      Logger.info('ScheduleRemoteDataSource', 'Complete request map:');
      requestMap.forEach((key, value) {
        Logger.info('ScheduleRemoteDataSource', '$key: $value');
      });

      final formData = FormData.fromMap(requestMap);

      final options = Options(
        validateStatus: (status) => true,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      const url = '${Constants.baseUrl}/update-schedule/';
      Logger.info('ScheduleRemoteDataSource', 'Request URL: $url');

      final response = await dio
          .post(
        url,
        data: formData,
        options: options,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout setelah 30 detik');
        },
      );

      Logger.info('ScheduleRemoteDataSource',
          'Response status: ${response.statusCode}');
      Logger.info(
          'ScheduleRemoteDataSource', 'Response body: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          Logger.info('ScheduleRemoteDataSource', 'Jadwal berhasil diperbarui');
          return;
        }
        throw ServerException(
            message: response.data['message'] ?? 'Gagal memperbarui jadwal');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        final errorMessage = response.data is Map
            ? (response.data['message'] ?? 'Gagal memperbarui jadwal')
            : 'Gagal memperbarui jadwal';
        throw ServerException(
            message: '$errorMessage (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      Logger.error('ScheduleRemoteDataSource', 'DioError: ${e.message}');
      Logger.error(
          'ScheduleRemoteDataSource', 'DioError Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }
      throw ServerException(
          message: 'Terjadi kesalahan saat memperbarui jadwal: ${e.message}');
    } catch (e) {
      Logger.error('ScheduleRemoteDataSource', 'Error tidak terduga: $e');
      throw ServerException(
          message: 'Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  @override
  Future<List<ScheduleModel>> getRejectedSchedules(int userId) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      final response = await dio.get(
        '${Constants.baseUrl}/rejected-schedules/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      } else {
        throw ServerException(
            message: response.data['message'] ??
                'Failed to fetch rejected schedules');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EditScheduleResponseModel> fetchEditScheduleData(
      int scheduleId) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      final response = await dio.get(
        '${Constants.baseUrl}/schedules/$scheduleId/edit',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return EditScheduleResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
            message: response.data['message'] ??
                'Failed to fetch edit schedule data');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveEditedSchedule(Schedule schedule) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      final response = await dio.put(
        '${Constants.baseUrl}/schedules/${schedule.id}',
        data: {
          'tipe_schedule': schedule.tipeSchedule,
          'tujuan': schedule.tujuan,
          'nama_tujuan': schedule.namaTujuan,
          'tgl_visit': schedule.tglVisit,
          'shift': schedule.shift,
          'note': schedule.note,
          'nama_product': schedule.namaProduct,
          'nama_divisi': schedule.namaDivisi,
          'nama_spesialis': schedule.namaSpesialis,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
            message:
                response.data['message'] ?? 'Failed to save edited schedule');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
