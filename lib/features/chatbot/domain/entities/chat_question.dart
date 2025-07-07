import 'package:equatable/equatable.dart';

/// Entity representing a predefined chatbot question and its answer
class ChatQuestion extends Equatable {
  const ChatQuestion({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
    required this.order,
    this.isActive = true,
    this.keywords = const [],
    this.relatedQuestionIds = const [],
  });

  /// Unique identifier for the question
  final String id;

  /// ID of the category this question belongs to
  final String categoryId;

  /// The question text that users can select
  final String question;

  /// The answer that the bot will provide
  final String answer;

  /// Order for displaying questions within category (lower numbers appear first)
  final int order;

  /// Whether this question is currently active/visible
  final bool isActive;

  /// Keywords for search functionality (future enhancement)
  final List<String> keywords;

  /// IDs of related questions that might be suggested
  final List<String> relatedQuestionIds;

  /// Creates a copy of this question with updated fields
  ChatQuestion copyWith({
    String? id,
    String? categoryId,
    String? question,
    String? answer,
    int? order,
    bool? isActive,
    List<String>? keywords,
    List<String>? relatedQuestionIds,
  }) {
    return ChatQuestion(
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

  @override
  List<Object?> get props => [
        id,
        categoryId,
        question,
        answer,
        order,
        isActive,
        keywords,
        relatedQuestionIds,
      ];
}
