import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:test_cbo/core/network/network_info.dart';

import '../../features/auth/di/auth_injection.dart';
import '../../features/schedule/di/schedule_injection.dart';
import '../../features/approval/di/approval_injection.dart';
import '../../features/realisasi_visit/di/realisasi_visit_injection.dart';

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
  await initAuthDependencies();
  await initScheduleDependencies();
  await initApprovalDependencies();
  await initRealisasiVisitDependencies();
}

/// Inisialisasi external dependencies seperti shared preferences, http client, dll
Future<void> _initExternalDependencies() async {
  // Shared Preferences untuk penyimpanan lokal
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP Clients untuk komunikasi dengan API
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
