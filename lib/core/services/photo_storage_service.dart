import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../utils/logger.dart';

class PhotoStorageService {
  static const String _tag = 'PhotoStorageService';
  static const String _photoDataKey = 'check_in_out_photos';
  static const String _lastCleanupKey = 'last_cleanup_date';

  final SharedPreferences _prefs;

  PhotoStorageService(this._prefs);

  /// Save photo data for check-in or check-out
  Future<String?> savePhoto({
    required int scheduleId,
    required String originalPhotoPath,
    required String type, // 'checkin' or 'checkout'
    String? timestamp,
    String? note,
    String? status,
  }) async {
    try {
      Logger.info(_tag, 'Saving photo for schedule $scheduleId, type: $type');

      // Create application documents directory if not exists
      final appDir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${appDir.path}/check_photos');
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      // Generate unique filename
      final now = DateTime.now();
      final filename =
          '${type}_${scheduleId}_${now.millisecondsSinceEpoch}.jpg';
      final savedPhotoPath = '${photoDir.path}/$filename';

      // Copy photo to permanent location
      final originalFile = File(originalPhotoPath);
      if (await originalFile.exists()) {
        await originalFile.copy(savedPhotoPath);
        Logger.info(_tag, 'Photo copied to: $savedPhotoPath');
      } else {
        Logger.error(_tag, 'Original photo file not found: $originalPhotoPath');
        return null;
      }

      // Save photo metadata
      final photoData = PhotoData(
        scheduleId: scheduleId,
        type: type,
        photoPath: savedPhotoPath,
        timestamp: timestamp ?? DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
        note: note,
        status: status,
        createdAt: now,
      );

      await _savePhotoMetadata(photoData);

      return savedPhotoPath;
    } catch (e) {
      Logger.error(_tag, 'Error saving photo: $e');
      return null;
    }
  }

  /// Get saved photo data for specific schedule and type
  Future<PhotoData?> getPhotoData(int scheduleId, String type) async {
    try {
      final allPhotos = await _getAllPhotoData();
      return allPhotos
              .firstWhere(
                (photo) => photo.scheduleId == scheduleId && photo.type == type,
                orElse: () => PhotoData.empty(),
              )
              .isEmpty
          ? null
          : allPhotos.firstWhere(
              (photo) => photo.scheduleId == scheduleId && photo.type == type,
            );
    } catch (e) {
      Logger.error(_tag, 'Error getting photo data: $e');
      return null;
    }
  }

  /// Delete photo data for specific schedule
  Future<void> deletePhotoData(int scheduleId) async {
    try {
      Logger.info(_tag, 'Deleting photo data for schedule: $scheduleId');

      final allPhotos = await _getAllPhotoData();
      final photosToDelete =
          allPhotos.where((photo) => photo.scheduleId == scheduleId).toList();

      // Delete physical files
      for (final photo in photosToDelete) {
        final file = File(photo.photoPath);
        if (await file.exists()) {
          await file.delete();
          Logger.info(_tag, 'Deleted photo file: ${photo.photoPath}');
        }
      }

      // Remove from metadata
      final remainingPhotos =
          allPhotos.where((photo) => photo.scheduleId != scheduleId).toList();
      await _saveAllPhotoData(remainingPhotos);

      Logger.success(
          _tag, 'Successfully deleted photo data for schedule: $scheduleId');
    } catch (e) {
      Logger.error(_tag, 'Error deleting photo data: $e');
    }
  }

  /// Check if photo exists for schedule and type
  Future<bool> hasPhoto(int scheduleId, String type) async {
    final photoData = await getPhotoData(scheduleId, type);
    if (photoData == null) return false;

    final file = File(photoData.photoPath);
    return await file.exists();
  }

  /// Auto cleanup old photos (called daily at 23:59)
  Future<void> autoCleanup() async {
    try {
      Logger.info(_tag, 'Starting auto cleanup...');

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final lastCleanup = _prefs.getString(_lastCleanupKey);

      // Check if already cleaned today
      if (lastCleanup == today) {
        Logger.info(_tag, 'Already cleaned today, skipping...');
        return;
      }

      final allPhotos = await _getAllPhotoData();
      final photosToDelete = <PhotoData>[];

      // Delete photos older than 1 day or from previous days
      for (final photo in allPhotos) {
        final photoDate = DateFormat('yyyy-MM-dd').format(photo.createdAt);
        if (photoDate != today) {
          photosToDelete.add(photo);
        }
      }

      // Delete physical files
      for (final photo in photosToDelete) {
        final file = File(photo.photoPath);
        if (await file.exists()) {
          await file.delete();
          Logger.info(_tag, 'Auto-deleted photo: ${photo.photoPath}');
        }
      }

      // Update metadata
      final remainingPhotos = allPhotos.where((photo) {
        final photoDate = DateFormat('yyyy-MM-dd').format(photo.createdAt);
        return photoDate == today;
      }).toList();

      await _saveAllPhotoData(remainingPhotos);

      // Update last cleanup date
      await _prefs.setString(_lastCleanupKey, today);

      Logger.success(_tag,
          'Auto cleanup completed. Deleted ${photosToDelete.length} photos');
    } catch (e) {
      Logger.error(_tag, 'Error during auto cleanup: $e');
    }
  }

  /// Force cleanup all photos
  Future<void> forceCleanupAll() async {
    try {
      Logger.info(_tag, 'Force cleanup all photos...');

      final allPhotos = await _getAllPhotoData();

      // Delete all physical files
      for (final photo in allPhotos) {
        final file = File(photo.photoPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear all metadata
      await _saveAllPhotoData([]);

      Logger.success(_tag, 'Force cleanup completed');
    } catch (e) {
      Logger.error(_tag, 'Error during force cleanup: $e');
    }
  }

  /// Get all photo data (public method for testing/debugging)
  Future<List<PhotoData>> getAllPhotoData() async {
    return await _getAllPhotoData();
  }

  /// Private method to save photo metadata
  Future<void> _savePhotoMetadata(PhotoData photoData) async {
    final allPhotos = await _getAllPhotoData();

    // Remove existing photo with same schedule and type
    allPhotos.removeWhere((photo) =>
        photo.scheduleId == photoData.scheduleId &&
        photo.type == photoData.type);

    // Add new photo data
    allPhotos.add(photoData);

    await _saveAllPhotoData(allPhotos);
  }

  /// Private method to get all photo data from SharedPreferences
  Future<List<PhotoData>> _getAllPhotoData() async {
    try {
      final jsonString = _prefs.getString(_photoDataKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PhotoData.fromJson(json)).toList();
    } catch (e) {
      Logger.error(_tag, 'Error getting all photo data: $e');
      return [];
    }
  }

  /// Private method to save all photo data to SharedPreferences
  Future<void> _saveAllPhotoData(List<PhotoData> photos) async {
    try {
      final jsonList = photos.map((photo) => photo.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(_photoDataKey, jsonString);
    } catch (e) {
      Logger.error(_tag, 'Error saving all photo data: $e');
    }
  }
}

/// Data class for photo metadata
class PhotoData {
  final int scheduleId;
  final String type; // 'checkin' or 'checkout'
  final String photoPath;
  final String timestamp;
  final String? note;
  final String? status;
  final DateTime createdAt;

  PhotoData({
    required this.scheduleId,
    required this.type,
    required this.photoPath,
    required this.timestamp,
    this.note,
    this.status,
    required this.createdAt,
  });

  PhotoData.empty()
      : scheduleId = -1,
        type = '',
        photoPath = '',
        timestamp = '',
        note = null,
        status = null,
        createdAt = DateTime.now();

  bool get isEmpty => scheduleId == -1;

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'type': type,
      'photoPath': photoPath,
      'timestamp': timestamp,
      'note': note,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PhotoData.fromJson(Map<String, dynamic> json) {
    return PhotoData(
      scheduleId: json['scheduleId'],
      type: json['type'],
      photoPath: json['photoPath'],
      timestamp: json['timestamp'],
      note: json['note'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
