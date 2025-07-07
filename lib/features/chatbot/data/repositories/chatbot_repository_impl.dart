import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/chat_category.dart';
import '../../domain/entities/chat_question.dart';
import '../../domain/entities/chat_feedback.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_local_data_source.dart';
import '../datasources/chatbot_remote_data_source.dart';
import '../models/chat_feedback_model.dart';

/// Implementation of ChatbotRepository
class ChatbotRepositoryImpl implements ChatbotRepository {
  const ChatbotRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ChatbotLocalDataSource localDataSource;
  final ChatbotRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<ChatCategory>>> getCategories() async {
    try {
      // First try to get data from local cache
      final cachedData = await localDataSource.getCachedData();

      if (cachedData != null) {
        final categories = cachedData
            .getActiveCategories()
            .map((model) => model.toEntity())
            .toList();
        return Right(categories);
      }

      // If no cached data, try to load from assets
      final assetData = await localDataSource.loadFromAssets();
      final categories = assetData
          .getActiveCategories()
          .map((model) => model.toEntity())
          .toList();

      // Cache the asset data for future use
      await localDataSource.cacheData(assetData);

      return Right(categories);
    } on CacheException {
      return const Left(CacheFailure(message: 'Failed to get categories'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ChatQuestion>>> getQuestionsByCategory(
    String categoryId,
  ) async {
    try {
      // First try to get data from local cache
      final cachedData = await localDataSource.getCachedData();

      if (cachedData != null) {
        final questions = cachedData
            .getQuestionsByCategory(categoryId)
            .map((model) => model.toEntity())
            .toList();
        return Right(questions);
      }

      // If no cached data, try to load from assets
      final assetData = await localDataSource.loadFromAssets();
      final questions = assetData
          .getQuestionsByCategory(categoryId)
          .map((model) => model.toEntity())
          .toList();

      // Cache the asset data for future use
      await localDataSource.cacheData(assetData);

      return Right(questions);
    } on CacheException {
      return const Left(CacheFailure(message: 'Failed to get questions'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ChatQuestion>> getQuestionById(
      String questionId) async {
    try {
      // First try to get data from local cache
      final cachedData = await localDataSource.getCachedData();

      if (cachedData != null) {
        final questionModel = cachedData.questions
            .where((q) => q.id == questionId && q.isActive)
            .firstOrNull;

        if (questionModel != null) {
          return Right(questionModel.toEntity());
        }
      }

      // If not found in cache, try to load from assets
      final assetData = await localDataSource.loadFromAssets();
      final questionModel = assetData.questions
          .where((q) => q.id == questionId && q.isActive)
          .firstOrNull;

      if (questionModel != null) {
        // Cache the asset data for future use
        await localDataSource.cacheData(assetData);
        return Right(questionModel.toEntity());
      }

      return const Left(CacheFailure(message: 'Question not found'));
    } on CacheException {
      return const Left(CacheFailure(message: 'Failed to get question'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ChatQuestion>>> getAllQuestions() async {
    try {
      // First try to get data from local cache
      final cachedData = await localDataSource.getCachedData();

      if (cachedData != null) {
        final questions = cachedData.questions
            .where((q) => q.isActive)
            .map((model) => model.toEntity())
            .toList();
        return Right(questions);
      }

      // If no cached data, try to load from assets
      final assetData = await localDataSource.loadFromAssets();
      final questions = assetData.questions
          .where((q) => q.isActive)
          .map((model) => model.toEntity())
          .toList();

      // Cache the asset data for future use
      await localDataSource.cacheData(assetData);

      return Right(questions);
    } on CacheException {
      return const Left(CacheFailure(message: 'Failed to get all questions'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> submitFeedback(ChatFeedback feedback) async {
    try {
      final feedbackModel = ChatFeedbackModel.fromEntity(feedback);

      // Always save feedback locally first
      await localDataSource.saveFeedback(feedbackModel);

      // Try to submit to remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.submitFeedback(feedbackModel);
        } catch (e) {
          // If remote submission fails, still return success since local save worked
          // The feedback will be synced later when connection is available
        }
      }

      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure(message: 'Failed to save feedback'));
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getFeedbackStats(
    String questionId,
  ) async {
    try {
      // Try to get stats from remote first
      if (await networkInfo.isConnected) {
        try {
          final remoteStats =
              await remoteDataSource.getFeedbackStats(questionId);
          return Right(remoteStats);
        } on ServerException {
          // Fall back to local stats if remote fails
        } on NetworkException {
          // Fall back to local stats if network issue
        }
      }

      // Get stats from local feedback
      final localFeedback =
          await localDataSource.getFeedbackForQuestion(questionId);
      final stats = <String, int>{
        'helpful': 0,
        'notHelpful': 0,
      };

      for (final feedback in localFeedback) {
        if (feedback.feedbackType.name == 'helpful') {
          stats['helpful'] = (stats['helpful'] ?? 0) + 1;
        } else {
          stats['notHelpful'] = (stats['notHelpful'] ?? 0) + 1;
        }
      }

      return Right(stats);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get feedback stats'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshData() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote
          final remoteData = await remoteDataSource.fetchChatbotData();

          // Update local cache with fresh data
          await localDataSource.cacheData(remoteData);

          return const Right(null);
        } on ServerException {
          return const Left(
              ServerFailure(message: 'Failed to refresh data from server'));
        } on NetworkException {
          return const Left(
              NetworkFailure(message: 'Network error while refreshing data'));
        } on AuthenticationException {
          return const Left(
              AuthenticationFailure(message: 'Authentication failed'));
        } on UnauthorizedException {
          return const Left(AuthenticationFailure(message: 'Access denied'));
        }
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<bool> hasLocalData() async {
    try {
      final cachedData = await localDataSource.getCachedData();
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> getLastUpdateTime() async {
    try {
      return await localDataSource.getLastCacheTime();
    } catch (e) {
      return null;
    }
  }
}
