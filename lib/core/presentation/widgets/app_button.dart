import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';
import 'package:test_cbo/core/theme/app_theme.dart';

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
    this.borderRadius = AppTheme.borderRadiusSmall,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine button style based on type
    ButtonStyle buttonStyle;
    Color bgColor;
    Color fgColor;

    switch (type) {
      case AppButtonType.primary:
        bgColor = backgroundColor ?? AppTheme.primaryColor;
        fgColor = textColor ?? Colors.white;
        break;
      case AppButtonType.secondary:
        bgColor = backgroundColor ?? AppTheme.secondaryColor;
        fgColor = textColor ?? Colors.white;
        break;
      case AppButtonType.success:
        bgColor = backgroundColor ?? AppTheme.successColor;
        fgColor = textColor ?? Colors.white;
        break;
      case AppButtonType.warning:
        bgColor = backgroundColor ?? AppTheme.warningColor;
        fgColor = textColor ?? Colors.white;
        break;
      case AppButtonType.error:
        bgColor = backgroundColor ?? AppTheme.errorColor;
        fgColor = textColor ?? Colors.white;
        break;
      case AppButtonType.outline:
        bgColor = Colors.transparent;
        fgColor = textColor ?? AppTheme.primaryColor;
        break;
      case AppButtonType.text:
        bgColor = Colors.transparent;
        fgColor = textColor ?? AppTheme.primaryColor;
        break;
    }

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.success:
      case AppButtonType.warning:
      case AppButtonType.error:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: AppTheme.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          disabledBackgroundColor: bgColor.withOpacity(0.6),
          disabledForegroundColor: fgColor.withOpacity(0.6),
        );
        break;
      case AppButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: BorderSide(color: backgroundColor ?? AppTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        );
        break;
      case AppButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: fgColor,
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
              fontWeight: fontWeight ?? FontWeight.w500,
              fontSize: fontSize ?? 16,
            ),
            textAlign: TextAlign.center,
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
