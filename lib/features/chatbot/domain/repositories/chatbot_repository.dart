import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_category.dart';
import '../entities/chat_question.dart';
import '../entities/chat_feedback.dart';

/// Repository interface for chatbot operations
abstract class ChatbotRepository {
  /// Get all active chat categories
  /// Returns a list of categories ordered by their order field
  Future<Either<Failure, List<ChatCategory>>> getCategories();

  /// Get all active questions for a specific category
  /// Returns a list of questions ordered by their order field
  Future<Either<Failure, List<ChatQuestion>>> getQuestionsByCategory(
    String categoryId,
  );

  /// Get a specific question by its ID
  Future<Either<Failure, ChatQuestion>> getQuestionById(String questionId);

  /// Get all active questions (for search functionality)
  Future<Either<Failure, List<ChatQuestion>>> getAllQuestions();

  /// Submit user feedback for a question
  Future<Either<Failure, void>> submitFeedback(ChatFeedback feedback);

  /// Get feedback statistics for a question (optional for analytics)
  Future<Either<Failure, Map<String, int>>> getFeedbackStats(
    String questionId,
  );

  /// Refresh chatbot data from remote source
  /// This will update local cache with latest data from API
  Future<Either<Failure, void>> refreshData();

  /// Check if data is available locally
  Future<bool> hasLocalData();

  /// Get last data update timestamp
  Future<DateTime?> getLastUpdateTime();
}
