import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final LocalNotificationService localNotificationService;
  final SharedPreferences sharedPreferences;
  final AuthRepository authRepository;
  final ScheduleRepository scheduleRepository;

  NotificationRepositoryImpl({
    required this.localNotificationService,
    required this.sharedPreferences,
    required this.authRepository,
    required this.scheduleRepository,
  });

  @override
  Future<Either<Failure, void>> scheduleCheckoutNotification() async {
    try {
      await localNotificationService.scheduleCheckoutNotification();
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to schedule checkout notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleDailyGreeting() async {
    try {
      await localNotificationService.scheduleDailyGreeting();
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to schedule daily greeting: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleApprovalReminder() async {
    try {
      await localNotificationService.scheduleApprovalReminder();
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to schedule approval reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>>
      getNotificationSettings() async {
    try {
      final settings = await localNotificationService.getNotificationSettings();
      final currentUserResult = await authRepository.getCurrentUser();
      return currentUserResult.fold(
        (failure) => Right(settings),
        (user) => Right(settings.copyWith(userName: user.name)),
      );
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to get notification settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveNotificationSettings(
      NotificationSettings settings) async {
    try {
      await localNotificationService.saveNotificationSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to save notification settings: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPendingCheckouts() async {
    try {
      // Get current user
      final userResult = await authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        return const Right([]);
      }
      final user =
          userResult.getOrElse(() => throw Exception('User not found'));

      // Get schedules for current user
      final schedulesResult =
          await scheduleRepository.getSchedules(user.idUser);
      if (schedulesResult.isLeft()) {
        return const Right([]);
      }
      final schedules = schedulesResult.getOrElse(() => []);

      // Filter schedules that need checkout
      final pendingCheckouts = schedules
          .where((schedule) =>
              schedule.statusCheckin.toLowerCase() == 'belum checkout')
          .map((schedule) =>
              'Schedule for ${schedule.tglVisit} - ${schedule.shift} at ${schedule.namaTujuan}')
          .toList();

      return Right(pendingCheckouts);
    } catch (e) {
      return Left(
          NotificationFailure(message: 'Failed to get pending checkouts: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isNotificationWorking() async {
    try {
      final hasPermission = await localNotificationService.requestPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to check notification status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> testCheckoutNotification() async {
    try {
      final settings = await localNotificationService.getNotificationSettings();
      await localNotificationService
          .showTestCheckoutNotification(settings.userName);
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(
          message: 'Failed to test checkout notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> testDailyGreeting() async {
    try {
      final settings = await localNotificationService.getNotificationSettings();
      await localNotificationService.showTestDailyGreeting(settings.userName);
      return const Right(null);
    } catch (e) {
      return Left(
          NotificationFailure(message: 'Failed to test daily greeting: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> testApprovalReminder() async {
    try {
      final settings = await localNotificationService.getNotificationSettings();
      await localNotificationService
          .showTestApprovalReminder(settings.userName);
      return const Right(null);
    } catch (e) {
      return Left(
          NotificationFailure(message: 'Failed to test approval reminder: $e'));
    }
  }
}
