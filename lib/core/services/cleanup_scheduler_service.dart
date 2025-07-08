import 'dart:async';
import 'dart:isolate';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'photo_storage_service.dart';

class CleanupSchedulerService {
  static const String _tag = 'CleanupSchedulerService';
  static const String _isScheduledKey = 'cleanup_scheduled';

  static Timer? _cleanupTimer;
  static bool _isInitialized = false;

  /// Initialize the cleanup scheduler
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Logger.info(_tag, 'Initializing cleanup scheduler...');

      // Calculate time until next 23:59
      final now = DateTime.now();
      final nextCleanup = DateTime(now.year, now.month, now.day, 23, 59);

      // If it's already past 23:59 today, schedule for tomorrow
      final targetTime = nextCleanup.isBefore(now)
          ? nextCleanup.add(const Duration(days: 1))
          : nextCleanup;

      final duration = targetTime.difference(now);

      Logger.info(_tag, 'Next cleanup scheduled at: ${targetTime.toString()}');
      Logger.info(_tag, 'Time until cleanup: ${duration.toString()}');

      // Schedule the cleanup
      _cleanupTimer = Timer(duration, () {
        _performCleanup();
        // Schedule next cleanup (24 hours later)
        _scheduleNextCleanup();
      });

      _isInitialized = true;
      Logger.success(_tag, 'Cleanup scheduler initialized successfully');
    } catch (e) {
      Logger.error(_tag, 'Error initializing cleanup scheduler: $e');
    }
  }

  /// Manually trigger cleanup (for testing or immediate cleanup)
  static Future<void> triggerCleanup() async {
    Logger.info(_tag, 'Manual cleanup triggered');
    await _performCleanup();
  }

  /// Stop the cleanup scheduler
  static void stop() {
    Logger.info(_tag, 'Stopping cleanup scheduler...');
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _isInitialized = false;
  }

  /// Check if cleanup is scheduled
  static bool get isScheduled => _cleanupTimer?.isActive ?? false;

  /// Get time until next cleanup
  static Duration? get timeUntilNextCleanup {
    if (_cleanupTimer == null || !_cleanupTimer!.isActive) return null;

    final now = DateTime.now();
    final nextCleanup = DateTime(now.year, now.month, now.day, 23, 59);
    final targetTime = nextCleanup.isBefore(now)
        ? nextCleanup.add(const Duration(days: 1))
        : nextCleanup;

    return targetTime.difference(now);
  }

  /// Private method to perform cleanup
  static Future<void> _performCleanup() async {
    try {
      Logger.info(_tag, 'Performing scheduled cleanup...');

      final prefs = await SharedPreferences.getInstance();
      final photoService = PhotoStorageService(prefs);

      await photoService.autoCleanup();

      Logger.success(_tag, 'Scheduled cleanup completed');
    } catch (e) {
      Logger.error(_tag, 'Error during scheduled cleanup: $e');
    }
  }

  /// Private method to schedule next cleanup (24 hours later)
  static void _scheduleNextCleanup() {
    Logger.info(_tag, 'Scheduling next cleanup in 24 hours...');

    _cleanupTimer = Timer(const Duration(days: 1), () {
      _performCleanup();
      _scheduleNextCleanup();
    });
  }

  /// Initialize cleanup on app startup with background isolate support
  static Future<void> initializeWithBackgroundSupport() async {
    try {
      Logger.info(_tag, 'Initializing cleanup with background support...');

      // Mark that cleanup is scheduled
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isScheduledKey, true);

      // Initialize regular cleanup
      await initialize();

      // Check if we need immediate cleanup (app was closed and reopened)
      await _checkAndPerformMissedCleanup();
    } catch (e) {
      Logger.error(
          _tag, 'Error initializing cleanup with background support: $e');
    }
  }

  /// Check if cleanup was missed while app was closed
  static Future<void> _checkAndPerformMissedCleanup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCleanup = prefs.getString('last_cleanup_date');
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (lastCleanup != todayString) {
        Logger.info(_tag, 'Missed cleanup detected, performing now...');
        await _performCleanup();
      }
    } catch (e) {
      Logger.error(_tag, 'Error checking missed cleanup: $e');
    }
  }

  /// Reset scheduler (useful for testing)
  static Future<void> reset() async {
    stop();
    _isInitialized = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isScheduledKey);
    Logger.info(_tag, 'Cleanup scheduler reset');
  }
}
