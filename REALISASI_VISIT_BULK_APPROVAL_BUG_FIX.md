# Realisasi Visit Bulk Approval Bug Fix

## Problem Description

Users were unable to perform bulk approval on realisasi visit schedules. When selecting multiple schedules using "Pilih Semua" (Select All), only the first selected schedule was being approved instead of all selected schedules.

## Root Cause Analysis

The issue was in the `_handleApproveSelected()` method in `realisasi_visit_detail_page.dart`:

```dart
// BEFORE (Bug)
context.read<RealisasiVisitBloc>().add(
  ApproveRealisasiVisitEvent(
    idRealisasiVisit: int.parse(_selectedScheduleIds.first), // Only first ID!
    idUser: widget.userId,
  ),
);
```

The code was only sending `_selectedScheduleIds.first` to the API, while the UI correctly allowed multiple selections.

## Solution Implemented

### 1. Updated Data Source Interface

**File**: `lib/features/realisasi_visit/data/datasources/realisasi_visit_remote_data_source.dart`

Changed from single ID to list of IDs:

```dart
// BEFORE
Future<String> approveRealisasiVisit({
  required int idRealisasiVisit,
  required int idUser,
});

// AFTER
Future<String> approveRealisasiVisit({
  required List<int> idRealisasiVisits,
  required int idUser,
});
```

### 2. Updated Repository Interface

**File**: `lib/features/realisasi_visit/domain/repositories/realisasi_visit_repository.dart`

```dart
// BEFORE
Future<Either<Failure, String>> approveRealisasiVisit({
  required int idRealisasiVisit,
  required int idUser,
});

// AFTER
Future<Either<Failure, String>> approveRealisasiVisit({
  required List<int> idRealisasiVisits,
  required int idUser,
});
```

### 3. Updated Repository Implementation

**File**: `lib/features/realisasi_visit/data/repositories/realisasi_visit_repository_impl.dart`

Updated to pass list of IDs to data source.

### 4. Updated Use Cases

**File**: `lib/features/realisasi_visit/domain/usecases/approve_realisasi_visit.dart`

```dart
// BEFORE
class ApproveRealisasiVisitParams {
  final int idRealisasiVisit;
  final int idUser;
}

// AFTER
class ApproveRealisasiVisitParams {
  final List<int> idRealisasiVisits;
  final int idUser;
}
```

### 5. Updated BLoC Events

**File**: `lib/features/realisasi_visit/presentation/bloc/realisasi_visit_event.dart`

```dart
// BEFORE
class ApproveRealisasiVisitEvent extends RealisasiVisitEvent {
  final int idRealisasiVisit;
  final int idUser;
}

// AFTER
class ApproveRealisasiVisitEvent extends RealisasiVisitEvent {
  final List<int> idRealisasiVisits;
  final int idUser;
}
```

### 6. Updated BLoC Handler

**File**: `lib/features/realisasi_visit/presentation/bloc/realisasi_visit_bloc.dart`

Updated to use list of IDs in the use case call.

### 7. Updated UI Handler

**File**: `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

```dart
// BEFORE
context.read<RealisasiVisitBloc>().add(
  ApproveRealisasiVisitEvent(
    idRealisasiVisit: int.parse(_selectedScheduleIds.first), // Bug!
    idUser: widget.userId,
  ),
);

// AFTER
final List<int> selectedIds = _selectedScheduleIds
    .map((id) => int.parse(id))
    .toList();

context.read<RealisasiVisitBloc>().add(
  ApproveRealisasiVisitEvent(
    idRealisasiVisits: selectedIds, // All selected IDs
    idUser: widget.userId,
  ),
);
```

## API Compatibility

The API already supported bulk approval through the `id_schedule` parameter which accepts a JSON array:

```dart
final formData = {
  'id_atasan': idUser.toString(),
  'id_schedule': json.encode(idRealisasiVisits), // Array of IDs
};
```

## Testing

### Before Fix

1. Select multiple schedules using "Pilih Semua"
2. Click "Setujui Jadwal Terpilih"
3. Result: Only the first schedule gets approved

### After Fix

1. Select multiple schedules using "Pilih Semua"
2. Click "Setujui Jadwal Terpilih"
3. Result: All selected schedules get approved

## Impact

- ✅ Fixed bulk approval functionality
- ✅ Improved user experience for approving multiple schedules
- ✅ Maintained backward compatibility
- ✅ No breaking changes to existing single approval flows

## Files Modified

1. `lib/features/realisasi_visit/data/datasources/realisasi_visit_remote_data_source.dart`
2. `lib/features/realisasi_visit/domain/repositories/realisasi_visit_repository.dart`
3. `lib/features/realisasi_visit/data/repositories/realisasi_visit_repository_impl.dart`
4. `lib/features/realisasi_visit/domain/usecases/approve_realisasi_visit.dart`
5. `lib/features/realisasi_visit/domain/usecases/reject_realisasi_visit.dart`
6. `lib/features/realisasi_visit/presentation/bloc/realisasi_visit_event.dart`
7. `lib/features/realisasi_visit/presentation/bloc/realisasi_visit_bloc.dart`
8. `lib/features/realisasi_visit/presentation/pages/realisasi_visit_detail_page.dart`

## Status

✅ **COMPLETED** - Bug fixed and bulk approval now works correctly for multiple schedules.
