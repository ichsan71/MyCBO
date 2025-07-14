# Filter Status pada Detail Realisasi Visit

## Overview

Fitur filter status telah ditambahkan pada halaman detail realisasi visit untuk memudahkan atasan dalam melihat dan memfilter jadwal berdasarkan status penyelesaian.

## Status Categories

### 1. Selesai

- **Kondisi**: Status terrealisasi = "Done" DAN sudah disetujui realisasi (realisasiVisitApproved tidak null)
- **Warna**: Hijau (Green)
- **Icon**: `check_circle_outline`
- **Deskripsi**: Jadwal yang telah selesai dilaksanakan dan sudah mendapat persetujuan

### 2. Pending

- **Kondisi**: Status terrealisasi = "Done" TAPI belum disetujui (realisasiVisitApproved null)
- **Warna**: Orange (Orange)
- **Icon**: `pending_outlined`
- **Deskripsi**: Jadwal yang sudah selesai dilaksanakan tapi masih menunggu persetujuan

### 3. Tidak Selesai

- **Kondisi**:
  - Status terrealisasi = "Not Done" ATAU
  - Belum ada check-in dan check-out (keduanya kosong)
- **Warna**: Merah (Red)
- **Icon**: `cancel_outlined`
- **Deskripsi**: Jadwal yang belum selesai dilaksanakan

## UI Components

### Filter Chips

- Ditambahkan row kedua filter chips khusus untuk status
- Setiap chip memiliki warna sesuai dengan kategori status
- Filter dapat dikombinasikan dengan pencarian teks

### Status Badge

- Badge status pada setiap card jadwal diperbarui menggunakan kategori status baru
- Menggunakan warna dan icon yang konsisten dengan filter chips

### Search Result Info

- Menampilkan informasi filter yang aktif
- Mendukung kombinasi filter pencarian dan filter status
- Responsive text dengan overflow handling

### No Results State

- Pesan yang disesuaikan berdasarkan jenis filter yang aktif
- Button reset yang membersihkan semua filter

## Technical Implementation

### Helper Function

```dart
String _getScheduleStatusCategory(RealisasiVisitDetail schedule) {
  final status = schedule.statusTerrealisasi.toLowerCase().trim();
  final hasCheckIn = schedule.checkin != null && schedule.checkin!.isNotEmpty;
  final hasCheckOut = schedule.checkout != null && schedule.checkout!.isNotEmpty;
  final isApproved = schedule.realisasiVisitApproved != null;

  // Tidak Selesai: status "not done" atau belum check-in/check-out
  if (status == 'not done' || status == 'notdone' || status == 'not_done' ||
      (!hasCheckIn && !hasCheckOut)) {
    return 'Tidak Selesai';
  }

  // Selesai: status "done" dan sudah disetujui
  if (status == 'done' && isApproved) {
    return 'Selesai';
  }

  // Pending: status "done" tapi belum disetujui
  if (status == 'done' && !isApproved) {
    return 'Pending';
  }

  return 'Pending';
}
```

### Filter Logic

- Filter status diterapkan terlebih dahulu sebelum filter pencarian
- Kombinasi filter menggunakan operator AND
- Dukungan untuk multiple criteria filtering

### State Management

- `_selectedStatusFilter`: Menyimpan filter status yang aktif
- Terintegrasi dengan state management yang sudah ada
- Tidak mempengaruhi fungsi approval/rejection

## User Experience

### Improvements

1. **Visual Clarity**: Status yang jelas dengan warna dan icon yang konsisten
2. **Easy Filtering**: Filter cepat berdasarkan status tanpa perlu scrolling
3. **Combined Search**: Kombinasi pencarian teks dan filter status
4. **Clear Feedback**: Informasi hasil filter yang detail
5. **Quick Reset**: Reset filter dengan satu tombol

### Workflow Integration

- Tidak mengubah alur approval yang sudah ada
- Kompatibel dengan bulk approval functionality
- Mendukung select all pada kategori yang dapat disetujui

## Files Modified

- `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

## Testing Points

1. Filter berdasarkan masing-masing status category
2. Kombinasi filter status dengan pencarian teks
3. Reset filter functionality
4. Visual consistency pada berbagai theme
5. Performance dengan data banyak
6. Responsive behavior pada berbagai ukuran layar

## Notes

- Fitur ini tidak mengubah logic approval yang sudah ada
- Status category calculation mengikuti business logic yang sudah ditetapkan
- UI pattern mengikuti design system yang sudah ada di aplikasi
