import 'package:flutter/material.dart';
import '../widgets/check_in_warning_dialog.dart';

class DialogHelper {
  static Future<bool> showCheckInWarningDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CheckInWarningDialog(
        onProceed: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    return result ?? false;
  }
}
