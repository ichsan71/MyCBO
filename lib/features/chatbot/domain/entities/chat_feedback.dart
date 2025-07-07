import 'package:equatable/equatable.dart';

enum FeedbackType { helpful, notHelpful }

/// Entity representing user feedback on a chatbot answer
class ChatFeedback extends Equatable {
  const ChatFeedback({
    required this.id,
    required this.questionId,
    required this.feedbackType,
    required this.timestamp,
    this.comment,
    this.userId,
  });

  /// Unique identifier for the feedback
  final String id;

  /// ID of the question this feedback is for
  final String questionId;

  /// Type of feedback (helpful or not helpful)
  final FeedbackType feedbackType;

  /// Timestamp when feedback was given
  final DateTime timestamp;

  /// Optional comment from the user
  final String? comment;

  /// ID of the user who gave feedback (optional for analytics)
  final String? userId;

  /// Creates a helpful feedback
  factory ChatFeedback.helpful({
    required String id,
    required String questionId,
    required DateTime timestamp,
    String? comment,
    String? userId,
  }) {
    return ChatFeedback(
      id: id,
      questionId: questionId,
      feedbackType: FeedbackType.helpful,
      timestamp: timestamp,
      comment: comment,
      userId: userId,
    );
  }

  /// Creates a not helpful feedback
  factory ChatFeedback.notHelpful({
    required String id,
    required String questionId,
    required DateTime timestamp,
    String? comment,
    String? userId,
  }) {
    return ChatFeedback(
      id: id,
      questionId: questionId,
      feedbackType: FeedbackType.notHelpful,
      timestamp: timestamp,
      comment: comment,
      userId: userId,
    );
  }

  /// Creates a copy of this feedback with updated fields
  ChatFeedback copyWith({
    String? id,
    String? questionId,
    FeedbackType? feedbackType,
    DateTime? timestamp,
    String? comment,
    String? userId,
  }) {
    return ChatFeedback(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      feedbackType: feedbackType ?? this.feedbackType,
      timestamp: timestamp ?? this.timestamp,
      comment: comment ?? this.comment,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questionId,
        feedbackType,
        timestamp,
        comment,
        userId,
      ];
}
