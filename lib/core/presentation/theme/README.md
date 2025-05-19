# Panduan Styling dan Warna Aplikasi CBO

## Pengantar

Dokumen ini berisi panduan untuk memastikan konsistensi styling dan warna di seluruh aplikasi CBO. Semua pengembang harus mengikuti panduan ini untuk menjaga konsistensi UI/UX.

## Warna

Semua warna yang digunakan dalam aplikasi harus mengacu pada kelas `AppTheme`:

```dart
// Warna utama
AppTheme.primaryColor    // Biru (#1976D2)
AppTheme.secondaryColor  // Teal (#26A69A)

// Warna status
AppTheme.successColor    // Hijau (#4CAF50)
AppTheme.warningColor    // Kuning (#FFC107)
AppTheme.errorColor      // Merah (#D32F2F)

// Warna teks
AppTheme.primaryTextColor    // Hitam (#212121)
AppTheme.secondaryTextColor  // Abu-abu (#757575)

// Warna latar
AppTheme.cardBackgroundColor // Putih (#FFFFFF)
```

## Border Radius

Untuk menjaga konsistensi, gunakan nilai border radius yang telah ditentukan:

```dart
AppTheme.borderRadiusSmall   // 8px
AppTheme.borderRadiusMedium  // 12px
AppTheme.borderRadiusLarge   // 16px
```

Penggunaan:

- `borderRadiusSmall`: Untuk elemen kecil seperti chip, badge, dan tombol kecil
- `borderRadiusMedium`: Untuk elemen sedang seperti kartu, dialog, dan tombol standar
- `borderRadiusLarge`: Untuk elemen besar seperti panel dan kartu utama

## Elevasi

Gunakan nilai elevasi standar untuk konsistensi bayangan:

```dart
AppTheme.elevationSmall   // 2
AppTheme.elevationMedium  // 4
AppTheme.elevationLarge   // 8
```

## Transparansi

Untuk transparansi, gunakan `withAlpha()` dengan nilai standar:

```dart
color.withAlpha(51)   // 20% opacity (0.2)
color.withAlpha(76)   // 30% opacity (0.3)
color.withAlpha(102)  // 40% opacity (0.4)
color.withAlpha(128)  // 50% opacity (0.5)
color.withAlpha(153)  // 60% opacity (0.6)
color.withAlpha(178)  // 70% opacity (0.7)
color.withAlpha(204)  // 80% opacity (0.8)
color.withAlpha(229)  // 90% opacity (0.9)
```

## Komponen UI

### AppBar

Gunakan komponen `AppBarWidget` untuk semua app bar dalam aplikasi:

```dart
AppBarWidget(
  title: 'Judul Halaman',
  actions: [...],
)
```

### Button

Gunakan komponen `AppButton` untuk semua tombol:

```dart
AppButton(
  text: 'Tombol',
  onPressed: () {},
  type: AppButtonType.primary, // primary, secondary, outline, text, success, warning, error
)
```

### Card

Gunakan komponen `AppCard` untuk semua kartu:

```dart
AppCard(
  title: 'Judul Kartu',
  subtitle: 'Subjudul',
  child: YourContent(),
)
```

## Praktik Terbaik

1. Selalu gunakan komponen yang telah disediakan daripada membuat komponen baru
2. Jangan mendefinisikan warna atau nilai border radius secara langsung dalam kode
3. Gunakan tema yang konsisten untuk seluruh aplikasi
4. Ikuti pola desain Material Design untuk pengalaman pengguna yang konsisten
