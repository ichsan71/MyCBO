import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckInStatusHelper {
  static Color getStatusColor(String status) {
    final lowerStatus = status.toLowerCase().trim();
    
    switch (lowerStatus) {
      case 'belum checkin':
        return Colors.orange;
      case 'check-in':
        return Colors.green;
      case 'belum checkout':
        return Colors.blue;
      case 'selesai':
        return Colors.purple;
      case 'batal':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String getDisplayStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    final lowerStatus = status.toLowerCase().trim();

    switch (lowerStatus) {
      case 'belum checkin':
        return l10n.notCheckedIn;
      case 'check-in':
        return l10n.checkedIn;
      case 'belum checkout':
        return l10n.notCheckedOut;
      case 'selesai':
        return l10n.completed;
      case 'batal':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  static IconData getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase().trim();

    switch (lowerStatus) {
      case 'belum checkin':
        return Icons.login_outlined;
      case 'check-in':
        return Icons.check_circle;
      case 'belum checkout':
        return Icons.logout_outlined;
      case 'selesai':
        return Icons.done_all;
      case 'batal':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
} 