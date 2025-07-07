import '../../domain/entities/chat_question.dart';

/// Data model for ChatQuestion with JSON serialization
class ChatQuestionModel extends ChatQuestion {
  const ChatQuestionModel({
    required super.id,
    required super.categoryId,
    required super.question,
    required super.answer,
    required super.order,
    super.isActive = true,
    super.keywords = const [],
    super.relatedQuestionIds = const [],
  });

  /// Create ChatQuestionModel from JSON
  factory ChatQuestionModel.fromJson(Map<String, dynamic> json) {
    return ChatQuestionModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      order: json['order'] as int,
      isActive: json['isActive'] as bool? ?? true,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      relatedQuestionIds: (json['relatedQuestionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convert ChatQuestionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'question': question,
      'answer': answer,
      'order': order,
      'isActive': isActive,
      'keywords': keywords,
      'relatedQuestionIds': relatedQuestionIds,
    };
  }

  /// Create ChatQuestionModel from ChatQuestion entity
  factory ChatQuestionModel.fromEntity(ChatQuestion question) {
    return ChatQuestionModel(
      id: question.id,
      categoryId: question.categoryId,
      question: question.question,
      answer: question.answer,
      order: question.order,
      isActive: question.isActive,
      keywords: question.keywords,
      relatedQuestionIds: question.relatedQuestionIds,
    );
  }

  /// Convert to ChatQuestion entity
  ChatQuestion toEntity() {
    return ChatQuestion(
      id: id,
      categoryId: categoryId,
      question: question,
      answer: answer,
      order: order,
      isActive: isActive,
      keywords: keywords,
      relatedQuestionIds: relatedQuestionIds,
    );
  }

  /// Create a copy with updated fields
  @override
  ChatQuestionModel copyWith({
    String? id,
    String? categoryId,
    String? question,
    String? answer,
    int? order,
    bool? isActive,
    List<String>? keywords,
    List<String>? relatedQuestionIds,
  }) {
    return ChatQuestionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      keywords: keywords ?? this.keywords,
      relatedQuestionIds: relatedQuestionIds ?? this.relatedQuestionIds,
    );
  }
}
