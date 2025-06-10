import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/injection_container.dart';
import '../data/datasources/local_notification_service.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../presentation/bloc/notification_bloc.dart';

/// Inisialisasi dependency injection untuk fitur notifikasi
///
/// Fungsi ini mendaftarkan semua dependency yang dibutuhkan untuk fitur notifikasi:
/// - BLoC: Mengelola state notifikasi
/// - Repository: Abstraksi untuk akses data
/// - Service: Implementasi local notification
Future<void> initNotificationDependencies() async {
  // BLoC
  sl.registerLazySingleton(
    () => NotificationBloc(
      notificationRepository: sl(),
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

  // Service
  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationServiceImpl(
      flutterLocalNotificationsPlugin: sl(),
      sharedPreferences: sl(),
      authRepository: sl(),
      scheduleRepository: sl(),
    ),
  );

  // Plugin
  sl.registerLazySingleton(
    () => FlutterLocalNotificationsPlugin(),
  );
}
