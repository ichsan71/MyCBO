import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  success,
  warning,
  error
}

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
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool showShadow;

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
    this.borderRadius = 12,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = Theme.of(context).brightness;

    // Determine button style based on type
    ButtonStyle buttonStyle;
    Color bgColor;
    Color fgColor;

    switch (type) {
      case AppButtonType.primary:
        bgColor = backgroundColor ?? theme.colorScheme.primary;
        fgColor = textColor ?? theme.colorScheme.onPrimary;
        break;
      case AppButtonType.secondary:
        bgColor = backgroundColor ?? theme.colorScheme.secondary;
        fgColor = textColor ?? theme.colorScheme.onSecondary;
        break;
      case AppButtonType.success:
        // Menggunakan warna yang lebih terang untuk mode normal
        bgColor = backgroundColor ??
            (brightness == Brightness.light
                ? const Color(0xFF4CAF50) // Hijau yang lebih terang
                : AppTheme.successColor);
        fgColor = textColor ?? Colors.white;
        break;
      case AppButtonType.warning:
        bgColor = backgroundColor ?? AppTheme.warningColor;
        fgColor = textColor ?? Colors.black;
        break;
      case AppButtonType.error:
        // Menggunakan warna yang lebih terang untuk mode normal
        bgColor = backgroundColor ??
            (brightness == Brightness.light
                ? const Color(0xFFE57373) // Merah yang lebih terang
                : theme.colorScheme.error);
        fgColor = textColor ??
            (brightness == Brightness.light
                ? Colors.white
                : theme.colorScheme.onError);
        break;
      case AppButtonType.outline:
        bgColor = Colors.transparent;
        fgColor = textColor ?? theme.colorScheme.primary;
        break;
      case AppButtonType.text:
        bgColor = Colors.transparent;
        fgColor = textColor ?? theme.colorScheme.primary;
        break;
    }

    // Apply elevation based on button type and showShadow flag
    final double elevation = (showShadow &&
            (type == AppButtonType.primary ||
                type == AppButtonType.secondary ||
                type == AppButtonType.success ||
                type == AppButtonType.warning ||
                type == AppButtonType.error))
        ? AppTheme.elevationSmall
        : 0;

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.success:
      case AppButtonType.warning:
      case AppButtonType.error:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: elevation,
          shadowColor:
              showShadow ? bgColor.withOpacity(0.4) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMedium,
                  horizontal: AppTheme.spacingLarge),
          disabledBackgroundColor: bgColor.withOpacity(0.6),
          disabledForegroundColor: fgColor.withOpacity(0.6),
          minimumSize: const Size(88, 48),
        );
        break;
      case AppButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: BorderSide(
              color: backgroundColor ?? theme.colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMedium,
                  horizontal: AppTheme.spacingLarge),
          minimumSize: const Size(88, 48),
        );
        break;
      case AppButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSmall,
                  horizontal: AppTheme.spacingMedium),
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
          SizedBox(width: AppTheme.spacingSmall),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.outline || type == AppButtonType.text
                    ? fgColor
                    : Colors.white,
              ),
            ),
          )
        else
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: fontWeight ?? FontWeight.w600,
              fontSize: fontSize ?? 16,
            ),
            textAlign: TextAlign.center,
          ),
        if (suffixIcon != null && !isLoading) ...[
          SizedBox(width: AppTheme.spacingSmall),
          suffixIcon!,
        ],
      ],
    );

    // Create the button with appropriate type
    Widget button;
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.success:
      case AppButtonType.warning:
      case AppButtonType.error:
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
