import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../domain/entities/notification_settings.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:logger/logger.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/schedule/domain/repositories/schedule_repository.dart';

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
      printTime: true,
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
      logger.i('Initializing notification service...');

      // Initialize timezone
      try {
        tz.initializeTimeZones();
        logger.i('Timezone initialized successfully');
      } catch (e) {
        logger.e('Failed to initialize timezone: $e');
        throw Exception('Failed to initialize timezone: $e');
      }

      // Initialize Android settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      logger.d('Android settings initialized');

      // Initialize settings for all platforms
      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );
      logger.d('Platform settings initialized');

      // Initialize the plugin
      final initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          logger.i('Notification clicked: ${details.payload}');
        },
      );

      if (initialized != true) {
        logger.e('Failed to initialize notification plugin');
        throw Exception('Failed to initialize notification plugin');
      }

      logger.i('Notification plugin initialized successfully');

      // Request notification permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        logger.w('Notification permissions not granted');
      } else {
        logger.i('Notification permissions granted');
      }

      // Create notification channel for Android
      if (Platform.isAndroid) {
        const androidChannel = AndroidNotificationChannel(
          'notifications_channel',
          'Notifications',
          description: 'General notifications channel',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);

        logger.i('Android notification channel created');
      }

      logger.i('Notification service initialization completed successfully');
    } catch (e) {
      logger.e('Error initializing notification service: $e');
      throw Exception('Failed to initialize notification service: $e');
    }
  }

  @override
  Future<void> scheduleCheckoutNotification() async {
    try {
      logger.i('Scheduling checkout notification...');

      // Get current user
      final userResult = await authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        logger.e('Failed to get current user');
        return;
      }
      final user =
          userResult.getOrElse(() => throw Exception('User not found'));
      logger.d('Got current user: ${user.name}');

      // Update username in settings
      await sharedPreferences.setString('user_name', user.name);
      logger.d('Updated username in settings to: ${user.name}');

      // Get schedules for current user
      final schedulesResult =
          await scheduleRepository.getSchedules(user.idUser);
      if (schedulesResult.isLeft()) {
        logger.e('Failed to get schedules');
        return;
      }
      final schedules = schedulesResult.getOrElse(() => []);
      logger.d('Got ${schedules.length} schedules');

      // Filter schedules that need checkout
      final pendingCheckouts = schedules
          .where((schedule) =>
              schedule.statusCheckin.toLowerCase() == 'belum checkout')
          .toList();
      logger.d('Found ${pendingCheckouts.length} pending checkouts');

      if (pendingCheckouts.isNotEmpty) {
        // Cancel any existing notification first
        await flutterLocalNotificationsPlugin.cancel(1);
        logger.d('Cancelled existing checkout notifications');

        // Create Android-specific notification details
        const androidDetails = AndroidNotificationDetails(
          'checkout_channel',
          'Checkout Reminders',
          channelDescription: 'Periodic reminders for pending checkouts',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          ongoing: true,
          autoCancel: false,
        );

        const notificationDetails =
            NotificationDetails(android: androidDetails);

        // Schedule periodic notification every hour
        await flutterLocalNotificationsPlugin.periodicallyShow(
          1,
          'Checkout Reminder',
          'Hello ${user.name}, you have ${pendingCheckouts.length} pending checkouts. Please complete them.',
          RepeatInterval.hourly,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        logger.i('Periodic checkout notification scheduled for every hour');

        // Save last checkout check time
        await sharedPreferences.setString(
          'last_checkout_check',
          DateTime.now().toIso8601String(),
        );
        logger.d('Saved last checkout check time');
      } else {
        await flutterLocalNotificationsPlugin.cancel(1);
        logger.i('No pending checkouts, cancelled notifications');
      }
    } catch (e) {
      logger.e('Error scheduling checkout notification: $e');
    }
  }

  @override
  Future<void> scheduleDailyGreeting() async {
    try {
      logger.i('Scheduling daily greeting...');

      // Get current user
      final userResult = await authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        logger.e('Failed to get current user');
        return;
      }
      final user =
          userResult.getOrElse(() => throw Exception('User not found'));
      logger.d('Got current user: ${user.name}');

      // Update username in settings
      await sharedPreferences.setString('user_name', user.name);
      logger.d('Updated username in settings to: ${user.name}');

      // Calculate next greeting time (9:00)
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        10,
        0,
      );

      // If it's past 9:00, schedule for tomorrow
      if (now.isAfter(scheduledDate)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        logger.d('Scheduling greeting for tomorrow at 9:00');
      } else {
        logger.d('Scheduling greeting for today at 9:00');
      }

      await scheduleNotification(
        id: 2,
        title: 'Daily Greeting',
        body: 'Hello ${user.name}, have a great day!',
        scheduledDate: scheduledDate,
      );

      // Save last daily greeting time
      await sharedPreferences.setString(
        'last_daily_greeting',
        DateTime.now().toIso8601String(),
      );
      logger.d('Saved last daily greeting time');

      logger.i('Daily greeting scheduled successfully');
    } catch (e) {
      logger.e('Error scheduling daily greeting: $e');
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
      logger.i('Showing test checkout notification...');

      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        100, // Different ID for test notifications
        'Test Checkout Reminder',
        'Hello $username, this is a test checkout reminder notification.',
        notificationDetails,
      );

      logger.i('Test checkout notification shown successfully');
    } catch (e) {
      logger.e('Error showing test checkout notification: $e');
      throw Exception('Failed to show test checkout notification: $e');
    }
  }

  @override
  Future<void> showTestDailyGreeting(String username) async {
    try {
      logger.i('Showing test daily greeting...');

      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        101, // Different ID for test notifications
        'Test Daily Greeting',
        'Hello $username, this is a test daily greeting notification.',
        notificationDetails,
      );

      logger.i('Test daily greeting shown successfully');
    } catch (e) {
      logger.e('Error showing test daily greeting: $e');
      throw Exception('Failed to show test daily greeting: $e');
    }
  }
}
