import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chatbot_data_model.dart';
import '../models/chat_category_model.dart';
import '../models/chat_question_model.dart';
import '../models/chat_feedback_model.dart';

/// Abstract class defining the local data source interface
abstract class ChatbotLocalDataSource {
  /// Load chatbot data from local assets
  Future<ChatbotDataModel> loadFromAssets();

  /// Get cached chatbot data from local storage
  Future<ChatbotDataModel?> getCachedData();

  /// Cache chatbot data to local storage
  Future<void> cacheData(ChatbotDataModel data);

  /// Save feedback to local storage
  Future<void> saveFeedback(ChatFeedbackModel feedback);

  /// Get all saved feedback
  Future<List<ChatFeedbackModel>> getAllFeedback();

  /// Get feedback for specific question
  Future<List<ChatFeedbackModel>> getFeedbackForQuestion(String questionId);

  /// Clear all cached data
  Future<void> clearCache();

  /// Get last cache update time
  Future<DateTime?> getLastCacheTime();
}

/// Implementation of ChatbotLocalDataSource
class ChatbotLocalDataSourceImpl implements ChatbotLocalDataSource {
  ChatbotLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  static const String _cachedDataKey = 'CACHED_CHATBOT_DATA';
  static const String _feedbackKey = 'CHATBOT_FEEDBACK';
  static const String _lastCacheTimeKey = 'LAST_CACHE_TIME';
  static const String _assetsPath = 'assets/data/chatbot_data.json';

  @override
  Future<ChatbotDataModel> loadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString(_assetsPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return ChatbotDataModel.fromJson(jsonData);
    } catch (e) {
      throw CacheException(message: 'Failed to load chatbot data from assets');
    }
  }

  @override
  Future<ChatbotDataModel?> getCachedData() async {
    try {
      final String? cachedString = sharedPreferences.getString(_cachedDataKey);
      if (cachedString != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedString);
        return ChatbotDataModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached chatbot data');
    }
  }

  @override
  Future<void> cacheData(ChatbotDataModel data) async {
    try {
      final String jsonString = json.encode(data.toJson());
      await sharedPreferences.setString(_cachedDataKey, jsonString);
      await sharedPreferences.setString(
        _lastCacheTimeKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache chatbot data');
    }
  }

  @override
  Future<void> saveFeedback(ChatFeedbackModel feedback) async {
    try {
      final List<ChatFeedbackModel> existingFeedback = await getAllFeedback();
      existingFeedback.add(feedback);

      final List<Map<String, dynamic>> feedbackJsonList =
          existingFeedback.map((f) => f.toJson()).toList();

      final String jsonString = json.encode(feedbackJsonList);
      await sharedPreferences.setString(_feedbackKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to save feedback');
    }
  }

  @override
  Future<List<ChatFeedbackModel>> getAllFeedback() async {
    try {
      final String? feedbackString = sharedPreferences.getString(_feedbackKey);
      if (feedbackString != null) {
        final List<dynamic> feedbackList = json.decode(feedbackString);
        return feedbackList
            .map((f) => ChatFeedbackModel.fromJson(f as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException(message: 'Failed to get feedback');
    }
  }

  @override
  Future<List<ChatFeedbackModel>> getFeedbackForQuestion(
      String questionId) async {
    try {
      final List<ChatFeedbackModel> allFeedback = await getAllFeedback();
      return allFeedback.where((f) => f.questionId == questionId).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get feedback for question');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedDataKey);
      await sharedPreferences.remove(_lastCacheTimeKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    try {
      final String? timeString = sharedPreferences.getString(_lastCacheTimeKey);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
