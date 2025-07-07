import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_category.dart';
import '../../domain/entities/chat_question.dart';
import '../../domain/entities/chat_message.dart';

/// Base class for all chatbot states
abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object?> get props => [];
}

/// Initial state when chatbot is first loaded
class ChatbotInitial extends ChatbotState {
  const ChatbotInitial();
}

/// State when chatbot is loading data
class ChatbotLoading extends ChatbotState {
  const ChatbotLoading();
}

/// State when chatbot categories are loaded and displayed
class ChatbotCategoriesLoaded extends ChatbotState {
  final List<ChatCategory> categories;
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatbotCategoriesLoaded({
    required this.categories,
    required this.messages,
    this.isTyping = false,
  });

  @override
  List<Object?> get props => [categories, messages, isTyping];

  ChatbotCategoriesLoaded copyWith({
    List<ChatCategory>? categories,
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatbotCategoriesLoaded(
      categories: categories ?? this.categories,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

/// State when questions for a category are loaded and displayed
class ChatbotQuestionsLoaded extends ChatbotState {
  final String categoryId;
  final List<ChatQuestion> questions;
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatbotQuestionsLoaded({
    required this.categoryId,
    required this.questions,
    required this.messages,
    this.isTyping = false,
  });

  @override
  List<Object?> get props => [categoryId, questions, messages, isTyping];

  ChatbotQuestionsLoaded copyWith({
    String? categoryId,
    List<ChatQuestion>? questions,
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatbotQuestionsLoaded(
      categoryId: categoryId ?? this.categoryId,
      questions: questions ?? this.questions,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

/// State when a question is answered and conversation is displayed
class ChatbotConversation extends ChatbotState {
  final List<ChatMessage> messages;
  final ChatQuestion? currentQuestion;
  final bool isTyping;
  final bool feedbackSubmitted;

  const ChatbotConversation({
    required this.messages,
    this.currentQuestion,
    this.isTyping = false,
    this.feedbackSubmitted = false,
  });

  @override
  List<Object?> get props =>
      [messages, currentQuestion, isTyping, feedbackSubmitted];

  ChatbotConversation copyWith({
    List<ChatMessage>? messages,
    ChatQuestion? currentQuestion,
    bool? isTyping,
    bool? feedbackSubmitted,
  }) {
    return ChatbotConversation(
      messages: messages ?? this.messages,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isTyping: isTyping ?? this.isTyping,
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
    );
  }
}

/// State when feedback is successfully submitted
class ChatbotFeedbackSubmitted extends ChatbotState {
  final List<ChatMessage> messages;
  final ChatQuestion currentQuestion;

  const ChatbotFeedbackSubmitted({
    required this.messages,
    required this.currentQuestion,
  });

  @override
  List<Object?> get props => [messages, currentQuestion];
}

/// State when data is being refreshed
class ChatbotRefreshing extends ChatbotState {
  final List<ChatMessage> messages;

  const ChatbotRefreshing({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// State when an error occurs
class ChatbotError extends ChatbotState {
  final String message;
  final List<ChatMessage> chatMessages;

  const ChatbotError({
    required this.message,
    this.chatMessages = const [],
  });

  @override
  List<Object?> get props => [message, chatMessages];
}
