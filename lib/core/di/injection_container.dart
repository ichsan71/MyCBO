import 'package:get_it/get_it.dart';
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
import '../../features/check_in/data/datasources/check_in_remote_data_source.dart';
import '../../features/check_in/data/repositories/check_in_repository_impl.dart';
import '../../features/check_in/domain/repositories/check_in_repository.dart';
import '../network/dio_config.dart';
import '../../features/kpi/data/repositories/kpi_repository_impl.dart';
import '../../features/kpi/domain/repositories/kpi_repository.dart';
import '../../features/kpi/domain/usecases/get_kpi_data.dart';
import '../../features/kpi/presentation/bloc/kpi_bloc.dart';
import '../../features/kpi/presentation/bloc/kpi_member_bloc.dart';
import '../../features/kpi/data/datasources/kpi_member_remote_data_source.dart';
import '../../features/kpi/data/repositories/kpi_member_repository_impl.dart';
import '../../features/kpi/domain/repositories/kpi_member_repository.dart';
import '../../features/kpi/domain/usecases/get_kpi_member_data_usecase.dart';
import '../../features/realisasi_visit/data/datasources/realisasi_visit_remote_data_source.dart';
import '../../features/realisasi_visit/data/repositories/realisasi_visit_repository_impl.dart';
import '../../features/realisasi_visit/domain/repositories/realisasi_visit_repository.dart';
import '../../features/realisasi_visit/domain/usecases/get_realisasi_visits.dart';
import '../../features/realisasi_visit/domain/usecases/get_realisasi_visits_gm.dart';
import '../../features/realisasi_visit/domain/usecases/get_realisasi_visits_gm_details.dart';
import '../../features/realisasi_visit/domain/usecases/approve_realisasi_visit.dart';
import '../../features/realisasi_visit/domain/usecases/reject_realisasi_visit.dart';
import '../../features/realisasi_visit/presentation/bloc/realisasi_visit_bloc.dart';
import '../../features/chatbot/di/chatbot_injection.dart';
import '../../features/ranking_achievement/di/ranking_achievement_injection.dart';
import '../services/photo_storage_service.dart';
import '../services/cleanup_scheduler_service.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies with optimization for startup performance
Future<void> init() async {
  // Initialize only critical dependencies first
  await _initCriticalDependencies();

  // Initialize non-critical dependencies lazily
  await _initNonCriticalDependencies();
}

/// Initialize critical dependencies needed for app startup
Future<void> _initCriticalDependencies() async {
  // External dependencies (critical)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core HTTP client (critical for auth)
  sl.registerLazySingleton(() => DioConfig.createDio());
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton<String>(
    () => 'https://dev-bco.businesscorporateofficer.com/api',
    instanceName: 'baseUrl',
  );

  // Network info (critical)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Photo storage service (critical for restoring photos)
  sl.registerLazySingleton<PhotoStorageService>(
    () => PhotoStorageService(sl()),
  );

  // Auth feature (critical for startup)
  injectAuth(sl);
}

/// Initialize non-critical dependencies that can be loaded lazily
Future<void> _initNonCriticalDependencies() async {
  // Register remaining external dependencies lazily
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Database (lazy - will be initialized when first accessed)
  sl.registerLazySingleton(() => AppDatabase.instance);

  // Schedule feature dependencies (lazy)
  await initScheduleDependencies();
  _initTipeScheduleDependencies();
  _initEditScheduleDependencies();

  // Other feature dependencies (lazy)
  await initApprovalDependencies();
  await _initRealisasiVisitDependencies();
  _initNotificationDependencies();
  _initCheckInDependencies();
  _initKpiDependencies();
  await initRankingAchievementDependencies(sl);
  await initChatbotDependencies(sl);
}

// /// Initialize external dependencies
// Future<void> _initExternalDependencies() async {
//   // This method is now split into critical and non-critical
//   // Keep for backward compatibility if needed
// }

// /// Initialize core dependencies
// void _initCoreDependencies() {
//   // This method is now handled in _initCriticalDependencies and _initNonCriticalDependencies
//   // Keep for backward compatibility if needed
// }

// /// Initialize feature dependencies
// Future<void> _initFeatureDependencies() async {
//   // This method is now handled in _initCriticalDependencies and _initNonCriticalDependencies
//   // Keep for backward compatibility if needed
// }

/// Initialize Tipe Schedule dependencies
void _initTipeScheduleDependencies() {
  // Use cases
  sl.registerLazySingleton(() => GetTipeSchedules(sl()));

  // Repository
  sl.registerLazySingleton<TipeScheduleRepository>(
    () => TipeScheduleRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TipeScheduleRemoteDataSource>(
    () => TipeScheduleRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Bloc (lazy factory)
  sl.registerFactory(() => TipeScheduleBloc(getTipeSchedules: sl()));
}

/// Initialize Edit Schedule dependencies
void _initEditScheduleDependencies() {
  // Bloc (factory for multiple instances)
  sl.registerFactory(() => EditScheduleBloc(getEditScheduleData: sl()));

  // Use cases (lazy singletons)
  sl.registerLazySingleton(() => GetEditScheduleData(sl()));
  sl.registerLazySingleton(() => GetSchedules(sl()));
  sl.registerLazySingleton(() => GetSchedulesByRangeDate(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => GetRejectedSchedules(sl()));
}

/// Initialize Notification dependencies
void _initNotificationDependencies() {
  // Service (lazy singleton)
  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationServiceImpl(
      flutterLocalNotificationsPlugin: sl(),
      sharedPreferences: sl(),
      authRepository: sl(),
      scheduleRepository: sl(),
    ),
  );

  // Repository (lazy singleton)
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      localNotificationService: sl(),
      sharedPreferences: sl(),
      authRepository: sl(),
      scheduleRepository: sl(),
    ),
  );

  // Bloc (factory for better performance)
  sl.registerFactory(() => NotificationBloc(repository: sl()));
}

/// Initialize Check-in dependencies
void _initCheckInDependencies() {
  // Data sources (lazy)
  sl.registerLazySingleton<CheckInRemoteDataSource>(
    () => CheckInRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<CheckInRepository>(
    () => CheckInRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
}

/// Initialize KPI dependencies
void _initKpiDependencies() {
  // KPI Member
  sl.registerFactory(() => KpiMemberBloc(getKpiMemberDataUseCase: sl()));
  sl.registerLazySingleton(() => GetKpiMemberDataUseCase(sl()));
  sl.registerLazySingleton<KpiMemberRepository>(
    () => KpiMemberRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<KpiMemberRemoteDataSource>(
    () => KpiMemberRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );

  // KPI
  sl.registerFactory(() => KpiBloc(getKpiData: sl()));
  sl.registerLazySingleton(() => GetKpiData(sl()));
  sl.registerLazySingleton<KpiRepository>(
    () => KpiRepositoryImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
}

/// Initialize Realisasi Visit dependencies
Future<void> _initRealisasiVisitDependencies() async {
  // Bloc
  sl.registerFactory(
    () => RealisasiVisitBloc(
      getRealisasiVisits: sl(),
      getRealisasiVisitsGM: sl(),
      getRealisasiVisitsGMDetails: sl(),
      approveRealisasiVisit: sl(),
      rejectRealisasiVisit: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRealisasiVisits(sl()));
  sl.registerLazySingleton(() => GetRealisasiVisitsGM(sl()));
  sl.registerLazySingleton(() => GetRealisasiVisitsGMDetails(sl()));
  sl.registerLazySingleton(() => ApproveRealisasiVisit(sl()));
  sl.registerLazySingleton(() => RejectRealisasiVisit(sl()));

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
      client: sl(),
      baseUrl: sl<String>(instanceName: 'baseUrl'),
      sharedPreferences: sl(),
    ),
  );
}
