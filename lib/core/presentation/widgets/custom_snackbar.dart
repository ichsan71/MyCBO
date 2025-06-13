import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration? duration,
  }) {
    // Get screen size and safe area
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    // Handle long error messages by allowing them to wrap
    String displayMessage = message;
    if (message.length > 100) {
      displayMessage = message.substring(0, 100) + '...';
    }

    final snackBar = SnackBar(
      content: Material(
        color: Colors.transparent,
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayMessage,
                    style: GoogleFonts.poppins(
                      color: isError || isSuccess
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isError || isSuccess)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: isError
          ? AppTheme.errorColor
          : isSuccess
              ? AppTheme.successColor
              : theme.snackBarTheme.backgroundColor,
      behavior: SnackBarBehavior.fixed,
      duration: duration ?? const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
      elevation: 6,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: mediaQuery.viewInsets.bottom > 0 ? 0 : 8,
        top: 8,
      ),
    );

    // Ensure we're showing the SnackBar in a safe way
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      if (messenger.mounted) {
        messenger.clearSnackBars();
        messenger.showSnackBar(snackBar);
      }
    });
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      isError: true,
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      isSuccess: true,
      duration: duration,
    );
  }
}
