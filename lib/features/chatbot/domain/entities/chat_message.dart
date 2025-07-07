import 'package:equatable/equatable.dart';

enum MessageType { user, bot }

enum MessageStatus { sending, sent, failed }

/// Entity representing a chat message in the chatbot conversation
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.questionId,
  });

  /// Unique identifier for the message
  final String id;

  /// Content/text of the message
  final String content;

  /// Type of message (user or bot)
  final MessageType type;

  /// Timestamp when message was created
  final DateTime timestamp;

  /// Status of the message (for user messages)
  final MessageStatus status;

  /// Associated question ID (for tracking which question was asked)
  final String? questionId;

  /// Creates a user message
  factory ChatMessage.user({
    required String id,
    required String content,
    required DateTime timestamp,
    String? questionId,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      type: MessageType.user,
      timestamp: timestamp,
      status: status,
      questionId: questionId,
    );
  }

  /// Creates a bot message
  factory ChatMessage.bot({
    required String id,
    required String content,
    required DateTime timestamp,
    String? questionId,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      type: MessageType.bot,
      timestamp: timestamp,
      status: MessageStatus.sent,
      questionId: questionId,
    );
  }

  /// Creates a copy of this message with updated fields
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? questionId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      questionId: questionId ?? this.questionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        timestamp,
        status,
        questionId,
      ];
}
