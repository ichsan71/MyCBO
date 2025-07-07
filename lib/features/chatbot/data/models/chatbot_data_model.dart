import 'chat_category_model.dart';
import 'chat_question_model.dart';

/// Data model for complete chatbot data structure
class ChatbotDataModel {
  const ChatbotDataModel({
    required this.categories,
    required this.questions,
    this.version = '1.0.0',
    this.lastUpdated,
  });

  /// List of chat categories
  final List<ChatCategoryModel> categories;

  /// List of chat questions
  final List<ChatQuestionModel> questions;

  /// Data version for tracking updates
  final String version;

  /// Last updated timestamp
  final DateTime? lastUpdated;

  /// Create ChatbotDataModel from JSON
  factory ChatbotDataModel.fromJson(Map<String, dynamic> json) {
    return ChatbotDataModel(
      categories: (json['categories'] as List<dynamic>?)
              ?.map(
                  (e) => ChatCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map(
                  (e) => ChatQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Convert ChatbotDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((e) => e.toJson()).toList(),
      'questions': questions.map((e) => e.toJson()).toList(),
      'version': version,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ChatbotDataModel copyWith({
    List<ChatCategoryModel>? categories,
    List<ChatQuestionModel>? questions,
    String? version,
    DateTime? lastUpdated,
  }) {
    return ChatbotDataModel(
      categories: categories ?? this.categories,
      questions: questions ?? this.questions,
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get questions for a specific category
  List<ChatQuestionModel> getQuestionsByCategory(String categoryId) {
    return questions
        .where((q) => q.categoryId == categoryId && q.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Get active categories sorted by order
  List<ChatCategoryModel> getActiveCategories() {
    return categories.where((c) => c.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
