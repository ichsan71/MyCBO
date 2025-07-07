# Realisasi Visit API Parameter Bug Fix

## Overview

Fix bug pada approval realisasi visit yang gagal karena parameter API yang salah sesuai dengan ekspektasi backend.

## 🐛 **Bug Description**

### Error Message

```
API Response: {
  "success": false,
  "message": "Gagal approve, Id atasan tidak terdaftar."
}
```

### Root Cause

Parameter yang dikirim ke API tidak sesuai dengan ekspektasi backend:

**❌ Parameter Lama (Salah):**

```dart
{
  'id_realisasi_visit': '133308',
  'id_user': '815'
}
```

**✅ Parameter Baru (Benar):**

```dart
{
  'id_atasan': '815',
  'id_schedule': ['133308']
}
```

## 🔧 **Solution**

### Files Modified

#### 1. `lib/features/realisasi_visit/data/datasources/realisasi_visit_remote_data_source.dart`

**Approval Function:**

```dart
// Before
final formData = {
  'id_realisasi_visit': idRealisasiVisit.toString(),
  'id_user': idUser.toString(),
};

// After
final formData = {
  'id_atasan': idUser.toString(),
  'id_schedule': ['$idRealisasiVisit'],
};
```

**Reject Function:**

```dart
// Before
final formData = {
  'id_realisasi_visit': idRealisasiVisit.toString(),
  'id_user': idUser.toString(),
  'reason': reason,
};

// After
final formData = {
  'id_atasan': idUser.toString(),
  'id_schedule': ['$idRealisasiVisit'],
  'reason': reason,
};
```

#### 2. `lib/features/realisasi_visit/data/datasources/realisasi_visit_remote_data_source_impl.dart`

**Approval Function:**

```dart
// Before
body: json.encode({
  'id_realisasi_visit': idRealisasiVisit.toString(),
  'id_user': idUser.toString(),
})

// After
body: json.encode({
  'id_atasan': idUser.toString(),
  'id_schedule': ['$idRealisasiVisit'],
})
```

**Reject Function:**

```dart
// Before
body: json.encode({
  'id_realisasi_visit': idRealisasiVisit,
  'id_user': idUser,
  'reason': reason,
})

// After
body: json.encode({
  'id_atasan': idUser.toString(),
  'id_schedule': ['$idRealisasiVisit'],
  'reason': reason,
})
```

### 3. Enhanced Error Handling

Added proper handling for `success: false` responses:

```dart
if (response.statusCode == 200) {
  final data = json.decode(response.body);

  if (data['success'] == true) {
    return data['message'] ?? 'Realisasi visit berhasil disetujui';
  } else {
    // Jika success = false, lempar exception dengan pesan error dari API
    throw ServerException(
      message: data['message'] ?? 'Gagal menyetujui realisasi visit',
    );
  }
}
```

## 📊 **API Parameter Mapping**

| Purpose                       | Parameter     | Type          | Example               |
| ----------------------------- | ------------- | ------------- | --------------------- |
| ID Atasan (User yang approve) | `id_atasan`   | String        | "815"                 |
| ID Schedule yang di-approve   | `id_schedule` | Array[String] | ["133308"]            |
| Alasan reject (optional)      | `reason`      | String        | "Tidak sesuai target" |

## 🧪 **Testing Scenarios**

### Before Fix

```
Request: {id_realisasi_visit: "133308", id_user: "815"}
Response: {success: false, message: "Gagal approve, Id atasan tidak terdaftar."}
Status: ❌ FAILED
```

### After Fix

```
Request: {id_atasan: "815", id_schedule: ["133308"]}
Response: {success: true, message: "Realisasi visit berhasil disetujui"}
Status: ✅ SUCCESS
```

## 🔍 **Validation Points**

1. **Parameter Names**: `id_atasan` bukan `id_user`
2. **Schedule Format**: Array `["id"]` bukan string `"id"`
3. **Success Handling**: Cek `success: true/false` di response
4. **Error Messages**: Tampilkan pesan error dari API yang akurat

## 📝 **Notes**

- User ID 815 adalah ID atasan yang valid untuk approve
- Backend expects `id_atasan` sebagai identifikasi user yang melakukan approval
- `id_schedule` adalah array karena mendukung bulk approval di masa depan
- Error handling ditingkatkan untuk menangani response `success: false`

## 🎯 **Impact**

- ✅ Approval realisasi visit sekarang bekerja dengan benar
- ✅ Error message lebih informatif dari backend
- ✅ Konsistensi parameter API antara approval dan reject
- ✅ Support untuk future bulk approval functionality

## Date: 2025-01-15

## Fixed by: System
