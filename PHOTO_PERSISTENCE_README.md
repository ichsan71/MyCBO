# Photo Persistence System untuk Check-in/Check-out

Sistem ini memungkinkan foto yang diambil saat check-in dan check-out tersimpan secara persisten dan dapat dipulihkan meskipun aplikasi ditutup atau navigasi kembali.

## Fitur Utama

✅ **Persistent Storage**: Foto tersimpan secara lokal di device storage
✅ **Auto Restore**: Foto dan data form dipulihkan otomatis saat form dibuka kembali
✅ **Auto Cleanup**: Foto dihapus otomatis setiap jam 23:59
✅ **Success Cleanup**: Foto dihapus otomatis setelah berhasil check-in/check-out
✅ **Data Integrity**: Verifikasi file masih ada saat restore
✅ **Debounced Save**: Optimasi penyimpanan dengan debouncing untuk perubahan note

## Cara Kerja

### 1. Penyimpanan Foto

- Saat foto diambil dari kamera, foto dikompres dan disimpan ke direktori aplikasi
- Metadata foto (path, timestamp, note, status) disimpan ke SharedPreferences
- File foto disimpan dengan nama unik: `{type}_{scheduleId}_{timestamp}.jpg`

### 2. Restore Data

- Saat form check-in/check-out dibuka, sistem otomatis mencari data tersimpan
- Jika ditemukan, foto dan form data dipulihkan
- Jika file foto tidak ada, metadata dihapus otomatis

### 3. Auto Cleanup

- **Harian**: Setiap jam 23:59, foto dari hari sebelumnya dihapus otomatis
- **Success**: Setelah berhasil check-in/check-out, foto untuk schedule tersebut dihapus
- **Integrity Check**: Cleanup juga membersihkan metadata untuk file yang tidak ada

## Struktur File

```
lib/core/services/
├── photo_storage_service.dart          # Service utama untuk penyimpanan foto
├── cleanup_scheduler_service.dart      # Scheduler untuk auto cleanup
└── photo_cleanup_test_utils.dart       # Utility untuk testing dan debug
```

## Cara Penggunaan

### Otomatis (Sudah Terintegrasi)

Sistem sudah terintegrasi dengan:

- `CheckinForm` - Form check-in
- `CheckoutForm` - Form check-out
- `main.dart` - Inisialisasi scheduler
- `injection_container.dart` - Dependency injection

### Manual Testing/Debug

```dart
import 'package:test_cbo/core/services/photo_cleanup_test_utils.dart';

// Test storage functionality
await PhotoCleanupTestUtils.testPhotoStorage();

// Test scheduler
await PhotoCleanupTestUtils.testCleanupScheduler();

// Print status
await PhotoCleanupTestUtils.printDetailedStatus();

// Force cleanup for testing
await PhotoCleanupTestUtils.forceCleanupForTesting();
```

## Lokasi Penyimpanan

### Foto

```
/data/data/com.example.test_cbo/app_flutter/check_photos/
├── checkin_123_1640995200000.jpg
├── checkout_123_1640998800000.jpg
└── ...
```

### Metadata (SharedPreferences)

- Key: `check_in_out_photos`
- Format: JSON array dengan data foto

## Konfigurasi

### PhotoStorageService

```dart
class PhotoStorageService {
  static const String _photoDataKey = 'check_in_out_photos';
  static const String _lastCleanupKey = 'last_cleanup_date';
  // ...
}
```

### CleanupSchedulerService

```dart
class CleanupSchedulerService {
  // Cleanup time: 23:59 daily
  final targetTime = DateTime(now.year, now.month, now.day, 23, 59);
  // ...
}
```

## Error Handling

- **File Not Found**: Metadata dihapus otomatis jika file tidak ditemukan
- **Permission Error**: Logged dan graceful fallback
- **Storage Full**: Error logged, tidak crash aplikasi
- **Scheduler Error**: Error logged, scheduler tetap berjalan

## Monitoring dan Debug

### Status Checker

```dart
final status = await PhotoCleanupTestUtils.getCleanupStatus();
print(status); // Detailed status information
```

### Logger Integration

Semua operasi logged dengan tag yang jelas:

- `PhotoStorageService`
- `CleanupSchedulerService`
- `PhotoCleanupTestUtils`

## Performance Considerations

1. **Debouncing**: Note saving menggunakan debouncing 1 detik
2. **Compression**: Foto dikompres ke lebar maksimal 800px, kualitas 70%
3. **Lazy Loading**: Service diinisialisasi di critical dependencies
4. **Background Cleanup**: Cleanup berjalan di background tanpa memblokir UI

## Dependencies

- `shared_preferences`: Menyimpan metadata
- `path_provider`: Mendapatkan direktori aplikasi
- `intl`: Format tanggal dan waktu

## Troubleshooting

### Foto Tidak Tersimpan

1. Periksa permission storage
2. Periksa available storage space
3. Lihat log untuk error messages

### Cleanup Tidak Berjalan

1. Periksa apakah scheduler aktif: `CleanupSchedulerService.isScheduled`
2. Periksa waktu cleanup: `CleanupSchedulerService.timeUntilNextCleanup`
3. Force trigger: `CleanupSchedulerService.triggerCleanup()`

### Data Tidak Dipulihkan

1. Periksa metadata: `PhotoCleanupTestUtils.getCleanupStatus()`
2. Periksa apakah file masih ada
3. Periksa schedule ID yang sama

## Version History

- **v1.0.0**: Initial implementation dengan basic storage dan cleanup
- Auto cleanup harian jam 23:59
- Success cleanup setelah check-in/check-out berhasil
- Integration dengan existing forms
