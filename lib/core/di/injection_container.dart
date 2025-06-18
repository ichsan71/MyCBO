import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:test_cbo/core/network/network_info.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/tipe_schedule_bloc.dart';
import 'package:dio/dio.dart';

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

/// Service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // External dependencies
  await _initExternalDependencies();

  // Core dependencies
  _initCoreDependencies();

  // Feature dependencies
  await _initFeatureDependencies();
}

/// Initialize external dependencies
Future<void> _initExternalDependencies() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP Clients
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DioConfig.createDio());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}

/// Initialize core dependencies
void _initCoreDependencies() {
  // Network info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Database
  sl.registerLazySingleton(() => AppDatabase.instance);

  // Notifications
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
}

/// Initialize feature dependencies
Future<void> _initFeatureDependencies() async {
  // Auth feature
  await initAuthDependencies();

  // Schedule feature
  await initScheduleDependencies();
  _initTipeScheduleDependencies();
  _initEditScheduleDependencies();

  // Approval feature
  await initApprovalDependencies();

  // Realisasi Visit feature
  await initRealisasiVisitDependencies();

  // Notification feature
  _initNotificationDependencies();

  // Check-in feature
  _initCheckInDependencies();

  // KPI feature
  _initKpiDependencies();
}

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

  // Bloc
  sl.registerLazySingleton(() => TipeScheduleBloc(getTipeSchedules: sl()));
}

/// Initialize Edit Schedule dependencies
void _initEditScheduleDependencies() {
  // Bloc
  sl.registerFactory(() => EditScheduleBloc(getEditScheduleData: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetEditScheduleData(sl()));
  sl.registerLazySingleton(() => GetSchedules(sl()));
  sl.registerLazySingleton(() => GetSchedulesByRangeDate(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => GetRejectedSchedules(sl()));
}

/// Initialize Notification dependencies
void _initNotificationDependencies() {
  // Service
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

  // Bloc
  sl.registerLazySingleton(() => NotificationBloc(repository: sl()));
}

/// Initialize Check-in dependencies
void _initCheckInDependencies() {
  // Data sources
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
