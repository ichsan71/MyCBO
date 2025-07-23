# CEO Role Restriction Update

## Overview

Perubahan telah dilakukan untuk membatasi akses role CEO terhadap menu-menu tertentu sesuai dengan requirement baru. CEO tidak dapat mengakses menu persetujuan, realisasi visit, add schedule, KPI anggota, ringkasan kinerja, dan peringkat achievement.

## Perubahan yang Dilakukan

### 1. Menu Access Control (Home Page)

**File:** `lib/features/auth/presentation/pages/home_page.dart`

**Perubahan:**

- Menghapus `CEO` dari daftar role yang memiliki akses ke menu approval
- Menghapus `CEO` dari daftar role yang memiliki akses ke menu realisasi visit
- Menghapus `CEO` dari daftar role yang memiliki akses ke menu add schedule
- Menghapus `CEO` dari daftar role yang memiliki akses ke menu KPI anggota
- Menyembunyikan section ringkasan kinerja (KPI chart) untuk CEO
- Menyembunyikan section peringkat achievement untuk CEO
- Memperbarui logika `isGmOrCeo` menjadi `isGmOnly` dan menambahkan `isCeo`

**Sebelum:**

```dart
final hasApprovalAccess = role == 'ADMIN' ||
    role == 'BCO' ||
    role == 'RSM' ||
    role == 'DM' ||
    role == 'AM' ||
    role == 'GM' ||
    role == 'CEO';

final hasRealisasiVisitAccess = role == 'ADMIN' ||
    role == 'GM' ||
    role == 'CEO' ||
    role == 'BCO' ||
    role == 'RSM' ||
    role == 'DM' ||
    role == 'AM';

final hasKpiAccess = role != 'PS' && role != 'GM' && role != 'AE';
final isGmOrCeo = role == 'GM' || role == 'CEO';
```

**Sesudah:**

```dart
final hasApprovalAccess = role == 'ADMIN' ||
    role == 'BCO' ||
    role == 'RSM' ||
    role == 'DM' ||
    role == 'AM' ||
    role == 'GM';

final hasRealisasiVisitAccess = role == 'ADMIN' ||
    role == 'GM' ||
    role == 'BCO' ||
    role == 'RSM' ||
    role == 'DM' ||
    role == 'AM';

final hasKpiAccess = role != 'PS' && role != 'GM' && role != 'AE' && role != 'CEO';
final isGmOnly = role == 'GM';
final isCeo = role == 'CEO';
```

### 2. Menu Access Conditions

**Perubahan pada Quick Actions Menu:**

```dart
// KPI Member menu - CEO tidak bisa akses
if (hasKpiAccess && !isGmOnly)

// Add Schedule menu - CEO tidak bisa akses
if (!isGmOnly && !isCeo)

// Approval menu - CEO tidak bisa akses
if (hasApprovalAccess)

// Realisasi Visit menu - CEO tidak bisa akses
if (hasRealisasiVisitAccess)
```

### 3. Section Visibility Control

**Ringkasan Kinerja Section:**

```dart
if (!isCeo) ...[
  // KPI Chart Section
  Container(
    // ... KPI chart content
  ),
],
```

**Peringkat Achievement Section:**

```dart
if (!isCeo) ...[
  // Ranking Achievement Section
  BlocProvider(
    create: (context) => sl<RankingAchievementBloc>(),
    child: RankingAchievementWidget(
      roleId: widget.user.user.idUser.toString(),
      currentUserId: widget.user.user.idUser,
    ),
  ),
],
```

### 4. Chatbot Category Access

**File:** `assets/data/chatbot_data.json`

**Perubahan:**

- Menghapus `CEO` dari `allowedRoles` untuk kategori "approval"
- Menghapus `CEO` dari `allowedRoles` untuk kategori "realisasi"
- Menambahkan role restrictions untuk kategori "KPI" (CEO tidak bisa akses)

**Sebelum:**

```json
{
  "id": "approval",
  "allowedRoles": ["ADMIN", "GM", "CEO", "BCO", "RSM", "DM", "AM"]
},
{
  "id": "realisasi",
  "allowedRoles": ["ADMIN", "GM", "CEO", "BCO", "RSM", "DM", "AM"]
},
{
  "id": "kpi",
  "allowedRoles": []
}
```

**Sesudah:**

```json
{
  "id": "approval",
  "allowedRoles": ["ADMIN", "GM", "BCO", "RSM", "DM", "AM"]
},
{
  "id": "realisasi",
  "allowedRoles": ["ADMIN", "GM", "BCO", "RSM", "DM", "AM"]
},
{
  "id": "kpi",
  "allowedRoles": ["ADMIN", "BCO", "RSM", "DM", "AM", "PS", "AE"]
}
```

## Dampak Perubahan

### ✅ Akses yang Dipertahankan untuk CEO

- Dashboard utama
- Menu Tanya Mazbot (chatbot) - kategori umum dan notifikasi
- Menu settings/notifikasi
- Profile dan logout
- Schedule view (hanya melihat, tidak bisa add)

### ❌ Akses yang Dibatasi untuk CEO

- Menu approval (persetujuan)
- Menu realisasi visit
- Menu add schedule
- Menu KPI anggota
- Section ringkasan kinerja (KPI chart)
- Section peringkat achievement
- Kategori chatbot untuk approval, realisasi, dan KPI

### 🔄 Tidak Berubah

- Semua role lain tetap memiliki akses sesuai dengan permission sebelumnya
- GM tetap dibatasi untuk KPI dan add schedule
- Admin tetap memiliki akses penuh

## Testing Checklist

- [ ] CEO tidak dapat melihat menu approval di dashboard
- [ ] CEO tidak dapat melihat menu realisasi visit di dashboard
- [ ] CEO tidak dapat melihat menu add schedule di dashboard
- [ ] CEO tidak dapat melihat menu KPI anggota di dashboard
- [ ] CEO tidak dapat melihat section ringkasan kinerja (KPI chart)
- [ ] CEO tidak dapat melihat section peringkat achievement
- [ ] CEO tidak dapat mengakses kategori approval di chatbot
- [ ] CEO tidak dapat mengakses kategori realisasi di chatbot
- [ ] CEO tidak dapat mengakses kategori KPI di chatbot
- [ ] CEO dapat mengakses kategori umum dan notifikasi di chatbot
- [ ] Role lain (ADMIN, GM, BCO, RSM, DM, AM) tetap memiliki akses normal
- [ ] GM tetap dibatasi untuk KPI dan add schedule

## Files Modified

1. `lib/features/auth/presentation/pages/home_page.dart`

   - Update role-based access control logic
   - Change `isGmOrCeo` to `isGmOnly`
   - Add `isCeo` variable
   - Hide KPI chart section for CEO
   - Hide ranking achievement section for CEO
   - Update menu access conditions

2. `assets/data/chatbot_data.json`
   - Remove CEO from approval category allowedRoles
   - Remove CEO from realisasi category allowedRoles
   - Add role restrictions for KPI category

## Date: 2025-01-15

## Updated by: System
