import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_feedback.dart';

/// Base class for all chatbot events
abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load chatbot categories for specific user role
class LoadCategoriesEvent extends ChatbotEvent {
  final String userRole;

  const LoadCategoriesEvent({required this.userRole});

  @override
  List<Object?> get props => [userRole];
}

/// Event to load questions for a specific category
class LoadQuestionsByCategoryEvent extends ChatbotEvent {
  final String categoryId;

  const LoadQuestionsByCategoryEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

/// Event to select a question and show its answer
class SelectQuestionEvent extends ChatbotEvent {
  final String questionId;

  const SelectQuestionEvent({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

/// Event to submit feedback for a question
class SubmitFeedbackEvent extends ChatbotEvent {
  final ChatFeedback feedback;

  const SubmitFeedbackEvent({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

/// Event to refresh chatbot data from remote source
class RefreshDataEvent extends ChatbotEvent {
  const RefreshDataEvent();
}

/// Event to start a new conversation (clear current messages)
class StartNewConversationEvent extends ChatbotEvent {
  final String userRole;

  const StartNewConversationEvent({required this.userRole});

  @override
  List<Object?> get props => [userRole];
}

/// Event to go back to categories from questions
class BackToCategoriesEvent extends ChatbotEvent {
  final String userRole;

  const BackToCategoriesEvent({required this.userRole});

  @override
  List<Object?> get props => [userRole];
}

/// Event to show typing indicator
class ShowTypingEvent extends ChatbotEvent {
  const ShowTypingEvent();
}

/// Event to hide typing indicator
class HideTypingEvent extends ChatbotEvent {
  const HideTypingEvent();
}
