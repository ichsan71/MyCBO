import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

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
  final bool showShadow;
  final Color? shadowColor;
  final Color? titleColor;
  final Color? subtitleColor;

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
    this.showShadow = true,
    this.shadowColor,
    this.titleColor,
    this.subtitleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = AppTheme.borderRadiusMedium;

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
                  const SizedBox(width: AppTheme.spacingMedium),
                ],
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: titleColor ?? theme.colorScheme.primary,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: subtitleColor ??
                                    theme.colorScheme.onSurfaceVariant,
                              ),
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

    final double effectiveElevation =
        showShadow ? (elevation ?? AppTheme.elevationSmall) : 0.0;
    final effectiveShadowColor = shadowColor ??
        Colors.black.withOpacity(0.1); // Meningkatkan kontras bayangan

    final card = Card(
      elevation: effectiveElevation,
      shadowColor: effectiveShadowColor,
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? defaultBorderRadius,
        side: hasBorder
            ? BorderSide(
                color: borderColor ??
                    theme.colorScheme.outline
                        .withOpacity(0.3), // Menggunakan withOpacity
                width: 1.0,
              )
            : BorderSide.none,
      ),
      color: backgroundColor ??
          theme.cardTheme.color ??
          AppTheme.cardBackgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: cardContent,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? defaultBorderRadius,
        child: card,
      );
    }

    return card;
  }
}
