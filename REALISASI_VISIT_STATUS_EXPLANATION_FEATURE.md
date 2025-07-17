# Fitur Penjelasan Status pada Detail Realisasi Visit

## Overview

Fitur baru telah ditambahkan untuk memberikan penjelasan yang jelas tentang arti dari masing-masing status pada halaman detail realisasi visit. Fitur ini membantu user memahami dengan mudah apa yang dimaksud dengan setiap status yang ditampilkan.

## Implementasi UI

### Lokasi Penjelasan Status

**File**: `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

**Posisi**: Di bawah pembatas filter, setelah search result info (jika ada)

### Struktur Komponen

#### 1. Container Utama

- **Background**: Card background color
- **Border**: Border color dengan radius 12px
- **Padding**: 16px untuk spacing yang nyaman
- **Layout**: Column dengan crossAxisAlignment start

#### 2. Header Section

- **Icon**: `info_outline` dengan warna primary
- **Title**: "Penjelasan Status" dengan font weight 600
- **Spacing**: 8px antara icon dan text

#### 3. Status Items

Setiap status memiliki item penjelasan yang terdiri dari:

- **Icon Container**: Background color sesuai status dengan opacity 0.1
- **Status Name**: Font weight 600, primary text color
- **Description**: Font weight normal, secondary text color, height 1.4

## Status yang Dijelaskan

### 1. Selesai

- **Icon**: `check_circle_outline`
- **Color**: Green
- **Penjelasan**: "Status selesai berarti data sudah disetujui dan berhasil check-in & check-out"

### 2. Pending

- **Icon**: `pending_outlined`
- **Color**: Orange
- **Penjelasan**: "Status pending berarti data sudah selesai check-in & check-out tapi belum disetujui"

### 3. Tidak Selesai

- **Icon**: `cancel_outlined`
- **Color**: Red
- **Penjelasan**: "Status tidak selesai berarti data belum melakukan check-in atau check-out"

## Technical Implementation

### Helper Functions

#### `_buildStatusExplanation()`

```dart
Widget _buildStatusExplanation() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.getCardBackgroundColor(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.getBorderColor(context),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Penjelasan Status', ...),
          ],
        ),
        const SizedBox(height: 12),
        // Status items
        _buildStatusExplanationItem('Selesai', '...', Colors.green, Icons.check_circle_outline),
        _buildStatusExplanationItem('Pending', '...', Colors.orange, Icons.pending_outlined),
        _buildStatusExplanationItem('Tidak Selesai', '...', Colors.red, Icons.cancel_outlined),
      ],
    ),
  );
}
```

#### `_buildStatusExplanationItem()`

```dart
Widget _buildStatusExplanationItem(
  String status,
  String description,
  Color color,
  IconData icon,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Icon container
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 12),
      // Text content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, ...), // Status name
            const SizedBox(height: 2),
            Text(description, ...), // Description
          ],
        ),
      ),
    ],
  );
}
```

## Visual Design

### Layout Structure

```
┌─────────────────────────────────┐
│ ℹ️ Penjelasan Status            │
│                                 │
│ 🟢 Selesai                      │
│    Status selesai berarti data  │
│    sudah disetujui dan berhasil │
│    check-in & check-out         │
│                                 │
│ 🟠 Pending                      │
│    Status pending berarti data  │
│    sudah selesai check-in &     │
│    check-out tapi belum disetujui│
│                                 │
│ 🔴 Tidak Selesai                │
│    Status tidak selesai berarti │
│    data belum melakukan check-in│
│    atau check-out               │
└─────────────────────────────────┘
```

### Color Scheme

- **Primary Color**: Untuk header dan accent
- **Green**: Status "Selesai"
- **Orange**: Status "Pending"
- **Red**: Status "Tidak Selesai"
- **Background**: Card background color
- **Border**: Border color

### Typography

- **Header**: 16px, weight 600, primary color
- **Status Name**: 14px, weight 600, primary text color
- **Description**: 13px, weight normal, secondary text color, height 1.4

## User Experience

### Benefits

1. **Clarity**: User langsung memahami arti setiap status
2. **Consistency**: Penjelasan yang konsisten dengan logika bisnis
3. **Accessibility**: Icon dan warna yang membantu visual recognition
4. **Education**: Membantu user baru memahami sistem

### Positioning

- **Strategic Location**: Setelah filter, sebelum daftar jadwal
- **Non-Intrusive**: Tidak mengganggu alur kerja utama
- **Always Visible**: Selalu tersedia untuk referensi

### Responsive Design

- **Flexible Layout**: Menggunakan Expanded untuk text content
- **Proper Spacing**: Consistent spacing antara elemen
- **Icon Scaling**: Icon size yang proporsional

## Integration

### With Existing Features

- **Filter System**: Penjelasan sesuai dengan filter status yang ada
- **Status Badge**: Konsisten dengan warna dan icon di status badge
- **Theme System**: Menggunakan theme colors yang konsisten

### State Management

- **Static Content**: Tidak memerlukan state management khusus
- **Theme Aware**: Responsive terhadap perubahan theme
- **No Dependencies**: Tidak bergantung pada data dinamis

## Testing Points

### Visual Testing

- [ ] Penjelasan status muncul dengan benar
- [ ] Icon dan warna sesuai dengan status
- [ ] Layout responsive pada berbagai ukuran layar
- [ ] Typography readable dan konsisten

### Content Testing

- [ ] Penjelasan status akurat dan mudah dipahami
- [ ] Text tidak terpotong atau overflow
- [ ] Spacing antar elemen proporsional

### Integration Testing

- [ ] Tidak mengganggu filter functionality
- [ ] Tidak mempengaruhi search result info
- [ ] Compatible dengan theme system

## Files Modified

1. **`lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`**
   - Added: `_buildStatusExplanation()` function
   - Added: `_buildStatusExplanationItem()` function
   - Modified: `_buildSearchBar()` to include status explanation
   - Added: Status explanation UI components

## Future Enhancements

1. **Collapsible**: Option untuk collapse/expand penjelasan
2. **Localization**: Support untuk multiple languages
3. **Dynamic Content**: Penjelasan yang bisa diupdate dari backend
4. **Interactive**: Tooltip atau modal untuk detail lebih lanjut
5. **Customization**: User preference untuk menampilkan/menyembunyikan

## Date: 2025-01-17

## Updated by: System
