import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:test_cbo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:test_cbo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:test_cbo/features/auth/domain/repositories/auth_repository.dart';
import 'package:test_cbo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:test_cbo/features/auth/domain/usecases/login_usecase.dart';
import 'package:test_cbo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/schedule/data/datasources/add_schedule_remote_data_source.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source_impl.dart';
import 'package:test_cbo/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:test_cbo/features/schedule/data/repositories/add_schedule_repository_impl.dart';
import 'package:test_cbo/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';
import 'package:test_cbo/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:test_cbo/features/schedule/domain/usecases/add_schedule.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors_and_clinics.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_products.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedule_types.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedules_usecase.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors.dart';
import 'package:http/http.dart' as http;
import '../../features/approval/data/datasources/approval_remote_data_source.dart';
import '../../features/approval/data/repositories/approval_repository_impl.dart';
import '../../features/approval/domain/repositories/approval_repository.dart';
import '../../features/approval/domain/usecases/send_approval.dart';
import '../../features/approval/presentation/bloc/approval_bloc.dart';
import '../../features/approval/domain/usecases/get_approvals_usecase.dart';
import '../../features/approval/domain/usecases/approve_request_usecase.dart';
import '../../features/approval/domain/usecases/reject_request_usecase.dart';
import '../../features/approval/domain/usecases/filter_approvals_usecase.dart';

import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

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

  //! Features - Schedule
  // Bloc
  sl.registerFactory(
    () => ScheduleBloc(
      getSchedulesUseCase: sl(),
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

  //! Core
  sl.registerLazySingleton(() => AppDatabase.instance);
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  //! Features - Approval
  // BLoC
  sl.registerFactory(
    () => ApprovalBloc(
      getApprovals: sl(),
      filterApprovals: sl(),
      approveRequest: sl(),
      rejectRequest: sl(),
      sendApproval: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetApprovalsUseCase(sl()));
  sl.registerLazySingleton(() => FilterApprovalsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectRequestUseCase(sl()));
  sl.registerLazySingleton(() => SendApproval(sl()));

  // Repository
  sl.registerLazySingleton<ApprovalRepository>(
    () => ApprovalRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ApprovalRemoteDataSource>(
    () => ApprovalRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
}
