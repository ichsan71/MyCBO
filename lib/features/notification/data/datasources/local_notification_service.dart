import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/error/exceptions.dart';
import '../models/notification_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import '../../../../core/utils/constants.dart';

abstract class LocalNotificationService {
  Future<void> initialize();
  Future<void> scheduleMorningGreeting(String userName);
  Future<void> schedulePeriodicCheckoutReminder();
  Future<void> showApprovalNotification(int scheduleId, String message);
  Future<void> showVisitRealizationNotification(int scheduleId, String message);
  Future<void> cancelNotification(int scheduleId);
  Future<NotificationSettingsModel> getNotificationSettings();
  Future<void> saveNotificationSettings(NotificationSettingsModel settings);
  Future<void> showTestNotification();
  Future<bool> requestPermission();
  Future<bool> checkPermission();
}

class LocalNotificationServiceImpl implements LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final SharedPreferences sharedPreferences;
  static const String notificationSettingsKey = 'NOTIFICATION_SETTINGS';
  final _logger = Logger('LocalNotificationService');

  LocalNotificationServiceImpl({
    required this.flutterLocalNotificationsPlugin,
    required this.sharedPreferences,
  });

  @override
  Future<bool> requestPermission() async {
    try {
      // Request Android permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      // Request iOS permissions
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSImplementation != null) {
        final bool? result = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result ?? false;
      }

      return false;
    } catch (e) {
      _logger.warning('Error requesting notification permission: $e');
      return false;
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      // Check Android permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.areNotificationsEnabled();
        return granted ?? false;
      }

      return true; // For iOS, we assume permission is granted if requested
    } catch (e) {
      _logger.warning('Error checking notification permission: $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      final bool hasPermission = await requestPermission();
      if (!hasPermission) {
        _logger.warning(
            'Notification permission not granted. Continuing with initialization...');
      }

      // Create notification channels for Android
      const AndroidNotificationChannel morningGreetingChannel =
          AndroidNotificationChannel(
        'morning_greeting',
        'Sapaan Pagi',
        description: 'Notifikasi sapaan pagi hari',
        importance: Importance.high,
      );

      const AndroidNotificationChannel checkoutReminderChannel =
          AndroidNotificationChannel(
        'checkout_reminder',
        'Pengingat Check-out',
        description: 'Notifikasi untuk mengingatkan check-out',
        importance: Importance.high,
      );

      const AndroidNotificationChannel approvalChannel =
          AndroidNotificationChannel(
        'approval_notification',
        'Notifikasi Persetujuan',
        description: 'Notifikasi untuk persetujuan jadwal',
        importance: Importance.high,
      );

      const AndroidNotificationChannel visitRealizationChannel =
          AndroidNotificationChannel(
        'visit_realization',
        'Realisasi Kunjungan',
        description: 'Notifikasi untuk realisasi kunjungan',
        importance: Importance.high,
      );

      // Create the channels
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(morningGreetingChannel);
      await androidPlugin?.createNotificationChannel(checkoutReminderChannel);
      await androidPlugin?.createNotificationChannel(approvalChannel);
      await androidPlugin?.createNotificationChannel(visitRealizationChannel);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) async {
          final String? payload = details.payload;
          if (payload != null) {
            _logger.info('Notification tapped with payload: $payload');
          }
        },
      );

      // Only schedule notifications if we have permission
      if (hasPermission) {
        // Get user data from SharedPreferences using the correct key
        final userDataString =
            sharedPreferences.getString(Constants.userDataKey);
        String userName = 'User';
        if (userDataString != null) {
          try {
            final Map<String, dynamic> userData = json.decode(userDataString);
            // The user data is stored with the UserModel structure
            userName = userData['name'] ?? 'User';
            _logger.info('Retrieved user name: $userName');
          } catch (e) {
            _logger.warning('Error parsing user data: $e');
          }
        } else {
          _logger.warning('No user data found in SharedPreferences');
        }

        // Always schedule morning greeting with user's name
        await scheduleMorningGreeting(userName);

        // Schedule other notifications based on settings
        final settings = await getNotificationSettings();
        if (settings.isCheckoutReminderEnabled) {
          await schedulePeriodicCheckoutReminder();
        }
      }

      _logger.info('Notification service initialized successfully');
    } catch (e) {
      _logger.severe('Error initializing notifications: $e');
      // Don't throw CacheException, just log the error
    }
  }

  @override
  Future<void> scheduleMorningGreeting(String userName) async {
    try {
      final settings = await getNotificationSettings();
      final timeParts = settings.morningGreetingTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1000, // Unique ID for morning greeting
        'Selamat Pagi!',
        'Selamat pagi $userName, semoga hari ini menyenangkan!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'morning_greeting',
            'Sapaan Pagi',
            channelDescription: 'Notifikasi sapaan pagi hari',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logger
          .info('Scheduled morning greeting for ${scheduledDate.toString()}');
    } catch (e) {
      _logger.severe('Error scheduling morning greeting: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> schedulePeriodicCheckoutReminder() async {
    try {
      final settings = await getNotificationSettings();
      if (!settings.isCheckoutReminderEnabled) {
        _logger.info('Checkout reminder is disabled in settings');
        return;
      }

      final timeParts = settings.checkoutReminderStartTime.split(':');
      final startHour = int.parse(timeParts[0]);
      final startMinute = int.parse(timeParts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Schedule reminders every X hours
      for (int i = 0; i < 24 ~/ settings.checkoutReminderInterval; i++) {
        final reminderTime = scheduledDate
            .add(Duration(hours: i * settings.checkoutReminderInterval));

        if (reminderTime.hour >= 8 && reminderTime.hour <= 20) {
          // Only between 8 AM and 8 PM
          await flutterLocalNotificationsPlugin.zonedSchedule(
            2000 + i, // Unique ID for each periodic reminder
            'Pengingat Check-out',
            'Jangan lupa untuk melakukan check-out jika sudah selesai kunjungan.',
            reminderTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'checkout_reminder',
                'Pengingat Check-out',
                channelDescription: 'Notifikasi untuk mengingatkan check-out',
                importance: Importance.high,
                priority: Priority.high,
                enableVibration: true,
                playSound: true,
              ),
              iOS: DarwinNotificationDetails(
                sound: 'default.wav',
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );

          _logger.info(
              'Scheduled checkout reminder for ${reminderTime.toString()}');
        }
      }
    } catch (e) {
      _logger.severe('Error scheduling periodic checkout reminder: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> showApprovalNotification(int scheduleId, String message) async {
    try {
      final bool hasPermission = await checkPermission();
      if (!hasPermission) {
        _logger.warning('Notification permission not granted');
        throw CacheException();
      }

      final settings = await getNotificationSettings();
      if (!settings.isApprovalNotificationEnabled) {
        _logger.info('Approval notification is disabled in settings');
        return;
      }

      await flutterLocalNotificationsPlugin.show(
        scheduleId,
        'Persetujuan Jadwal',
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'approval_notification',
            'Notifikasi Persetujuan',
            channelDescription: 'Notifikasi untuk persetujuan jadwal',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      _logger.info('Successfully showed approval notification: $message');
    } catch (e) {
      _logger.severe('Error showing approval notification: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> showVisitRealizationNotification(
    int scheduleId,
    String message,
  ) async {
    try {
      final bool hasPermission = await checkPermission();
      if (!hasPermission) {
        _logger.warning('Notification permission not granted');
        throw CacheException();
      }

      final settings = await getNotificationSettings();
      if (!settings.isVisitRealizationEnabled) {
        _logger.info('Visit realization notification is disabled in settings');
        return;
      }

      await flutterLocalNotificationsPlugin.show(
        scheduleId,
        'Realisasi Kunjungan',
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'visit_realization',
            'Realisasi Kunjungan',
            channelDescription: 'Notifikasi untuk realisasi kunjungan',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      _logger
          .info('Successfully showed visit realization notification: $message');
    } catch (e) {
      _logger.severe('Error showing visit realization notification: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> cancelNotification(int scheduleId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(scheduleId);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    try {
      final jsonString = sharedPreferences.getString(notificationSettingsKey);
      if (jsonString != null) {
        return NotificationSettingsModel.fromJson(json.decode(jsonString));
      }
      return const NotificationSettingsModel(
        isCheckoutReminderEnabled: true,
        isApprovalNotificationEnabled: true,
        isVisitRealizationEnabled: true,
        morningGreetingTime: '08:00',
        checkoutReminderStartTime: '08:00',
        checkoutReminderInterval: 2,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveNotificationSettings(
      NotificationSettingsModel settings) async {
    try {
      await sharedPreferences.setString(
        notificationSettingsKey,
        json.encode(settings.toJson()),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> showTestNotification() async {
    try {
      // Get user data from SharedPreferences using the correct key
      final userDataString = sharedPreferences.getString(Constants.userDataKey);
      String userName = 'User';
      if (userDataString != null) {
        try {
          final Map<String, dynamic> userData = json.decode(userDataString);
          // The user data is stored with the UserModel structure
          userName = userData['name'] ?? 'User';
          _logger.info('Retrieved user name for test notification: $userName');
        } catch (e) {
          _logger.warning('Error parsing user data for test notification: $e');
        }
      } else {
        _logger.warning(
            'No user data found in SharedPreferences for test notification');
      }

      // Test morning greeting
      await flutterLocalNotificationsPlugin.show(
        9998,
        'Test Sapaan Pagi',
        'Selamat pagi $userName, ini adalah test notifikasi sapaan pagi.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'morning_greeting',
            'Sapaan Pagi',
            channelDescription: 'Notifikasi sapaan pagi hari',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      // Test checkout reminder
      await flutterLocalNotificationsPlugin.show(
        9999,
        'Test Pengingat Check-out',
        'Ini adalah test notifikasi pengingat check-out yang akan muncul setiap 2 jam.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'checkout_reminder',
            'Pengingat Check-out',
            channelDescription: 'Notifikasi untuk mengingatkan check-out',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      _logger.severe('Error showing test notification: $e');
      throw CacheException();
    }
  }
}
