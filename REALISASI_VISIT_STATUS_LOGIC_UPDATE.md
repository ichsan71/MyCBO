# Update Logika Status Realisasi Visit

## Overview

Telah dilakukan update pada logika penentuan status realisasi visit sesuai dengan kriteria bisnis yang baru.

## Kriteria Status

### 1. Selesai

- **Kondisi**: `status_terrealisasi` = "Done" DAN `realisasi_visit_approved` tidak null
- **Warna**: Hijau (Green)
- **Deskripsi**: Jadwal yang telah selesai dilaksanakan dan sudah mendapat persetujuan

### 2. Pending

- **Kondisi**: `status_terrealisasi` = "Done" TAPI `realisasi_visit_approved` null
- **Warna**: Orange (Orange)
- **Deskripsi**: Jadwal yang sudah selesai dilaksanakan tapi masih menunggu persetujuan

### 3. Tidak Selesai

- **Kondisi**: `status_terrealisasi` = "Not Done" atau variasi lainnya
- **Warna**: Merah (Red)
- **Deskripsi**: Jadwal yang belum selesai dilaksanakan

## Files Modified

### 1. Detail Page

**File:** `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

**Fungsi:** `_getScheduleStatusCategory()`

```dart
String _getScheduleStatusCategory(RealisasiVisitDetail schedule) {
  final status = schedule.statusTerrealisasi.toLowerCase().trim();
  final isApproved = schedule.realisasiVisitApproved != null;

  // Selesai: status "done" dan sudah disetujui (realisasi_visit_approved tidak null)
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

### 2. Card Widget

**File:** `lib/features/realisasi_visit/presentation/widgets/realisasi_visit_card.dart`

**Perubahan pada perhitungan status:**

```dart
// Selesai: status "Done" dan sudah disetujui (realisasi_visit_approved tidak null)
final int totalSelesai = realisasiVisit.details
    .where((detail) =>
        detail.statusTerrealisasi.toLowerCase() == 'done' &&
        detail.realisasiVisitApproved != null)
    .length;

// Pending: status "Done" tapi belum disetujui
final int totalPending = realisasiVisit.details
    .where((detail) =>
        detail.statusTerrealisasi.toLowerCase() == 'done' &&
        detail.realisasiVisitApproved == null)
    .length;

// Tidak Selesai: status "Not Done" atau status lainnya
final int totalTidakSelesai = realisasiVisit.details
    .where((detail) =>
        detail.statusTerrealisasi.toLowerCase() == 'not done' ||
        detail.statusTerrealisasi.toLowerCase() == 'notdone' ||
        detail.statusTerrealisasi.toLowerCase() == 'not_done')
    .length;
```

## Perubahan Utama

1. **Kriteria Selesai**: Sekarang memerlukan BOTH `status_terrealisasi = "Done"` DAN `realisasi_visit_approved != null`
2. **Kriteria Pending**: Status "Done" tapi belum disetujui (`realisasi_visit_approved = null`)
3. **Kriteria Tidak Selesai**: Semua status "Not Done" atau variasi lainnya
4. **Case Insensitive**: Menggunakan `toLowerCase()` untuk menghindari masalah case sensitivity

## Impact

- Filter status di detail page akan bekerja sesuai kriteria baru
- Status indicators di card widget akan menampilkan jumlah yang akurat
- Konsistensi logika di seluruh aplikasi
- User experience yang lebih akurat dalam melihat status realisasi visit

## Testing Points

1. Verifikasi status "Selesai" hanya muncul untuk jadwal dengan status "Done" dan sudah disetujui
2. Verifikasi status "Pending" muncul untuk jadwal dengan status "Done" tapi belum disetujui
3. Verifikasi status "Tidak Selesai" muncul untuk jadwal dengan status "Not Done"
4. Test case sensitivity dengan berbagai variasi penulisan status
5. Verifikasi filter status bekerja dengan benar di detail page
