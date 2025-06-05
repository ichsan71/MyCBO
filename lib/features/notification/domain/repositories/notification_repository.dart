import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_settings.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> scheduleCheckoutReminder(
      int scheduleId, String doctorName, DateTime visitTime);
  Future<Either<Failure, void>> showApprovalNotification(
      int scheduleId, String message);
  Future<Either<Failure, void>> showVisitRealizationNotification(
      int scheduleId, String message);
  Future<Either<Failure, void>> cancelNotification(int scheduleId);
  Future<Either<Failure, NotificationSettings>> getNotificationSettings();
  Future<Either<Failure, void>> saveNotificationSettings(
      NotificationSettings settings);
  Future<Either<Failure, void>> initializeNotifications();
}
