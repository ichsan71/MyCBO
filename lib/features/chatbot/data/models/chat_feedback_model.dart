import '../../domain/entities/chat_feedback.dart';

/// Data model for ChatFeedback with JSON serialization
class ChatFeedbackModel extends ChatFeedback {
  const ChatFeedbackModel({
    required super.id,
    required super.questionId,
    required super.feedbackType,
    required super.timestamp,
    super.comment,
    super.userId,
  });

  /// Create ChatFeedbackModel from JSON
  factory ChatFeedbackModel.fromJson(Map<String, dynamic> json) {
    return ChatFeedbackModel(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      feedbackType: FeedbackType.values.firstWhere(
        (e) => e.name == json['feedbackType'],
        orElse: () => FeedbackType.notHelpful,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      comment: json['comment'] as String?,
      userId: json['userId'] as String?,
    );
  }

  /// Convert ChatFeedbackModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'feedbackType': feedbackType.name,
      'timestamp': timestamp.toIso8601String(),
      'comment': comment,
      'userId': userId,
    };
  }

  /// Create ChatFeedbackModel from ChatFeedback entity
  factory ChatFeedbackModel.fromEntity(ChatFeedback feedback) {
    return ChatFeedbackModel(
      id: feedback.id,
      questionId: feedback.questionId,
      feedbackType: feedback.feedbackType,
      timestamp: feedback.timestamp,
      comment: feedback.comment,
      userId: feedback.userId,
    );
  }

  /// Convert to ChatFeedback entity
  ChatFeedback toEntity() {
    return ChatFeedback(
      id: id,
      questionId: questionId,
      feedbackType: feedbackType,
      timestamp: timestamp,
      comment: comment,
      userId: userId,
    );
  }

  /// Create a copy with updated fields
  @override
  ChatFeedbackModel copyWith({
    String? id,
    String? questionId,
    FeedbackType? feedbackType,
    DateTime? timestamp,
    String? comment,
    String? userId,
  }) {
    return ChatFeedbackModel(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      feedbackType: feedbackType ?? this.feedbackType,
      timestamp: timestamp ?? this.timestamp,
      comment: comment ?? this.comment,
      userId: userId ?? this.userId,
    );
  }
}
