import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chatbot_data_model.dart';
import '../models/chat_feedback_model.dart';

/// Abstract class defining the remote data source interface
abstract class ChatbotRemoteDataSource {
  /// Fetch chatbot data from remote API
  Future<ChatbotDataModel> fetchChatbotData();

  /// Submit feedback to remote API
  Future<void> submitFeedback(ChatFeedbackModel feedback);

  /// Get feedback statistics from remote API
  Future<Map<String, int>> getFeedbackStats(String questionId);

  /// Check if remote data has updates
  Future<bool> hasRemoteUpdates(String currentVersion);
}

/// Implementation of ChatbotRemoteDataSource
class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  ChatbotRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  final Dio dio;
  final SharedPreferences sharedPreferences;

  static const String _chatbotEndpoint = '/chatbot/data';
  static const String _feedbackEndpoint = '/chatbot/feedback';
  static const String _versionEndpoint = '/chatbot/version';

  @override
  Future<ChatbotDataModel> fetchChatbotData() async {
    try {
      final String? token = sharedPreferences.getString('access_token');
      final Response response = await dio.get(
        _chatbotEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return ChatbotDataModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch chatbot data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Connection timeout or network error');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Authentication failed');
      } else if (e.response?.statusCode == 403) {
        throw UnauthorizedException(message: 'Access denied');
      } else {
        throw ServerException(
          message: 'Server error: ${e.response?.statusCode ?? 'Unknown'}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> submitFeedback(ChatFeedbackModel feedback) async {
    try {
      final String? token = sharedPreferences.getString('access_token');
      final Response response = await dio.post(
        _feedbackEndpoint,
        data: feedback.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Failed to submit feedback: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Connection timeout or network error');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Authentication failed');
      } else if (e.response?.statusCode == 403) {
        throw UnauthorizedException(message: 'Access denied');
      } else {
        throw ServerException(
          message: 'Server error: ${e.response?.statusCode ?? 'Unknown'}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<Map<String, int>> getFeedbackStats(String questionId) async {
    try {
      final String? token = sharedPreferences.getString('access_token');
      final Response response = await dio.get(
        '$_feedbackEndpoint/stats/$questionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return Map<String, int>.from(data);
      } else {
        throw ServerException(
          message: 'Failed to get feedback stats: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Connection timeout or network error');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Authentication failed');
      } else if (e.response?.statusCode == 403) {
        throw UnauthorizedException(message: 'Access denied');
      } else {
        throw ServerException(
          message: 'Server error: ${e.response?.statusCode ?? 'Unknown'}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<bool> hasRemoteUpdates(String currentVersion) async {
    try {
      final String? token = sharedPreferences.getString('access_token');
      final Response response = await dio.get(
        _versionEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String remoteVersion = data['version'] as String? ?? '1.0.0';
        return remoteVersion != currentVersion;
      } else {
        // If we can't check version, assume no updates
        return false;
      }
    } catch (e) {
      // If there's any error checking version, assume no updates
      return false;
    }
  }
}
