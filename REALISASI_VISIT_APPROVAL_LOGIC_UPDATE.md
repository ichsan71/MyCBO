# Realisasi Visit Approval Logic Update

## Overview

Update logika approval pada fitur Realisasi Visit untuk mengubah aturan kapan user dapat melakukan approval.

## Perubahan Logika

### Logika Sebelumnya

- User dapat approve jadwal dari hari sebelumnya (kemarin)
- Deadline approval: sebelum jam 12.00 siang hari ini
- Tidak ada pembatasan pada tanggal visit

### Logika Baru

- User **hanya dapat approve jadwal hari ini**
- Deadline approval: **sampai jam 12.00 siang besok**
- Setelah deadline, otomatis berganti ke jadwal hari berikutnya

## Implementasi

### File yang Dimodifikasi

- `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

### Fungsi yang Diubah

```dart
bool _canApproveSchedule(RealisasiVisitDetail schedule) {
  // ... validasi existing ...

  // Cek apakah visitDate adalah hari ini
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime visitDateOnly = DateTime(visitDate.year, visitDate.month, visitDate.day);

  if (!visitDateOnly.isAtSameMomentAs(today)) {
    // Hanya jadwal hari ini yang dapat di-approve
    return false;
  }

  // Deadline adalah jam 12 siang BESOK untuk jadwal hari ini
  final DateTime deadline = DateTime(now.year, now.month, now.day + 1, 12, 0);
  return now.isBefore(deadline);
}
```

## Skenario Penggunaan

### Skenario 1: Approval Normal

- **Tanggal**: 2025-01-15 09:00 (Pagi)
- **Jadwal Visit**: 2025-01-15 (Hari ini)
- **Status**: "Done"
- **Result**: ✅ Dapat di-approve (sebelum deadline besok jam 12)

### Skenario 2: Lewat Deadline

- **Tanggal**: 2025-01-16 13:00 (Siang)
- **Jadwal Visit**: 2025-01-15 (Kemarin)
- **Status**: "Done"
- **Result**: ❌ Tidak dapat di-approve (jadwal bukan hari ini)

### Skenario 3: Jadwal Hari Ini, Sebelum Deadline

- **Tanggal**: 2025-01-15 23:30 (Malam)
- **Jadwal Visit**: 2025-01-15 (Hari ini)
- **Status**: "Done"
- **Result**: ✅ Dapat di-approve (masih sebelum deadline besok jam 12)

### Skenario 4: Setelah Deadline

- **Tanggal**: 2025-01-16 12:30 (Siang)
- **Jadwal Visit**: 2025-01-15 (Kemarin)
- **Status**: "Done"
- **Result**: ❌ Tidak dapat di-approve (lewat deadline + bukan hari ini)

## Validasi yang Tetap Berlaku

1. **Status Approval**: Jadwal yang sudah di-approve/reject tidak bisa di-approve lagi
2. **Status Realisasi**: Hanya jadwal dengan status "Done" yang bisa di-approve
3. **Error Handling**: Parsing tanggal yang gagal akan mengembalikan `false`

## Testing Checklist

- [ ] Jadwal hari ini dengan status "Done" dapat di-approve sebelum deadline
- [ ] Jadwal kemarin tidak dapat di-approve
- [ ] Jadwal besok tidak dapat di-approve
- [ ] Approval tidak bisa dilakukan setelah deadline (jam 12 siang besok)
- [ ] Jadwal dengan status "Not Done" tidak dapat di-approve
- [ ] Jadwal yang sudah di-approve tidak muncul di daftar pending

## Impact Analysis

### Positive Impact

- **Clearer Timeline**: User tahu kapan harus approve jadwal hari ini
- **Better Organization**: Approval terfokus pada jadwal hari ini
- **Extended Window**: Deadline sampai besok jam 12 memberikan waktu lebih

### Considerations

- User perlu aware dengan perubahan deadline approval
- Jadwal kemarin yang tertunda tidak bisa di-approve lagi

## Date: 2025-01-15

## Updated by: System
