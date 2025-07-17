# Perbaikan Status Filter "Tidak Selesai" pada Detail Realisasi Visit

## Masalah yang Ditemukan

Terdapat inkonsistensi antara logika filter dan tampilan status pada halaman Detail Realisasi Visit:

1. **Filter Status**: Menggunakan `_getScheduleStatusCategory()` yang mengembalikan "Tidak Selesai" untuk status "not done"
2. **Tampilan Status di Card**: Masih menggunakan `schedule.statusTerrealisasi` langsung (menampilkan "Pending")
3. **Status Badge**: Menggunakan logika lama yang tidak konsisten dengan filter

## Perbaikan yang Dilakukan

### 1. Konsistensi Tampilan Status di Card

**File:** `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`
**Line:** ~1138

**Sebelum:**

```dart
Text(
  schedule.statusTerrealisasi,  // Menampilkan "Pending" untuk "not done"
  // ...
)
```

**Sesudah:**

```dart
Text(
  _getScheduleStatusCategory(schedule),  // Menampilkan "Tidak Selesai" untuk "not done"
  // ...
)
```

### 2. Konsistensi Status Badge

**File:** `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`
**Function:** `_buildStatusBadge()`

**Sebelum:**

```dart
if (schedule.realisasiVisitApproved == null) {
  if (schedule.statusTerrealisasi.toLowerCase() == 'not done') {
    statusText = 'Pending';  // ❌ Tidak konsisten
  }
}
```

**Sesudah:**

```dart
final String statusCategory = _getScheduleStatusCategory(schedule);
switch (statusCategory) {
  case 'Tidak Selesai':
    statusText = 'Tidak Selesai';  // ✅ Konsisten
    break;
}
```

## Logika Status yang Konsisten

### Fungsi `_getScheduleStatusCategory()`

```dart
String _getScheduleStatusCategory(RealisasiVisitDetail schedule) {
  final status = schedule.statusTerrealisasi.toLowerCase().trim();
  final isApproved = schedule.realisasiVisitApproved != null;

  // Selesai: status "done" dan sudah disetujui
  if (status == 'done' && isApproved) {
    return 'Selesai';
  }

  // Pending: status "done" tapi belum disetujui
  if (status == 'done' && !isApproved) {
    return 'Pending';
  }

  // Tidak Selesai: status "not done" atau status lainnya
  if (status == 'not done' || status == 'notdone' || status == 'not_done') {
    return 'Tidak Selesai';
  }

  // Default untuk status lainnya
  return 'Tidak Selesai';
}
```

## Hasil Perbaikan

### ✅ Konsistensi Tercapai

- **Filter "Tidak Selesai"** sekarang menampilkan jadwal dengan status "not done"
- **Tampilan status di card** konsisten dengan filter
- **Status badge** konsisten dengan logika filter
- **Tidak ada perubahan logika/fungsi/flow** fitur lainnya

### ✅ Status Mapping yang Benar

| Status API            | Filter Category | Tampilan Card | Status Badge  |
| --------------------- | --------------- | ------------- | ------------- |
| "Done" + Approved     | Selesai         | Selesai       | Disetujui     |
| "Done" + Not Approved | Pending         | Pending       | Menunggu      |
| "Not Done"            | Tidak Selesai   | Tidak Selesai | Tidak Selesai |

## Testing Points

1. ✅ Filter "Tidak Selesai" menampilkan jadwal dengan status "not done"
2. ✅ Tampilan status di card konsisten dengan filter
3. ✅ Status badge menampilkan label yang benar
4. ✅ Filter "Selesai" dan "Pending" tetap berfungsi normal
5. ✅ Search functionality tidak terpengaruh
6. ✅ Approval/rejection flow tidak berubah

## Impact

- **User Experience**: Konsistensi tampilan status di seluruh halaman
- **Functionality**: Filter status bekerja dengan benar
- **Maintainability**: Logika status terpusat di satu fungsi
- **No Breaking Changes**: Semua fitur lain tetap berfungsi normal
