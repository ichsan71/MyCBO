import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:test_cbo/core/network/network_info.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/tipe_schedule_bloc.dart';

import '../../features/auth/di/auth_injection.dart';
import '../../features/schedule/di/schedule_injection.dart';
import '../../features/approval/di/approval_injection.dart';
import '../../features/realisasi_visit/di/realisasi_visit_injection.dart';
import '../../features/schedule/data/datasources/tipe_schedule_remote_data_source.dart';
import '../../features/schedule/data/repositories/tipe_schedule_repository_impl.dart';
import '../../features/schedule/domain/repositories/tipe_schedule_repository.dart';
import '../../features/schedule/domain/usecases/get_tipe_schedules.dart';
import '../../features/schedule/domain/usecases/get_edit_schedule_data.dart';
import '../../features/schedule/presentation/bloc/edit_schedule_bloc.dart';
import '../../features/schedule/domain/usecases/get_schedules.dart';
import '../../features/schedule/domain/usecases/get_schedules_by_range_date.dart';
import '../../features/schedule/domain/usecases/update_schedule.dart';
import '../../features/schedule/domain/usecases/get_rejected_schedules.dart';
import '../../features/notifications/data/datasources/local_notification_service.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Inisialisasi dependency injection untuk seluruh aplikasi
///
/// Fungsi ini akan menginisialisasi semua dependency yang diperlukan oleh aplikasi,
/// termasuk external dependencies, core modules, dan feature modules.
///
/// Dependency injection membantu dalam:
/// 1. Memisahkan pembuatan objek dari penggunaannya
/// 2. Memudahkan testing dengan mock objects
/// 3. Mengurangi coupling antar komponen
/// 4. Memudahkan pengelolaan lifecycle objek
Future<void> init() async {
  //! External dependencies
  await _initExternalDependencies();

  //! Core dependencies
  _initCoreDependencies();

  //! Feature dependencies
  // Initialize Notification Service first
  _initNotificationDependencies();

  await initAuthDependencies();
  await initScheduleDependencies();
  await initApprovalDependencies();
  await initRealisasiVisitDependencies();

  // Inisialisasi Tipe Schedule
  _initTipeScheduleDependencies();

  // Edit Schedule
  sl.registerFactory(
    () => EditScheduleBloc(
      getEditScheduleData: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSchedules(sl()));
  sl.registerLazySingleton(() => GetSchedulesByRangeDate(sl()));
  sl.registerLazySingleton(() => GetEditScheduleData(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => GetRejectedSchedules(sl()));
}

/// Inisialisasi dependencies untuk fitur Tipe Schedule
void _initTipeScheduleDependencies() {
  // UseCases
  sl.registerLazySingleton(() => GetTipeSchedules(sl()));

  // Repository
  sl.registerLazySingleton<TipeScheduleRepository>(
    () => TipeScheduleRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TipeScheduleRemoteDataSource>(
    () => TipeScheduleRemoteDataSourceImpl(
      client: sl<http.Client>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  // Bloc
  sl.registerLazySingleton(
      () => TipeScheduleBloc(getTipeSchedules: sl<GetTipeSchedules>()));
}

/// Initialize notification dependencies
void _initNotificationDependencies() {
  // FlutterLocalNotificationsPlugin
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // LocalNotificationService
  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationServiceImpl(
      flutterLocalNotificationsPlugin: sl(),
      sharedPreferences: sl(),
      authRepository: sl(),
      scheduleRepository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      localNotificationService: sl(),
      sharedPreferences: sl(),
      authRepository: sl(),
      scheduleRepository: sl(),
    ),
  );

  // Blocs
  sl.registerLazySingleton(
    () => NotificationBloc(
      notificationRepository: sl(),
    ),
  );
}

/// Inisialisasi external dependencies seperti shared preferences, http client, dll
Future<void> _initExternalDependencies() async {
  // Shared Preferences untuk penyimpanan lokal
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP Clients untuk komunikasi dengan API
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}

/// Inisialisasi core dependencies yang digunakan di seluruh aplikasi
void _initCoreDependencies() {
  // Database
  sl.registerLazySingleton(() => AppDatabase.instance);

  // Network info untuk cek koneksi internet
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
}
