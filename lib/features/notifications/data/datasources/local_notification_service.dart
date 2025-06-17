import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../domain/entities/notification_settings.dart';
import 'dart:io' show Platform;
import 'package:logger/logger.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/schedule/domain/repositories/schedule_repository.dart';

// Top-level function for handling background notifications
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tap in background
}

abstract class LocalNotificationService {
  Future<void> initialize();
  Future<void> scheduleCheckoutNotification();
  Future<void> scheduleDailyGreeting();
  Future<NotificationSettings> getNotificationSettings();
  Future<void> saveNotificationSettings(NotificationSettings settings);
  Future<bool> requestPermission();
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });
  Future<void> showTestCheckoutNotification(String username);
  Future<void> showTestDailyGreeting(String username);
}

class LocalNotificationServiceImpl implements LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final SharedPreferences sharedPreferences;
  final AuthRepository authRepository;
  final ScheduleRepository scheduleRepository;
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  LocalNotificationServiceImpl({
    required this.flutterLocalNotificationsPlugin,
    required this.sharedPreferences,
    required this.authRepository,
    required this.scheduleRepository,
  });

  @override
  Future<void> initialize() async {
    try {
      logger.i('Starting notification service initialization...');

      // Initialize timezone with explicit local timezone
      try {
        tz.initializeTimeZones();
        final jakarta = tz.getLocation('Asia/Jakarta');
        tz.setLocalLocation(jakarta);
        logger.i('Timezone initialized successfully to Asia/Jakarta');
      } catch (e) {
        logger.e('Failed to initialize timezone: $e');
        throw Exception('Failed to initialize timezone: $e');
      }

      // Initialize Android settings with specific icon
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      logger.d('Android settings initialized with icon: @mipmap/ic_launcher');

      // Initialize settings for all platforms
      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );
      logger.d('Platform settings initialized');

      // Initialize the plugin with explicit handling of notification selection
      final initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          logger.i('Notification clicked: ${details.payload}');
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      if (initialized != true) {
        logger.e('Failed to initialize notification plugin');
        throw Exception('Failed to initialize notification plugin');
      }

      logger.i('Notification plugin initialized successfully');

      // Check and setup notification channels and permissions
      final setupSuccess = await _checkNotificationSetup();
      if (!setupSuccess) {
        logger.e('Failed to setup notifications properly');
        throw Exception('Failed to setup notifications properly');
      }

      logger.i('Notification service initialization completed successfully');

      // Schedule initial notifications
      await scheduleCheckoutNotification();
      await scheduleDailyGreeting();
      logger.i('Initial notifications scheduled');
    } catch (e, stackTrace) {
      logger.e('Error initializing notification service: $e\n$stackTrace');
      throw Exception('Failed to initialize notification service: $e');
    }
  }

  @override
  Future<void> scheduleCheckoutNotification() async {
    try {
      logger.i('Starting checkout notification scheduling...');

      // Get current user
      final userResult = await authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        logger.e('Failed to get current user for checkout notification');
        return;
      }
      final user = userResult.getOrElse(() => throw Exception('User not found'));
      logger.d('Got current user for checkout: ${user.name}');

      // Get schedules for current user
      final schedulesResult = await scheduleRepository.getSchedules(user.idUser);
      if (schedulesResult.isLeft()) {
        logger.e('Failed to get schedules for checkout notification');
        return;
      }
      final schedules = schedulesResult.getOrElse(() => []);
      logger.d('Retrieved ${schedules.length} schedules for checkout check');

      // Filter schedules that need checkout
      final pendingCheckouts = schedules
          .where((schedule) =>
              schedule.statusCheckin.toLowerCase() == 'belum checkout')
          .toList();
      logger.d('Found ${pendingCheckouts.length} pending checkouts');

      // Cancel any existing notifications first
      await flutterLocalNotificationsPlugin.cancel(1); // Immediate notification ID
      await flutterLocalNotificationsPlugin.cancel(3); // Periodic notification ID
      logger.d('Cancelled existing checkout notifications');

      if (pendingCheckouts.isNotEmpty) {
        // Create Android-specific notification details for immediate notification
        const androidDetailsImmediate = AndroidNotificationDetails(
          'checkout_immediate_channel',
          'Checkout Reminders (Immediate)',
          channelDescription: 'Immediate reminders for pending checkouts',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        );

        const notificationDetailsImmediate = NotificationDetails(
          android: androidDetailsImmediate,
        );

        // Show immediate notification
        await flutterLocalNotificationsPlugin.show(
          1,
          'Pengingat Check-out',
          'Halo ${user.name}, Anda memiliki ${pendingCheckouts.length} checkout yang belum diselesaikan. Mohon segera diselesaikan.',
          notificationDetailsImmediate,
        );
        logger.i('Immediate checkout notification displayed');

        // Create Android-specific notification details for periodic notification
        const androidDetailsPeriodic = AndroidNotificationDetails(
          'checkout_periodic_channel',
          'Checkout Reminders (Periodic)',
          channelDescription: 'Periodic reminders for pending checkouts',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          ongoing: true,
          autoCancel: false,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.reminder,
        );

        const notificationDetailsPeriodic = NotificationDetails(
          android: androidDetailsPeriodic,
        );

        // Schedule periodic notification every minute
        await flutterLocalNotificationsPlugin.periodicallyShow(
          3,
          'Pengingat Check-out',
          'Halo ${user.name}, Anda masih memiliki ${pendingCheckouts.length} checkout yang belum diselesaikan.',
          RepeatInterval.hourly,
          notificationDetailsPeriodic,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        logger.i('Periodic checkout notification scheduled (every hour)');

        // Save last checkout check time
        await sharedPreferences.setString(
          'last_checkout_check',
          DateTime.now().toIso8601String(),
        );
        logger.d('Updated last checkout check timestamp');
      } else {
        logger.i('No pending checkouts found, notifications cleared');
      }
    } catch (e, stackTrace) {
      logger.e('Error in checkout notification: $e\n$stackTrace');
      throw Exception('Failed to schedule checkout notification: $e');
    }
  }

  @override
  Future<void> scheduleDailyGreeting() async {
    try {
      logger.i('Starting daily greeting scheduling...');

      // Get current user
      final userResult = await authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        logger.e('Failed to get current user for daily greeting');
        return;
      }
      final user = userResult.getOrElse(() => throw Exception('User not found'));
      logger.d('Got current user for greeting: ${user.name}');

      // Create Android-specific notification details
      const androidDetails = AndroidNotificationDetails(
        'daily_greeting_channel',
        'Daily Greetings',
        channelDescription: 'Channel for daily greeting notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        channelShowBadge: true,
        category: AndroidNotificationCategory.reminder,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // Cancel any existing daily greeting notification
      await flutterLocalNotificationsPlugin.cancel(2);
      logger.d('Cancelled existing daily greeting notification');

      // Get current time
      final now = DateTime.now();
      logger.d('Current time: $now');

      // Check if we're in the greeting window (14:53 - 14:56)
      if (now.hour == 9 && now.minute >= 0 && now.minute < 3) {
        logger.d('Within greeting time window, showing immediate notification');
        
        // Show immediate notification
        await flutterLocalNotificationsPlugin.show(
          2,
          'Selamat Pagi,',
          'Halo ${user.name}, semoga hari Anda menyenangkan!',
          notificationDetails,
        );
        logger.i('Immediate daily greeting displayed');
      }

      // Schedule daily notification
      final scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
      final scheduledTimeString = '${scheduledTime.hour}:${scheduledTime.minute}';
      logger.d('Attempting to schedule daily notification for $scheduledTimeString');

      // Schedule periodic notification
      await flutterLocalNotificationsPlugin.periodicallyShow(
        4, // Different ID for periodic daily greeting
        'Selamat Pagi,',
        'Halo ${user.name}, semoga hari Anda menyenangkan!',
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      logger.i('Daily greeting scheduled successfully');

      // Save last daily greeting time
      await sharedPreferences.setString(
        'last_daily_greeting',
        DateTime.now().toIso8601String(),
      );
      logger.d('Updated last daily greeting timestamp');
    } catch (e, stackTrace) {
      logger.e('Error in daily greeting: $e\n$stackTrace');
      throw Exception('Failed to schedule daily greeting: $e');
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      logger.d('Getting notification settings...');

      // Get raw values
      final lastCheckoutCheckRaw = sharedPreferences.get('last_checkout_check');
      final lastDailyGreetingRaw = sharedPreferences.get('last_daily_greeting');

      // Convert to DateTime
      DateTime lastCheckoutCheck;
      if (lastCheckoutCheckRaw is String) {
        lastCheckoutCheck = DateTime.parse(lastCheckoutCheckRaw);
      } else if (lastCheckoutCheckRaw is int) {
        lastCheckoutCheck =
            DateTime.fromMillisecondsSinceEpoch(lastCheckoutCheckRaw);
      } else {
        lastCheckoutCheck = DateTime.fromMillisecondsSinceEpoch(0);
      }

      DateTime lastDailyGreeting;
      if (lastDailyGreetingRaw is String) {
        lastDailyGreeting = DateTime.parse(lastDailyGreetingRaw);
      } else if (lastDailyGreetingRaw is int) {
        lastDailyGreeting =
            DateTime.fromMillisecondsSinceEpoch(lastDailyGreetingRaw);
      } else {
        lastDailyGreeting = DateTime.fromMillisecondsSinceEpoch(0);
      }

      final settings = NotificationSettings(
        isCheckoutEnabled:
            sharedPreferences.getBool('checkout_enabled') ?? true,
        isDailyGreetingEnabled:
            sharedPreferences.getBool('daily_greeting_enabled') ?? true,
        userName: sharedPreferences.getString('user_name') ?? '',
        lastCheckoutCheck: lastCheckoutCheck,
        lastDailyGreeting: lastDailyGreeting,
      );

      logger.d('Retrieved settings: ${settings.toString()}');
      return settings;
    } catch (e, stackTrace) {
      logger.e('Error getting notification settings: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      logger.d('Saving notification settings...');

      await sharedPreferences.setBool(
          'checkout_enabled', settings.isCheckoutEnabled);
      await sharedPreferences.setBool(
          'daily_greeting_enabled', settings.isDailyGreetingEnabled);
      await sharedPreferences.setString('user_name', settings.userName);
      await sharedPreferences.setString(
          'last_checkout_check', settings.lastCheckoutCheck.toIso8601String());
      await sharedPreferences.setString(
          'last_daily_greeting', settings.lastDailyGreeting.toIso8601String());

      logger.i('Notification settings saved successfully');
    } catch (e) {
      logger.e('Error saving notification settings: $e');
      rethrow;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      logger.i('Requesting notification permissions...');

      if (Platform.isAndroid) {
        final androidImplementation = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final notificationPermissionGranted =
            await androidImplementation?.requestNotificationsPermission() ??
                false;
        logger.d(
            'Android notification permission result: $notificationPermissionGranted');

        final exactAlarmPermissionGranted =
            await androidImplementation?.requestExactAlarmsPermission() ??
                false;
        logger.d(
            'Android exact alarm permission result: $exactAlarmPermissionGranted');

        final result =
            notificationPermissionGranted && exactAlarmPermissionGranted;
        logger.i('Android permissions granted: $result');
        return result;
      } else if (Platform.isIOS) {
        final iosImplementation = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        final result = await iosImplementation?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;

        logger.i('iOS permissions granted: $result');
        return result;
      }

      logger.w('Unsupported platform for notifications');
      return false;
    } catch (e) {
      logger.e('Error requesting notification permissions: $e');
      return false;
    }
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      logger.d('Scheduling notification: ID=$id, title=$title');

      // Cancel any existing notification with the same ID
      await flutterLocalNotificationsPlugin.cancel(id);
      logger.d('Cancelled existing notification with ID $id');

      // Create Android-specific notification details
      const androidDetails = AndroidNotificationDetails(
        'notifications_channel',
        'Notifications',
        channelDescription: 'General notifications channel',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // Convert DateTime to TZDateTime
      final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
      logger.d('Scheduling for: $scheduledTZDate');

      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      logger.i('Notification scheduled successfully');
    } catch (e) {
      logger.e('Error scheduling notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> showTestCheckoutNotification(String username) async {
    try {
      logger.i('Testing checkout notification...');

      // Create Android-specific notification details
      const androidDetails = AndroidNotificationDetails(
        'test_checkout_channel',
        'Test Checkout Notifications',
        channelDescription: 'Channel for testing checkout notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // Show immediate test notification
      await flutterLocalNotificationsPlugin.show(
        100,
        'Test Pengingat Checkout',
        'Halo $username, ini adalah test notifikasi checkout.',
        notificationDetails,
      );

      logger.i('Test checkout notification shown successfully');

      // Test periodic notification (every minute)
      await flutterLocalNotificationsPlugin.periodicallyShow(
        101,
        'Test Pengingat Checkout (Periodic)',
        'Halo $username, ini adalah test notifikasi checkout periodic.',
        RepeatInterval.hourly,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      logger.i('Test periodic checkout notification scheduled (hourly)');
    } catch (e, stackTrace) {
      logger.e('Error showing test checkout notification: $e\n$stackTrace');
      throw Exception('Failed to show test checkout notification: $e');
    }
  }

  @override
  Future<void> showTestDailyGreeting(String username) async {
    try {
      logger.i('Testing daily greeting notification...');

      // Create Android-specific notification details
      const androidDetails = AndroidNotificationDetails(
        'test_greeting_channel',
        'Test Greeting Notifications',
        channelDescription: 'Channel for testing greeting notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // Show immediate test notification
      await flutterLocalNotificationsPlugin.show(
        102,
        'Test Sapaan Pagi',
        'Halo $username, ini adalah test notifikasi sapaan pagi.',
        notificationDetails,
      );

      logger.i('Test greeting notification shown successfully');

      // Test daily notification
      await flutterLocalNotificationsPlugin.periodicallyShow(
        103,
        'Test Sapaan Pagi (Periodic)',
        'Halo $username, ini adalah test notifikasi sapaan pagi periodic.',
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      logger.i('Test periodic greeting notification scheduled');
    } catch (e, stackTrace) {
      logger.e('Error showing test greeting notification: $e\n$stackTrace');
      throw Exception('Failed to show test greeting notification: $e');
    }
  }

  // Helper method to check notification permissions and channels
  Future<bool> _checkNotificationSetup() async {
    try {
      logger.i('Checking notification setup...');

      // Check notification permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        logger.e('Notification permissions not granted');
        return false;
      }
      logger.d('Notification permissions are granted');

      if (Platform.isAndroid) {
        final androidPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin == null) {
          logger.e('Failed to resolve Android plugin');
          return false;
        }

        // Create/verify notification channels
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'checkout_immediate_channel',
            'Checkout Reminders (Immediate)',
            description: 'Immediate reminders for pending checkouts',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'checkout_periodic_channel',
            'Checkout Reminders (Periodic)',
            description: 'Periodic reminders for pending checkouts',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'daily_greeting_channel',
            'Daily Greetings',
            description: 'Channel for daily greeting notifications',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

        logger.d('Notification channels verified/created');
      }

      logger.i('Notification setup check completed successfully');
      return true;
    } catch (e, stackTrace) {
      logger.e('Error checking notification setup: $e\n$stackTrace');
      return false;
    }
  }
}
