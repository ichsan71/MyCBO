import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12.0,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine button style based on type
    ButtonStyle buttonStyle;

    switch (type) {
      case AppButtonType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: textColor ?? theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        );
        break;
      case AppButtonType.secondary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
          foregroundColor: textColor ?? theme.colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        );
        break;
      case AppButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: textColor ?? theme.colorScheme.primary,
          side: BorderSide(color: backgroundColor ?? theme.colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        );
        break;
      case AppButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: textColor ?? theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        );
        break;
    }

    // Create button content
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null && !isLoading) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary || type == AppButtonType.secondary
                    ? Colors.white
                    : theme.colorScheme.primary,
              ),
            ),
          )
        else
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        if (suffixIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );

    // Create the button with appropriate type
    Widget button;
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        button = ElevatedButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        );
        break;
    }

    // Handle width constraints
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    } else if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    } else {
      return button;
    }
  }
}
