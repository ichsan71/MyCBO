import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool hasBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.hasBorder = false,
    this.borderColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || leading != null || actions != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        child,
      ],
    );

    final card = Card(
      elevation: elevation ?? AppTheme.elevationSmall,
      margin: margin ?? const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: hasBorder
            ? BorderSide(
                color:
                    borderColor ?? AppTheme.secondaryTextColor.withOpacity(0.3),
                width: 1.0,
              )
            : BorderSide.none,
      ),
      color: backgroundColor ?? AppTheme.cardBackgroundColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: cardContent,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: card,
      );
    }

    return card;
  }
}
