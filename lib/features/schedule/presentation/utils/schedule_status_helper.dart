import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduleStatusHelper {
  static Color getStatusColor(String status, String draft) {
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    // Prioritas 1: Cek Draft Rejected
    if (lowerDraft.contains('rejected')) {
      return Colors.red;
    }

    // Prioritas 2: Cek Status
    switch (lowerStatus) {
      case 'belum checkin':
        return Colors.blue;
      case 'check-in':
      case 'belum checkout':
        return Colors.green;
      case 'selesai':
        return Colors.purple;
      case 'batal':
        return Colors.grey;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
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
        return namaApprover != null && namaApprover.isNotEmpty
            ? '${l10n.completed} (${l10n.approvedBy(namaApprover)})'
            : l10n.completed;
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