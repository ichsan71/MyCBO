import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'photo_storage_service.dart';
import 'cleanup_scheduler_service.dart';

/// Utility class for testing and debugging photo cleanup functionality
class PhotoCleanupTestUtils {
  static const String _tag = 'PhotoCleanupTestUtils';

  /// Test photo storage functionality
  static Future<void> testPhotoStorage() async {
    try {
      Logger.info(_tag, 'Starting photo storage test...');

      final prefs = await SharedPreferences.getInstance();
      final photoService = PhotoStorageService(prefs);

      // Test saving a dummy photo
      final savedPath = await photoService.savePhoto(
        scheduleId: 999,
        originalPhotoPath: '/dummy/path/test.jpg',
        type: 'test',
        timestamp: '01/01/2024 12:00:00',
        note: 'Test note',
      );

      Logger.info(_tag, 'Saved test photo: $savedPath');

      // Test retrieving photo data
      final photoData = await photoService.getPhotoData(999, 'test');
      if (photoData != null) {
        Logger.info(_tag, 'Retrieved photo data: ${photoData.toJson()}');
      }

      // Test cleanup
      await photoService.deletePhotoData(999);
      Logger.success(_tag, 'Photo storage test completed successfully');
    } catch (e) {
      Logger.error(_tag, 'Error in photo storage test: $e');
    }
  }

  /// Test cleanup scheduler functionality
  static Future<void> testCleanupScheduler() async {
    try {
      Logger.info(_tag, 'Starting cleanup scheduler test...');

      // Reset scheduler
      await CleanupSchedulerService.reset();

      // Initialize scheduler
      await CleanupSchedulerService.initialize();

      Logger.info(
          _tag, 'Scheduler active: ${CleanupSchedulerService.isScheduled}');

      final timeUntilNext = CleanupSchedulerService.timeUntilNextCleanup;
      if (timeUntilNext != null) {
        Logger.info(
            _tag, 'Time until next cleanup: ${timeUntilNext.toString()}');
      }

      Logger.success(_tag, 'Cleanup scheduler test completed successfully');
    } catch (e) {
      Logger.error(_tag, 'Error in cleanup scheduler test: $e');
    }
  }

  /// Get status of photo cleanup system
  static Future<Map<String, dynamic>> getCleanupStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoService = PhotoStorageService(prefs);

      // Get all photos from metadata
      final allPhotos = await photoService.getAllPhotoData();

      return {
        'scheduler_active': CleanupSchedulerService.isScheduled,
        'time_until_next_cleanup':
            CleanupSchedulerService.timeUntilNextCleanup?.toString(),
        'total_saved_photos': allPhotos.length,
        'photos_by_type': _groupPhotosByType(allPhotos),
        'photos_by_schedule': _groupPhotosBySchedule(allPhotos),
        'last_cleanup_date': prefs.getString('last_cleanup_date'),
      };
    } catch (e) {
      Logger.error(_tag, 'Error getting cleanup status: $e');
      return {'error': e.toString()};
    }
  }

  /// Force trigger cleanup for testing
  static Future<void> forceCleanupForTesting() async {
    try {
      Logger.info(_tag, 'Force triggering cleanup for testing...');
      await CleanupSchedulerService.triggerCleanup();
      Logger.success(_tag, 'Force cleanup completed');
    } catch (e) {
      Logger.error(_tag, 'Error in force cleanup: $e');
    }
  }

  /// Print detailed status to console for debugging
  static Future<void> printDetailedStatus() async {
    try {
      final status = await getCleanupStatus();

      developer.log('=== PHOTO CLEANUP STATUS ===', name: _tag);
      developer.log('Scheduler Active: ${status['scheduler_active']}',
          name: _tag);
      developer.log(
          'Time Until Next Cleanup: ${status['time_until_next_cleanup'] ?? 'N/A'}',
          name: _tag);
      developer.log('Total Saved Photos: ${status['total_saved_photos']}',
          name: _tag);
      developer.log('Photos by Type: ${status['photos_by_type']}', name: _tag);
      developer.log('Photos by Schedule: ${status['photos_by_schedule']}',
          name: _tag);
      developer.log(
          'Last Cleanup Date: ${status['last_cleanup_date'] ?? 'Never'}',
          name: _tag);
      developer.log('===============================', name: _tag);
    } catch (e) {
      Logger.error(_tag, 'Error printing status: $e');
    }
  }

  /// Group photos by type for statistics
  static Map<String, int> _groupPhotosByType(List<PhotoData> photos) {
    final Map<String, int> result = {};
    for (final photo in photos) {
      result[photo.type] = (result[photo.type] ?? 0) + 1;
    }
    return result;
  }

  /// Group photos by schedule for statistics
  static Map<String, int> _groupPhotosBySchedule(List<PhotoData> photos) {
    final Map<String, int> result = {};
    for (final photo in photos) {
      final key = 'schedule_${photo.scheduleId}';
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }
}
