import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/schedule.dart';

class ScheduleStatusHelper {
  static String getStatusText(Schedule schedule) {
    final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
    final lowerDraft = schedule.draft.toLowerCase().trim();

    // Jika jadwal ditolak
    if (lowerDraft.contains('rejected')) {
      return 'Ditolak';
    }

    // Jika jadwal sudah check-out tapi menunggu persetujuan realisasi
    if ((lowerStatus == 'check-out' || lowerStatus == 'selesai') &&
        (schedule.realisasiApprove == null || schedule.realisasiApprove == 0)) {
      return 'Menunggu Persetujuan';
    }

    // Jika jadwal sudah disetujui (approved == 1)
    if (schedule.approved == 1) {
      switch (lowerStatus) {
        case 'belum checkin':
          return 'Check-in';
        case 'check-in':
        case 'belum checkout':
          return 'Check-out';
        case 'check-out':
        case 'selesai':
          return schedule.realisasiApprove == 1
              ? 'Selesai'
              : 'Menunggu Persetujuan';
      }
    }

    // Jika jadwal belum disetujui
    if (schedule.approved == 0) {
      return 'Menunggu Persetujuan';
    }

    return 'Status Tidak Diketahui';
  }

  static Color getStatusColor(Schedule schedule) {
    final status = getStatusText(schedule);

    switch (status) {
      case 'Ditolak':
        return Colors.red.shade700;
      case 'Menunggu Persetujuan':
        return Colors.orange.shade700;
      case 'Check-in':
        return Colors.blue.shade700;
      case 'Check-out':
        return Colors.green.shade700;
      case 'Selesai':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  static IconData getStatusIcon(Schedule schedule) {
    final status = getStatusText(schedule);

    switch (status) {
      case 'Ditolak':
        return Icons.cancel_outlined;
      case 'Menunggu Persetujuan':
        return Icons.pending_outlined;
      case 'Check-in':
        return Icons.login_outlined;
      case 'Check-out':
        return Icons.logout_outlined;
      case 'Selesai':
        return Icons.check_circle_outlined;
      default:
        return Icons.help_outline;
    }
  }

  static bool isFilterMatch(Schedule schedule, String filterStatus) {
    final currentStatus = getStatusText(schedule);
    final lowerFilter = filterStatus.toLowerCase();

    switch (lowerFilter) {
      case 'semua':
        return true;
      case 'menunggu persetujuan':
        return currentStatus == 'Menunggu Persetujuan';
      case 'check-in':
        return currentStatus == 'Check-in';
      case 'check-out':
        return currentStatus == 'Check-out';
      case 'selesai':
        return currentStatus == 'Selesai';
      case 'ditolak':
        return currentStatus == 'Ditolak';
      default:
        return false;
    }
  }

  static String getDisplayStatus(
    BuildContext context,
    String status,
    String draft,
    int approved,
    String? namaApprover,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    // Prioritas 1: Cek Draft Rejected
    if (lowerDraft.contains('rejected')) {
      return namaApprover != null && namaApprover.isNotEmpty
          ? l10n.rejectedBy(namaApprover)
          : l10n.rejected;
    }

    // Prioritas 2: Cek Status dan Approval
    if (lowerStatus == 'belum checkin') {
      if (approved == 1) {
        return namaApprover != null && namaApprover.isNotEmpty
            ? l10n.approvedBy(namaApprover)
            : l10n.filterApproved;
      } else {
        return l10n.pendingApproval;
      }
    }

    // Prioritas 3: Status lainnya
    switch (lowerStatus) {
      case 'check-in':
        return l10n.checkedIn;
      case 'belum checkout':
        return l10n.notCheckedOut;
      case 'selesai':
        if (lowerDraft == 'submitted') {
          return l10n.completed;
        } else if (namaApprover != null && namaApprover.isNotEmpty) {
          return '${l10n.completed} (${l10n.approvedBy(namaApprover)})';
        } else {
          return l10n.completed;
        }
      case 'batal':
        return l10n.cancelled;
      case 'ditolak':
        return namaApprover != null && namaApprover.isNotEmpty
            ? l10n.rejectedBy(namaApprover)
            : l10n.rejected;
      default:
        return status;
    }
  }
}
