import 'package:test_cbo/core/di/injection_container.dart';
import 'package:test_cbo/features/schedule/data/datasources/add_schedule_remote_data_source.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source_impl.dart';
import 'package:test_cbo/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:test_cbo/features/schedule/data/repositories/add_schedule_repository_impl.dart';
import 'package:test_cbo/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';
import 'package:test_cbo/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:test_cbo/features/schedule/domain/usecases/add_schedule.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors_and_clinics.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_products.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedule_types.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedules_usecase.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_edit_schedule_usecase.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedules_by_range_date_usecase.dart'
    as range_date_usecase;
import 'package:test_cbo/features/schedule/domain/usecases/update_schedule_usecase.dart';

/// Inisialisasi dependency injection untuk fitur schedule
///
/// Fungsi ini mendaftarkan semua dependency yang dibutuhkan untuk fitur jadwal:
/// - BLoC: Mengelola state jadwal dan penambahan jadwal
/// - Use Cases: Fungsi bisnis seperti mendapatkan jadwal, menambah jadwal, dll
/// - Repository: Abstraksi untuk akses data
/// - Data Sources: Implementasi akses data dari remote API dan database lokal
Future<void> initScheduleDependencies() async {
  // BLoC
  sl.registerFactory(
    () => ScheduleBloc(
      getSchedulesUseCase: sl(),
      getSchedulesByRangeDateUseCase: sl(),
      approvalRepository: sl(),
      getEditScheduleUseCase: sl(),
      updateScheduleUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AddScheduleBloc(
      getDoctorsAndClinics: sl(),
      getScheduleTypes: sl(),
      getProducts: sl(),
      getDoctors: sl(),
      addSchedule: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSchedulesUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorsAndClinics(sl()));
  sl.registerLazySingleton(() => GetScheduleTypes(sl()));
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetDoctors(sl()));
  sl.registerLazySingleton(() => AddSchedule(sl()));
  sl.registerLazySingleton(
      () => range_date_usecase.GetSchedulesByRangeDateUseCase(sl()));
  sl.registerLazySingleton(() => GetEditScheduleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateScheduleUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AddScheduleRepository>(
    () => AddScheduleRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<AddScheduleRemoteDataSource>(
    () => AddScheduleRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Local Data Sources
  sl.registerLazySingleton<AddScheduleLocalDataSource>(
    () => AddScheduleLocalDataSourceImpl(
      database: sl(),
    ),
  );
}
