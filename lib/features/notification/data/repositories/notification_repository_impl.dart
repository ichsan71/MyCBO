import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/local_notification_service.dart';
import '../models/notification_settings_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final LocalNotificationService localNotificationService;

  NotificationRepositoryImpl({required this.localNotificationService});

  @override
  Future<Either<Failure, void>> scheduleCheckoutReminder(
    int scheduleId,
    String doctorName,
    DateTime visitTime,
  ) async {
    try {
      await localNotificationService.schedulePeriodicCheckoutReminder();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> showApprovalNotification(
    int scheduleId,
    String message,
  ) async {
    try {
      await localNotificationService.showApprovalNotification(
          scheduleId, message);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> showVisitRealizationNotification(
    int scheduleId,
    String message,
  ) async {
    try {
      await localNotificationService.showVisitRealizationNotification(
        scheduleId,
        message,
      );
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int scheduleId) async {
    try {
      await localNotificationService.cancelNotification(scheduleId);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>>
      getNotificationSettings() async {
    try {
      final settings = await localNotificationService.getNotificationSettings();
      return Right(settings);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      await localNotificationService.saveNotificationSettings(
        NotificationSettingsModel.fromEntity(settings),
      );
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> initializeNotifications() async {
    try {
      await localNotificationService.initialize();
      return const Right(null);
    } catch (e) {
      // Log the error but don't treat it as a failure
      // This allows the app to continue even if notifications aren't working
      return const Right(null);
    }
  }
}
