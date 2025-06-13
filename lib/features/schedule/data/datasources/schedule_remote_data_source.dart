import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
      Logger.info('ScheduleRemoteDataSource',
          'Memulai request ke API schedule dengan userId: $userId');

      final token = sharedPreferences.getString(Constants.tokenKey);
      Logger.info('ScheduleRemoteDataSource',
          'Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.error('ScheduleRemoteDataSource',
            'Token tidak ditemukan di SharedPreferences');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        validateStatus: (status) {
          return status !=
              null; // Accept all status codes and handle them in the response
        },
      );

      final String url = '${Constants.baseUrl}/schedule/$userId';
      Logger.info('ScheduleRemoteDataSource', 'URL request: $url');

      // Add retry logic
      int retryCount = 0;
      const maxRetries = 3;
      Response? response;
      DioException? lastError;

      while (retryCount < maxRetries) {
        try {
          response = await dio
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

          // If we get here, the request was successful
          break;
        } on DioException catch (e) {
          lastError = e;
          if (e.response?.statusCode == 500) {
            retryCount++;
            if (retryCount < maxRetries) {
              Logger.info('ScheduleRemoteDataSource',
                  'Retrying request after 500 error (attempt $retryCount of $maxRetries)');
              await Future.delayed(
                  Duration(seconds: 2 * retryCount)); // Exponential backoff
              continue;
            }
          }
          rethrow;
        }
      }

      if (response == null) {
        throw lastError ??
            ServerException(
                message: 'Failed to make request after $maxRetries attempts');
      }

      // Handle 500 error specifically
      if (response.statusCode == 500) {
        Logger.error('ScheduleRemoteDataSource', 'Server error (500) detected');
        Logger.error(
            'ScheduleRemoteDataSource', 'Response data: ${response.data}');
        throw ServerException(
          message:
              'Terjadi kesalahan pada server. Silakan coba lagi dalam beberapa saat.',
        );
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('ScheduleRemoteDataSource', '❌ DioError details:');
      Logger.error('ScheduleRemoteDataSource',
          '- Message: ${e.message ?? "No message"}');
      Logger.error('ScheduleRemoteDataSource', '- Type: ${e.type}');
      Logger.error(
          'ScheduleRemoteDataSource', '- Error: ${e.error ?? "No error"}');

      if (e.response != null) {
        Logger.error(
            'ScheduleRemoteDataSource', '- Status: ${e.response?.statusCode}');
        Logger.error(
            'ScheduleRemoteDataSource', '- Response: ${e.response?.data}');
      }

      // Check for authentication errors
      if (e.error?.toString().contains('Sesi login telah berakhir') == true ||
          e.message?.contains('Sesi login telah berakhir') == true ||
          e.response?.statusCode == 302 ||
          e.response?.statusCode == 401) {
        Logger.error(
            'ScheduleRemoteDataSource', '🔐 Authentication error detected');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Handle 500 errors
      if (e.response?.statusCode == 500) {
        Logger.error(
            'ScheduleRemoteDataSource', '❌ Server error (500) detected');
        throw ServerException(
          message:
              'Terjadi kesalahan pada server. Silakan coba lagi dalam beberapa saat.',
        );
      }

      // For other errors
      final errorMessage =
          e.error?.toString() ?? e.message ?? 'Unknown error occurred';
      Logger.error('ScheduleRemoteDataSource',
          '❌ Throwing ServerException: $errorMessage');
      throw ServerException(
          message:
              'Terjadi kesalahan saat mengambil data jadwal: $errorMessage');
    } catch (e) {
      Logger.error('ScheduleRemoteDataSource', '❌ Unexpected error: $e');
      if (e is UnauthorizedException) {
        Logger.error(
            'ScheduleRemoteDataSource', '🔐 Rethrowing UnauthorizedException');
        rethrow;
      }
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
          message: 'Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  List<ScheduleModel> _handleResponse(Response response) {
    try {
      Logger.info('ScheduleRemoteDataSource', 'Handling response...');
      Logger.info(
          'ScheduleRemoteDataSource', '- Status: ${response.statusCode}');
      Logger.info(
          'ScheduleRemoteDataSource', '- Type: ${response.data.runtimeType}');

      if (response.data == null) {
        throw ServerException(message: 'Response data is null');
      }

      if (response.data is String &&
          response.data.toString().contains('Redirecting to')) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Handle the paginated response structure
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data;

        // Check if the response has the expected structure
        if (responseData.containsKey('status') &&
            responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic> &&
            responseData['data'].containsKey('data')) {
          // Extract the actual schedule data array
          final List<dynamic> scheduleData = responseData['data']['data'];

          Logger.info('ScheduleRemoteDataSource',
              'Successfully processed ${scheduleData.length} schedules');

          return scheduleData
              .map((item) => ScheduleModel.fromJson(item))
              .toList();
        }
      }

      throw ServerException(message: 'Unexpected response format');
    } catch (e) {
      Logger.error(
          'ScheduleRemoteDataSource', '❌ Error in _handleResponse: $e');
      rethrow;
    }
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByRangeDate(
      int userId, String rangeDate) async {
    try {
      Logger.info('ScheduleRemoteDataSource', '====== START REQUEST ======');
      Logger.info('ScheduleRemoteDataSource', 'Endpoint: /filter-schedule');
      Logger.info('ScheduleRemoteDataSource', 'User ID: $userId');
      Logger.info('ScheduleRemoteDataSource', 'Range Date: $rangeDate');

      final token = sharedPreferences.getString(Constants.tokenKey);
      Logger.info(
          'ScheduleRemoteDataSource', 'Token available: ${token != null}');
      if (token != null) {
        Logger.info('ScheduleRemoteDataSource',
            'Token prefix: ${token.substring(0, min(10, token.length))}...');
      }

      if (token == null) {
        Logger.error(
            'ScheduleRemoteDataSource', 'Token not found in SharedPreferences');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      final options = Options(
        validateStatus: (status) {
          return status != null;
        },
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info('ScheduleRemoteDataSource', 'Request headers:');
      options.headers?.forEach((key, value) {
        if (key == 'Authorization') {
          Logger.info('ScheduleRemoteDataSource',
              '  $key: Bearer ${value.toString().substring(7, min(17, value.toString().length))}...');
        } else {
          Logger.info('ScheduleRemoteDataSource', '  $key: $value');
        }
      });

      // Format range date
      String formattedRangeDate = rangeDate;
      if (rangeDate.contains('-')) {
        final dates = rangeDate.split('-').map((d) => d.trim()).toList();
        if (dates.length == 2) {
          formattedRangeDate = '${dates[0]} - ${dates[1]}';
          Logger.info('ScheduleRemoteDataSource',
              'Formatted range date: $formattedRangeDate');
        }
      }

      // Prepare request data
      final requestData = {
        'id_user': userId.toString(),
        'range_date': formattedRangeDate,
        'per_page': '10',
        'page': '1',
      };

      Logger.info('ScheduleRemoteDataSource', 'Request data:');
      requestData.forEach((key, value) {
        Logger.info('ScheduleRemoteDataSource', '  $key: $value');
      });

      // Create FormData
      final formData = FormData.fromMap(requestData);
      Logger.info('ScheduleRemoteDataSource', 'FormData fields:');
      formData.fields.forEach((field) {
        Logger.info(
            'ScheduleRemoteDataSource', '  ${field.key}: ${field.value}');
      });

      final url = '${Constants.baseUrl}/filter-schedule';
      Logger.info('ScheduleRemoteDataSource', 'Request URL: $url');

      Logger.info('ScheduleRemoteDataSource', 'Sending request...');
      final response = await dio
          .post(
        url,
        data: formData,
        options: options,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          Logger.error(
              'ScheduleRemoteDataSource', 'Request timeout after 30 seconds');
          throw ServerException(
              message:
                  'Waktu permintaan habis. Silakan periksa koneksi Anda dan coba lagi.');
        },
      );

      Logger.info('ScheduleRemoteDataSource', '====== RESPONSE ======');
      Logger.info(
          'ScheduleRemoteDataSource', 'Status code: ${response.statusCode}');
      Logger.info('ScheduleRemoteDataSource',
          'Response type: ${response.data.runtimeType}');
      Logger.info('ScheduleRemoteDataSource', 'Response headers:');
      response.headers.forEach((name, values) {
        Logger.info('ScheduleRemoteDataSource', '  $name: $values');
      });

      if (response.data != null) {
        if (response.data is Map) {
          Logger.info('ScheduleRemoteDataSource',
              'Response data keys: ${(response.data as Map).keys.join(', ')}');
        }
        Logger.info(
            'ScheduleRemoteDataSource', 'Response data: ${response.data}');
      }

      // Handle different response status codes
      if (response.statusCode == 500) {
        Logger.error('ScheduleRemoteDataSource', 'Server returned 500 error');
        Logger.error(
            'ScheduleRemoteDataSource', 'Response data: ${response.data}');
        throw ServerException(
            message:
                'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.');
      }

      if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      if (response.statusCode != 200) {
        throw ServerException(
            message:
                'Terjadi kesalahan saat mengambil data jadwal. Status: ${response.statusCode}');
      }

      // Check for HTML redirect response
      if (response.data is String &&
          response.data.toString().contains('Redirecting to')) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Parse response data
      if (response.data == null) {
        return [];
      }

      try {
        final responseModel = ScheduleResponseModel.fromJson(response.data);
        return responseModel.data.data;
      } catch (e) {
        Logger.error('ScheduleRemoteDataSource',
            'Error parsing response data: $e\nResponse data: ${response.data}');
        throw ServerException(
            message: 'Terjadi kesalahan saat memproses data dari server.');
      }
    } catch (e) {
      Logger.error(
          'ScheduleRemoteDataSource', 'Error in getSchedulesByRangeDate: $e');
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw ServerException(
              message:
                  'Waktu permintaan habis. Silakan periksa koneksi Anda dan coba lagi.');
        }
      }
      rethrow;
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
