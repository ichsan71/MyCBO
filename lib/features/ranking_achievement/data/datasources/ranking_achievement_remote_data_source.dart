import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/network/api_config.dart';
import 'package:test_cbo/features/ranking_achievement/data/models/ranking_achievement_model.dart';
import 'package:flutter/foundation.dart';

abstract class RankingAchievementRemoteDataSource {
  Future<RankingAchievementResponse> getRankingAchievement(String roleId);
}

class RankingAchievementRemoteDataSourceImpl
    implements RankingAchievementRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  RankingAchievementRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<RankingAchievementResponse> getRankingAchievement(
      String roleId) async {
    try {
      debugPrint(
          'RankingAchievementRemoteDataSource - Fetching data for roleId: $roleId');

      final token = sharedPreferences.getString('token');
      final headers = ApiConfig.getHeaders(token);

      final response = await dio.get(
        '${ApiConfig.baseUrl}/rangking-achievement/role/$roleId',
        options: Options(
          headers: headers,
        ),
      );

      debugPrint(
          'RankingAchievementRemoteDataSource - Response status: ${response.statusCode}');
      debugPrint(
          'RankingAchievementRemoteDataSource - Response data: ${response.data}');

      if (response.statusCode == 200) {
        return RankingAchievementResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ranking achievement data');
      }
    } on DioException catch (e) {
      debugPrint(
          'RankingAchievementRemoteDataSource - DioException: ${e.message}');
      debugPrint(
          'RankingAchievementRemoteDataSource - DioException type: ${e.type}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Data not found for this role.');
      } else {
        throw Exception(
            'Failed to load ranking achievement data: ${e.message}');
      }
    } catch (e) {
      debugPrint('RankingAchievementRemoteDataSource - Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
