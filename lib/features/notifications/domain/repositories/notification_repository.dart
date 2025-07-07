import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_settings.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> scheduleCheckoutNotification();
  Future<Either<Failure, void>> scheduleDailyGreeting();
  Future<Either<Failure, void>> scheduleApprovalReminder();
  Future<Either<Failure, NotificationSettings>> getNotificationSettings();
  Future<Either<Failure, void>> saveNotificationSettings(
      NotificationSettings settings);
  Future<Either<Failure, List<String>>> getPendingCheckouts();
  Future<Either<Failure, bool>> isNotificationWorking();
  Future<Either<Failure, void>> testCheckoutNotification();
  Future<Either<Failure, void>> testDailyGreeting();
  Future<Either<Failure, void>> testApprovalReminder();
}
