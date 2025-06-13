import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../schedule/data/models/checkin_request_model.dart';
import '../../../schedule/data/models/checkout_request_model.dart';

abstract class CheckInRemoteDataSource {
  Future<void> checkIn(CheckinRequestModel request);
  Future<void> checkOut(CheckoutRequestModel request);
}

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;
  static const String _tag = 'CheckInRemoteDataSource';

  CheckInRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<void> checkIn(CheckinRequestModel request) async {
    try {
      Logger.info(_tag, 'Starting check-in process...');

      // Get token from SharedPreferences
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token not found');
        throw UnauthorizedException(
            message: 'Token not found. Please login again.');
      }

      // Prepare request data
      final formData = FormData.fromMap({
        'id_schedule': request.idSchedule.toString(),
        'lokasi': request.lokasi,
        'note': request.note,
        'foto': await MultipartFile.fromFile(request.foto),
      });

      Logger.info(_tag, 'Sending check-in request...');
      Logger.debug(_tag, 'Request data: ${request.toJson()}');

      // Make API call
      final response = await dio.post(
        '${Constants.baseUrl}/checkin',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      Logger.info(_tag, 'Check-in response status: ${response.statusCode}');
      Logger.debug(_tag, 'Response data: ${response.data}');

      if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: Token might be expired');
        throw UnauthorizedException(
            message: 'Session expired. Please login again.');
      }

      if (response.statusCode != 200) {
        final message = response.data['message'] ?? 'Check-in failed';
        Logger.error(_tag, 'Server error: $message');
        throw ServerException(message: message);
      }

      Logger.success(_tag, 'Check-in successful');
    } catch (e) {
      Logger.error(_tag, 'Error during check-in: $e');
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> checkOut(CheckoutRequestModel request) async {
    try {
      Logger.info(_tag, 'Starting check-out process...');

      // Get token from SharedPreferences
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        Logger.error(_tag, 'Token not found');
        throw UnauthorizedException(
            message: 'Token not found. Please login again.');
      }

      // Prepare request data
      final formData = FormData.fromMap({
        'id_schedule': request.idSchedule.toString(),
        'status': request.status,
        'note': request.note,
        'foto': await MultipartFile.fromFile(request.foto),
        if (request.tglScheduleLanjutan.isNotEmpty)
          'tgl_schedule_lanjutan': request.tglScheduleLanjutan,
      });

      Logger.info(_tag, 'Sending check-out request...');
      Logger.debug(_tag, 'Request data: ${request.toJson()}');

      // Make API call
      final response = await dio.post(
        '${Constants.baseUrl}/checkout',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      Logger.info(_tag, 'Check-out response status: ${response.statusCode}');
      Logger.debug(_tag, 'Response data: ${response.data}');

      if (response.statusCode == 401) {
        Logger.error(_tag, 'Unauthorized: Token might be expired');
        throw UnauthorizedException(
            message: 'Session expired. Please login again.');
      }

      if (response.statusCode != 200) {
        final message = response.data['message'] ?? 'Check-out failed';
        Logger.error(_tag, 'Server error: $message');
        throw ServerException(message: message);
      }

      Logger.success(_tag, 'Check-out successful');
    } catch (e) {
      Logger.error(_tag, 'Error during check-out: $e');
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
