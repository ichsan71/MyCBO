# Fitur Informasi Jadwal Melewati Batas Approval

## Overview

Fitur baru telah ditambahkan untuk menampilkan informasi jadwal realisasi visit yang telah melewati batas waktu approval. Fitur ini membantu atasan untuk dengan cepat mengidentifikasi jadwal yang tidak dapat disetujui lagi karena telah melewati deadline.

## Kriteria Jadwal Melewati Batas

### 1. Jadwal yang Diperiksa

- **Status**: "Done" (sudah selesai dilaksanakan)
- **Approval**: Belum disetujui (`realisasiVisitApproved == null`)

### 2. Logika Deadline

- **Visit hari ini**: Dapat disetujui kapan saja
- **Visit kemarin**: Deadline sampai hari ini jam 12:00 siang
- **Visit > 1 hari yang lalu**: Sudah pasti melewati batas

## Implementasi UI

### 1. Card Realisasi Visit (List Page)

**File**: `lib/features/realisasi_visit/presentation/widgets/realisasi_visit_card.dart`

**Fitur yang Ditambahkan**:

- Warning banner merah di bagian atas card
- Menampilkan jumlah jadwal yang melewati batas
- Icon warning amber untuk visual yang jelas

**Contoh Tampilan**:

```
⚠️ 3 jadwal melewati batas approval
┌─────────────────────────────────┐
│ Nama Bawahan                    │
│ Role: Sales                     │
│ ─────────────────────────────── │
│ 📅 Total Jadwal: 10             │
│ 👨‍⚕️ Dokter: 5                   │
│ 🏥 Klinik: 3                    │
│ ✅ Terrealisasi: 8/10           │
│ ┌─────────────────────────────┐ │
│ ● Selesai: 5  ● Tidak Selesai: 2│ │
│ ● Menunggu: 3                  │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### 2. Detail Page

**File**: `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

**Fitur yang Ditambahkan**:

#### A. Warning Section

- Card khusus untuk informasi jadwal melewati batas
- Menampilkan jumlah total jadwal yang melewati batas
- Penjelasan deadline approval
- Info box dengan detail aturan deadline

#### B. Individual Schedule Card Indicator

- Badge merah pada setiap jadwal yang melewati batas
- Icon jam dan teks "Melewati batas approval"
- Posisi di bawah status badge

**Contoh Tampilan**:

```
┌─────────────────────────────────┐
│ ⚠️ Jadwal Melewati Batas Approval│
│                                 │
│ Terdapat 3 jadwal yang telah    │
│ melewati batas waktu approval.  │
│ Jadwal ini tidak dapat disetujui│
│ lagi.                           │
│                                 │
│ ℹ️ Deadline approval: maksimal 1 │
│    hari setelah tanggal visit   │
│    atau sampai jam 12 siang     │
│    hari berikutnya.             │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ☑️ Dr. Ahmad                    │
│ 📅 Tanggal: 15 Jan 2025        │
│ [Menunggu]                     │
│                                 │
│ ⏰ Melewati batas approval      │
│                                 │
│ 🕐 Shift: Pagi                  │
│ 📋 Jenis: Regular               │
│ ℹ️ Status: Pending              │
└─────────────────────────────────┘
```

## Technical Implementation

### 1. Helper Functions

#### `_getOverdueApprovalInfo()` (Card Widget)

```dart
OverdueInfo _getOverdueApprovalInfo() {
  int overdueCount = 0;

  for (final detail in realisasiVisit.details) {
    if (detail.statusTerrealisasi.toLowerCase() == 'done' &&
        detail.realisasiVisitApproved == null) {

      final DateTime? visitDate = _parseVisitDate(detail.tglVisit);
      if (visitDate != null) {
        // Check deadline logic
        // Return count of overdue schedules
      }
    }
  }

  return OverdueInfo(
    hasOverdue: overdueCount > 0,
    overdueCount: overdueCount,
  );
}
```

#### `_hasOverdueSchedules()` (Detail Page)

```dart
bool _hasOverdueSchedules() {
  return widget.realisasiVisit.details.any((detail) {
    // Check if any schedule is overdue
    // Return true if found
  });
}
```

#### `_getOverdueSchedulesCount()` (Detail Page)

```dart
int _getOverdueSchedulesCount() {
  int count = 0;
  // Count overdue schedules
  return count;
}
```

#### `_isScheduleOverdue()` (Detail Page)

```dart
bool _isScheduleOverdue(RealisasiVisitDetail schedule) {
  // Check if specific schedule is overdue
  // Return true/false
}
```

### 2. Date Parsing

**Fungsi**: `_parseVisitDate()`

- Mendukung multiple format tanggal
- ISO format: `yyyy-MM-dd`
- US format: `MM/dd/yyyy`
- Display format: `dd MMM yyyy`
- Indonesian format: `dd/MM/yyyy`
- Error handling untuk format yang tidak valid

### 3. Data Structure

**Class**: `OverdueInfo`

```dart
class OverdueInfo {
  final bool hasOverdue;
  final int overdueCount;

  const OverdueInfo({
    required this.hasOverdue,
    required this.overdueCount,
  });
}
```

## User Experience

### 1. Visual Hierarchy

- **Warning Banner**: Posisi paling atas untuk immediate attention
- **Color Coding**: Merah untuk error/warning state
- **Icon Usage**: Warning amber dan schedule icons
- **Typography**: Font weight dan size yang sesuai

### 2. Information Architecture

- **Card Level**: Overview jumlah jadwal melewati batas
- **Detail Level**: Specific jadwal yang melewati batas
- **Individual Level**: Badge pada setiap jadwal

### 3. Accessibility

- **Color Contrast**: Menggunakan opacity untuk readability
- **Icon + Text**: Kombinasi visual dan text untuk clarity
- **Responsive Design**: Adaptif untuk berbagai ukuran layar

## Business Logic

### 1. Deadline Rules

```
Visit Date: 2025-01-15
Current Date: 2025-01-17 14:00

Status: OVERDUE ✅
Reason: Visit kemarin, sudah lewat jam 12 siang hari ini
```

### 2. Approval Restrictions

- Jadwal yang melewati batas tidak dapat disetujui
- Checkbox tidak muncul untuk jadwal overdue
- Bulk approval tidak termasuk jadwal overdue

### 3. Status Consistency

- Status tetap "Pending" untuk jadwal overdue
- Badge menampilkan "Melewati batas approval"
- Tidak mengubah logika status existing

## Testing Scenarios

### 1. Normal Case

- Jadwal hari ini: Tidak ada warning
- Jadwal kemarin sebelum jam 12: Tidak ada warning
- Jadwal kemarin setelah jam 12: Warning muncul

### 2. Edge Cases

- Format tanggal invalid: Graceful handling
- Timezone differences: Menggunakan local time
- Multiple overdue schedules: Count yang benar

### 3. UI Testing

- Warning banner muncul/hilang sesuai kondisi
- Count number akurat
- Responsive pada berbagai ukuran layar

## Files Modified

1. **`lib/features/realisasi_visit/presentation/widgets/realisasi_visit_card.dart`**

   - Added: `_getOverdueApprovalInfo()` function
   - Added: `_parseVisitDate()` function
   - Added: Warning banner UI
   - Added: `OverdueInfo` class

2. **`lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`**
   - Added: `_hasOverdueSchedules()` function
   - Added: `_getOverdueSchedulesCount()` function
   - Added: `_isScheduleOverdue()` function
   - Added: Warning section UI
   - Added: Individual schedule overdue indicator

## Dependencies

- `intl` package untuk date formatting
- Existing theme system untuk colors dan styling
- Google Fonts untuk typography

## Future Enhancements

1. **Notification System**: Push notification untuk jadwal yang akan melewati batas
2. **Email Alerts**: Email reminder untuk atasan
3. **Dashboard Widget**: Summary card di dashboard
4. **Export Report**: Laporan jadwal yang melewati batas
5. **Custom Deadline**: Konfigurasi deadline per role/perusahaan

## Date: 2025-01-17

## Updated by: System
