import 'package:get_it/get_it.dart';
import 'package:test_cbo/features/ranking_achievement/data/datasources/ranking_achievement_remote_data_source.dart';
import 'package:test_cbo/features/ranking_achievement/data/repositories/ranking_achievement_repository_impl.dart';
import 'package:test_cbo/features/ranking_achievement/domain/repositories/ranking_achievement_repository.dart';
import 'package:test_cbo/features/ranking_achievement/domain/usecases/get_ranking_achievement.dart';
import 'package:test_cbo/features/ranking_achievement/presentation/bloc/ranking_achievement_bloc.dart';

Future<void> initRankingAchievementDependencies(GetIt sl) async {
  // Bloc
  sl.registerFactory(() => RankingAchievementBloc(getRankingAchievement: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetRankingAchievement(sl()));

  // Repository
  sl.registerLazySingleton<RankingAchievementRepository>(
    () => RankingAchievementRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RankingAchievementRemoteDataSource>(
    () => RankingAchievementRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );
}
