import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chat_categories.dart';
import '../../domain/usecases/get_questions_by_category.dart';
import '../../domain/usecases/get_question_by_id.dart';
import '../../domain/usecases/submit_feedback.dart';
import '../../domain/usecases/refresh_chatbot_data.dart';
import 'chatbot_event.dart';
import 'chatbot_state.dart';

/// BLoC for managing chatbot state and business logic
class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final GetChatCategories getChatCategories;
  final GetQuestionsByCategory getQuestionsByCategory;
  final GetQuestionById getQuestionById;
  final SubmitFeedback submitFeedback;
  final RefreshChatbotData refreshChatbotData;

  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  ChatbotBloc({
    required this.getChatCategories,
    required this.getQuestionsByCategory,
    required this.getQuestionById,
    required this.submitFeedback,
    required this.refreshChatbotData,
  }) : super(const ChatbotInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategoriesEvent);
    on<LoadQuestionsByCategoryEvent>(_onLoadQuestionsByCategoryEvent);
    on<SelectQuestionEvent>(_onSelectQuestionEvent);
    on<SubmitFeedbackEvent>(_onSubmitFeedbackEvent);
    on<RefreshDataEvent>(_onRefreshDataEvent);
    on<StartNewConversationEvent>(_onStartNewConversationEvent);
    on<BackToCategoriesEvent>(_onBackToCategoriesEvent);
    on<ShowTypingEvent>(_onShowTypingEvent);
    on<HideTypingEvent>(_onHideTypingEvent);
  }

  /// Handle loading categories event
  Future<void> _onLoadCategoriesEvent(
    LoadCategoriesEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Loading chatbot categories for role: ${event.userRole}');
    emit(const ChatbotLoading());

    final result = await getChatCategories(
      GetChatCategoriesParams(userRole: event.userRole),
    );

    await result.fold(
      (failure) async {
        logger.e('🤖 Failed to load categories: ${failure.message}');
        emit(ChatbotError(
          message: failure.message,
          chatMessages: _getWelcomeMessages(),
        ));
      },
      (categories) async {
        logger.i(
            '🤖 Categories loaded successfully: ${categories.length} categories for role ${event.userRole}');

        final welcomeMessages = _getWelcomeMessages();
        final categoryMessage = _createCategorySelectionMessage();

        emit(ChatbotCategoriesLoaded(
          categories: categories,
          messages: [...welcomeMessages, categoryMessage],
        ));
      },
    );
  }

  /// Handle loading questions for a category
  Future<void> _onLoadQuestionsByCategoryEvent(
    LoadQuestionsByCategoryEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Loading questions for category: ${event.categoryId}');

    // Show typing indicator
    if (state is ChatbotCategoriesLoaded) {
      final currentState = state as ChatbotCategoriesLoaded;
      emit(currentState.copyWith(isTyping: true));
    }

    // Add user message for category selection
    final userMessage = ChatMessage.user(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: _getCategoryDisplayName(event.categoryId),
      timestamp: DateTime.now(),
    );

    final currentMessages = _getCurrentMessages();
    final updatedMessages = [...currentMessages, userMessage];

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final result = await getQuestionsByCategory(
      GetQuestionsByCategoryParams(categoryId: event.categoryId),
    );

    await result.fold(
      (failure) async {
        logger.e('🤖 Failed to load questions: ${failure.message}');
        emit(ChatbotError(
          message: failure.message,
          chatMessages: updatedMessages,
        ));
      },
      (questions) async {
        logger.i(
            '🤖 Questions loaded successfully: ${questions.length} questions');

        final botMessage = _createQuestionSelectionMessage();
        final finalMessages = [...updatedMessages, botMessage];

        emit(ChatbotQuestionsLoaded(
          categoryId: event.categoryId,
          questions: questions,
          messages: finalMessages,
          isTyping: false,
        ));
      },
    );
  }

  /// Handle selecting a question and showing its answer
  Future<void> _onSelectQuestionEvent(
    SelectQuestionEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Question selected: ${event.questionId}');

    // Show typing indicator
    if (state is ChatbotQuestionsLoaded) {
      final currentState = state as ChatbotQuestionsLoaded;
      emit(currentState.copyWith(isTyping: true));
    }

    final result = await getQuestionById(
      GetQuestionByIdParams(questionId: event.questionId),
    );

    await result.fold(
      (failure) async {
        logger.e('🤖 Failed to get question: ${failure.message}');
        emit(ChatbotError(
          message: failure.message,
          chatMessages: _getCurrentMessages(),
        ));
      },
      (question) async {
        logger.i('🤖 Question retrieved: ${question.question}');

        // Add user message for question selection
        final userMessage = ChatMessage.user(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          content: question.question,
          timestamp: DateTime.now(),
          questionId: event.questionId,
        );

        final currentMessages = _getCurrentMessages();
        final updatedMessages = [...currentMessages, userMessage];

        // Simulate typing delay
        await Future.delayed(const Duration(milliseconds: 2000));

        // Add bot response
        final botMessage = ChatMessage.bot(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          content: question.answer,
          timestamp: DateTime.now(),
          questionId: event.questionId,
        );

        final finalMessages = [...updatedMessages, botMessage];

        emit(ChatbotConversation(
          messages: finalMessages,
          currentQuestion: question,
          isTyping: false,
          feedbackSubmitted: false,
        ));
      },
    );
  }

  /// Handle feedback submission
  Future<void> _onSubmitFeedbackEvent(
    SubmitFeedbackEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Submitting feedback: ${event.feedback.feedbackType}');

    final result = await submitFeedback(
      SubmitFeedbackParams(feedback: event.feedback),
    );

    await result.fold(
      (failure) async {
        logger.e('🤖 Failed to submit feedback: ${failure.message}');
        // Don't show error for feedback submission, just log it
      },
      (_) async {
        logger.i('🤖 Feedback submitted successfully');

        if (state is ChatbotConversation) {
          final currentState = state as ChatbotConversation;
          emit(currentState.copyWith(feedbackSubmitted: true));
        }
      },
    );
  }

  /// Handle refresh data event
  Future<void> _onRefreshDataEvent(
    RefreshDataEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Refreshing chatbot data...');

    final currentMessages = _getCurrentMessages();
    emit(ChatbotRefreshing(messages: currentMessages));

    final result = await refreshChatbotData(NoParams());

    await result.fold(
      (failure) async {
        logger.e('🤖 Failed to refresh data: ${failure.message}');
        emit(ChatbotError(
          message: 'Failed to refresh data: ${failure.message}',
          chatMessages: currentMessages,
        ));
      },
      (_) async {
        logger.i('🤖 Data refreshed successfully');
        // Don't auto-reload categories after refresh, let user manually navigate
      },
    );
  }

  /// Handle starting a new conversation
  Future<void> _onStartNewConversationEvent(
    StartNewConversationEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Starting new conversation for role: ${event.userRole}');
    add(LoadCategoriesEvent(userRole: event.userRole));
  }

  /// Handle going back to categories
  Future<void> _onBackToCategoriesEvent(
    BackToCategoriesEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    logger.i('🤖 Going back to categories for role: ${event.userRole}');
    add(LoadCategoriesEvent(userRole: event.userRole));
  }

  /// Handle showing typing indicator
  Future<void> _onShowTypingEvent(
    ShowTypingEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    if (state is ChatbotCategoriesLoaded) {
      final currentState = state as ChatbotCategoriesLoaded;
      emit(currentState.copyWith(isTyping: true));
    } else if (state is ChatbotQuestionsLoaded) {
      final currentState = state as ChatbotQuestionsLoaded;
      emit(currentState.copyWith(isTyping: true));
    } else if (state is ChatbotConversation) {
      final currentState = state as ChatbotConversation;
      emit(currentState.copyWith(isTyping: true));
    }
  }

  /// Handle hiding typing indicator
  Future<void> _onHideTypingEvent(
    HideTypingEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    if (state is ChatbotCategoriesLoaded) {
      final currentState = state as ChatbotCategoriesLoaded;
      emit(currentState.copyWith(isTyping: false));
    } else if (state is ChatbotQuestionsLoaded) {
      final currentState = state as ChatbotQuestionsLoaded;
      emit(currentState.copyWith(isTyping: false));
    } else if (state is ChatbotConversation) {
      final currentState = state as ChatbotConversation;
      emit(currentState.copyWith(isTyping: false));
    }
  }

  /// Get current messages from state
  List<ChatMessage> _getCurrentMessages() {
    if (state is ChatbotCategoriesLoaded) {
      return (state as ChatbotCategoriesLoaded).messages;
    } else if (state is ChatbotQuestionsLoaded) {
      return (state as ChatbotQuestionsLoaded).messages;
    } else if (state is ChatbotConversation) {
      return (state as ChatbotConversation).messages;
    } else if (state is ChatbotError) {
      return (state as ChatbotError).chatMessages;
    }
    return [];
  }

  /// Create welcome messages
  List<ChatMessage> _getWelcomeMessages() {
    return [
      ChatMessage.bot(
        id: 'welcome_1',
        content: 'Halo! 👋 Saya Mazbot, asisten virtual Anda.',
        timestamp: DateTime.now(),
      ),
      ChatMessage.bot(
        id: 'welcome_2',
        content:
            'Saya siap membantu Anda memahami fitur-fitur aplikasi. Pilih kategori pertanyaan di bawah ini:',
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Create category selection message
  ChatMessage _createCategorySelectionMessage() {
    return ChatMessage.bot(
      id: 'category_selection',
      content: 'Pilih kategori yang ingin Anda tanyakan:',
      timestamp: DateTime.now(),
    );
  }

  /// Create question selection message
  ChatMessage _createQuestionSelectionMessage() {
    return ChatMessage.bot(
      id: 'question_selection',
      content: 'Berikut adalah pertanyaan yang tersedia. Pilih salah satu:',
      timestamp: DateTime.now(),
    );
  }

  /// Get display name for category (you might want to customize this)
  String _getCategoryDisplayName(String categoryId) {
    // This is a placeholder - you might want to implement a proper mapping
    switch (categoryId) {
      case 'schedule':
        return 'Jadwal';
      case 'kpi':
        return 'KPI';
      case 'approval':
        return 'Approval';
      case 'realisasi':
        return 'Realisasi Visit';
      default:
        return categoryId;
    }
  }
}
