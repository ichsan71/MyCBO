import 'package:get_it/get_it.dart';
import '../data/datasources/chatbot_local_data_source.dart';
import '../data/datasources/chatbot_remote_data_source.dart';
import '../data/repositories/chatbot_repository_impl.dart';
import '../domain/repositories/chatbot_repository.dart';
import '../domain/usecases/get_chat_categories.dart';
import '../domain/usecases/get_questions_by_category.dart';
import '../domain/usecases/get_question_by_id.dart';
import '../domain/usecases/submit_feedback.dart';
import '../domain/usecases/refresh_chatbot_data.dart';
import '../presentation/bloc/chatbot_bloc.dart';

/// Initialize all chatbot feature dependencies
Future<void> initChatbotDependencies(GetIt sl) async {
  // BLoC
  sl.registerFactory(
    () => ChatbotBloc(
      getChatCategories: sl(),
      getQuestionsByCategory: sl(),
      getQuestionById: sl(),
      submitFeedback: sl(),
      refreshChatbotData: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetChatCategories(sl()));
  sl.registerLazySingleton(() => GetQuestionsByCategory(sl()));
  sl.registerLazySingleton(() => GetQuestionById(sl()));
  sl.registerLazySingleton(() => SubmitFeedback(sl()));
  sl.registerLazySingleton(() => RefreshChatbotData(sl()));

  // Repository
  sl.registerLazySingleton<ChatbotRepository>(
    () => ChatbotRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ChatbotLocalDataSource>(
    () => ChatbotLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<ChatbotRemoteDataSource>(
    () => ChatbotRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );
}
