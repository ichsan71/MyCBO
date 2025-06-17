import 'package:flutter/material.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final Color? backgroundColor;
  final Widget? flexibleSpace;
  final bool? showShadow;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.bottom,
    this.elevation = 0,
    this.backgroundColor,
    this.flexibleSpace,
    this.showShadow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: actions,
      bottom: bottom,
      elevation: showShadow == true ? AppTheme.elevationMedium : elevation,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      flexibleSpace: flexibleSpace,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      shadowColor: showShadow == true
          ? Colors.black.withOpacity(0.3)
          : Colors.transparent,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
