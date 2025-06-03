import 'package:test_cbo/core/di/injection_container.dart';
import 'package:test_cbo/features/approval/data/datasources/approval_remote_data_source.dart';
import 'package:test_cbo/features/approval/data/repositories/approval_repository_impl.dart';
import 'package:test_cbo/features/approval/domain/repositories/approval_repository.dart';
import 'package:test_cbo/features/approval/domain/usecases/approve_request_usecase.dart';
import 'package:test_cbo/features/approval/domain/usecases/filter_approvals_usecase.dart';
import 'package:test_cbo/features/approval/domain/usecases/get_approvals_usecase.dart';
import 'package:test_cbo/features/approval/domain/usecases/reject_request_usecase.dart';
import 'package:test_cbo/features/approval/domain/usecases/send_approval.dart'
    as send_approval_usecase;
import 'package:test_cbo/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:test_cbo/features/approval/presentation/bloc/monthly_approval_bloc.dart';
import 'package:http/http.dart' as http;

/// Inisialisasi dependency injection untuk fitur approval
///
/// Fungsi ini mendaftarkan semua dependency yang dibutuhkan untuk fitur persetujuan:
/// - BLoC: Mengelola state persetujuan
/// - Use Cases: Fungsi bisnis seperti mendapatkan daftar persetujuan, menyetujui, menolak, dll
/// - Repository: Abstraksi untuk akses data
/// - Data Sources: Implementasi akses data dari remote API
Future<void> initApprovalDependencies() async {
  // Register http client jika belum terdaftar
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }

  // BLoC
  sl.registerFactory(
    () => ApprovalBloc(
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => MonthlyApprovalBloc(
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetApprovalsUseCase(sl()));
  sl.registerLazySingleton(() => FilterApprovalsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectRequestUseCase(sl()));
  sl.registerLazySingleton(() => send_approval_usecase.SendApproval(sl()));

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
      client: sl<http.Client>(),
      sharedPreferences: sl(),
    ),
  );
}
