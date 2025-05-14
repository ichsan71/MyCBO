import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final double borderRadius;
  final BorderSide? borderSide;
  final VoidCallback? onTap;
  final bool isOutlined;
  final Color? shadowColor;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius = 12.0,
    this.borderSide,
    this.onTap,
    this.isOutlined = false,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final BoxDecoration decoration = BoxDecoration(
      color: backgroundColor ?? theme.cardTheme.color ?? theme.cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: isOutlined || borderSide != null
          ? Border.all(
              color: borderSide?.color ?? theme.dividerColor,
              width: borderSide?.width ?? 1.0,
              style: borderSide?.style ?? BorderStyle.solid,
            )
          : null,
      boxShadow: elevation != null && elevation! > 0 && !isOutlined
          ? [
              BoxShadow(
                color: shadowColor ?? Colors.black.withOpacity(0.1),
                blurRadius: elevation! * 2,
                spreadRadius: elevation! * 0.2,
                offset: Offset(0, elevation! * 0.5),
              ),
            ]
          : null,
    );

    final Widget cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          margin: margin ?? theme.cardTheme.margin ?? EdgeInsets.zero,
          decoration: decoration,
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: margin ?? theme.cardTheme.margin ?? EdgeInsets.zero,
      decoration: decoration,
      child: cardContent,
    );
  }
}
