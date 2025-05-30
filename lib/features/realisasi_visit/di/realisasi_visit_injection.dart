import 'package:test_cbo/core/di/injection_container.dart';
import 'package:test_cbo/features/realisasi_visit/data/datasources/realisasi_visit_remote_data_source.dart';
import 'package:test_cbo/features/realisasi_visit/data/repositories/realisasi_visit_repository_impl.dart';
import 'package:test_cbo/features/realisasi_visit/domain/repositories/realisasi_visit_repository.dart';
import 'package:test_cbo/features/realisasi_visit/domain/usecases/approve_realisasi_visit_gm_usecase.dart';
import 'package:test_cbo/features/realisasi_visit/domain/usecases/approve_realisasi_visit_usecase.dart';
import 'package:test_cbo/features/realisasi_visit/domain/usecases/get_realisasi_visits_gm_usecase.dart';
import 'package:test_cbo/features/realisasi_visit/domain/usecases/get_realisasi_visits_usecase.dart';
import 'package:test_cbo/features/realisasi_visit/domain/usecases/reject_realisasi_visit_usecase.dart';
import 'package:test_cbo/features/realisasi_visit/presentation/bloc/realisasi_visit_bloc.dart';
import 'package:http/http.dart' as http;

/// Inisialisasi dependency injection untuk fitur realisasi visit
///
/// Fungsi ini mendaftarkan semua dependency yang dibutuhkan untuk fitur realisasi visit:
/// - BLoC: Mengelola state realisasi visit
/// - Use Cases: Fungsi bisnis seperti mendapatkan daftar realisasi visit, menyetujui, menolak, dll
/// - Repository: Abstraksi untuk akses data
/// - Data Sources: Implementasi akses data dari remote API
Future<void> initRealisasiVisitDependencies() async {
  // Register http client jika belum terdaftar
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }

  // BLoC
  sl.registerFactory(
    () => RealisasiVisitBloc(
      getRealisasiVisits: sl(),
      getRealisasiVisitsGM: sl(),
      approveRealisasiVisit: sl(),
      approveRealisasiVisitGM: sl(),
      rejectRealisasiVisit: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRealisasiVisitsUseCase(sl()));
  sl.registerLazySingleton(() => GetRealisasiVisitsGMUseCase(sl()));
  sl.registerLazySingleton(() => ApproveRealisasiVisitUseCase(sl()));
  sl.registerLazySingleton(() => ApproveRealisasiVisitGMUseCase(sl()));
  sl.registerLazySingleton(() => RejectRealisasiVisitUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RealisasiVisitRepository>(
    () => RealisasiVisitRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RealisasiVisitRemoteDataSource>(
    () => RealisasiVisitRemoteDataSourceImpl(
      client: sl<http.Client>(),
      sharedPreferences: sl(),
    ),
  );
}
