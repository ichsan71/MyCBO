import 'package:get_it/get_it.dart';
import 'package:test_cbo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:test_cbo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:test_cbo/features/auth/domain/repositories/auth_repository.dart';
import 'package:test_cbo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:test_cbo/features/auth/domain/usecases/login_usecase.dart';
import 'package:test_cbo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/privacy_policy_bloc.dart';

/// Inisialisasi dependency injection untuk fitur authentication
///
/// Fungsi ini mendaftarkan semua dependency yang dibutuhkan untuk fitur auth:
/// - BLoC: Mengelola state autentikasi
/// - Use Cases: Fungsi bisnis seperti login, logout, dan cek status auth
/// - Repository: Abstraksi untuk akses data
/// - Data Sources: Implementasi akses data dari remote API
void injectAuth(GetIt sl) {
  // Bloc
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));
  sl.registerFactory(() => PrivacyPolicyBloc());

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );
}
