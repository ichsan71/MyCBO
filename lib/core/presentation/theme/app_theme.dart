import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Light Theme Colors
  static const ThemeColors lightColors = ThemeColors(
    primary: Color(0xFF0277BD),
    secondary: Color(0xFF00897B),
    tertiary: Color(0xFF7B1FA2),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFA000),
    error: Color(0xFFD32F2F),
    surface: Color(0xFFF5F5F5),
    cardSurface: Colors.white,
    cardBackground: Colors.white,
    primaryText: Color(0xFF212121),
    secondaryText: Color(0xFF757575),
    disabled: Color(0xFFBDBDBD),
    scheduleText: Color(0xFF333333),
    scheduleIcon: Color(0xFF1565C0),
    scheduleHeader: Color(0xFF1976D2),
    scheduleSubtext: Color(0xFF616161),
    scheduleBackground: Color(0xFFFAFAFA),
    scheduleCard: Colors.white,
    scheduleSelectedItem: Color(0xFFE3F2FD),
    scheduleHighlight: Color(0xFF2196F3),
    divider: Color(0xFFEEEEEE),
    border: Color(0xFFE0E0E0),
  );

  // Dark Theme Colors
  static const ThemeColors darkColors = ThemeColors(
    primary: Color(0xFF90CAF9),
    secondary: Color(0xFF80CBC4),
    tertiary: Color(0xFFCE93D8),
    success: Color(0xFFA5D6A7),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFEF5350),
    surface: Color(0xFF121212),
    cardSurface: Color(0xFF1F1F1F),
    cardBackground: Color(0xFF2C2C2C),
    primaryText: Colors.white,
    secondaryText: Colors.white70,
    disabled: Colors.white38,
    scheduleText: Colors.white,
    scheduleIcon: Color(0xFF90CAF9),
    scheduleHeader: Color(0xFF42A5F5),
    scheduleSubtext: Colors.white70,
    scheduleBackground: Color(0xFF121212),
    scheduleCard: Color(0xFF2C2C2C),
    scheduleSelectedItem: Color(0xFF1565C0),
    scheduleHighlight: Color(0xFF90CAF9),
    divider: Color(0xFF424242),
    border: Color(0xFF424242),
  );

  static ThemeColors get colors {
    if (currentContext == null) {
      return lightColors;
    }
    return Theme.of(currentContext!).brightness == Brightness.dark
        ? darkColors
        : lightColors;
  }

  // Shadow
  static final List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(13),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // Border Radius
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(8);
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(12);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(16);
  static final BorderRadius borderRadiusXLarge = BorderRadius.circular(24);

  // Elevations
  static const double elevationSmall = 1;
  static const double elevationMedium = 3;
  static const double elevationLarge = 6;

  // Spacing
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;

  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  static BuildContext? currentContext;

  static ThemeData lightTheme() {
    const colors = lightColors;

    final ColorScheme colorScheme = ColorScheme(
      primary: colors.primary,
      primaryContainer: colors.primary.withOpacity(0.2),
      secondary: colors.secondary,
      secondaryContainer: colors.secondary.withOpacity(0.2),
      tertiary: colors.tertiary,
      tertiaryContainer: colors.tertiary.withOpacity(0.2),
      surface: colors.surface,
      background: colors.surface,
      error: colors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: colors.primaryText,
      onBackground: colors.primaryText,
      onError: Colors.white,
      brightness: Brightness.light,
    );

    return _baseTheme(colorScheme, colors);
  }

  static ThemeData darkTheme() {
    const colors = darkColors;

    final ColorScheme colorScheme = ColorScheme(
      primary: colors.primary,
      primaryContainer: colors.primary.withOpacity(0.2),
      secondary: colors.secondary,
      secondaryContainer: colors.secondary.withOpacity(0.2),
      tertiary: colors.tertiary,
      tertiaryContainer: colors.tertiary.withOpacity(0.2),
      surface: colors.surface,
      background: colors.surface,
      error: colors.error,
      onPrimary: colors.surface,
      onSecondary: colors.surface,
      onTertiary: colors.surface,
      onSurface: colors.primaryText,
      onBackground: colors.primaryText,
      onError: colors.surface,
      brightness: Brightness.dark,
    );

    return _baseTheme(colorScheme, colors);
  }

  static ThemeData _baseTheme(ColorScheme colorScheme, ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colors.surface,
      cardColor: colors.cardBackground,
      dividerColor: colors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.primaryText,
        ),
        iconTheme: IconThemeData(
          color: colors.primaryText,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colors.primaryText,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.primaryText,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colors.primaryText,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.primaryText,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colors.primaryText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colors.secondaryText,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.primaryText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(
            color: colors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: 14,
          color: colors.secondaryText,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: colors.secondaryText.withOpacity(0.7),
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
        errorStyle: TextStyle(
          color: colors.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusMedium,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(88, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusMedium,
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(88, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusMedium,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: colors.cardBackground,
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMedium,
        ),
        margin: const EdgeInsets.all(spacingSmall),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.primaryText,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLarge,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.disabled;
          }
          return colorScheme.primary;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.disabled;
          }
          return colorScheme.primary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusSmall,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colors.secondaryText,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        elevation: elevationMedium,
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colors.secondaryText,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: TextStyle(
          color: colors.primaryText,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMedium,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMedium,
        ),
      ),
    );
  }

  static Color get primaryColor => colors.primary;
  static Color get secondaryColor => colors.secondary;
  static Color get tertiaryColor => colors.tertiary;
  static Color get successColor => colors.success;
  static Color get warningColor => colors.warning;
  static Color get errorColor => colors.error;
  static Color get backgroundColor => colors.surface;
  static Color get surfaceColor => colors.surface;
  static Color get cardBackgroundColor => colors.cardBackground;
  static Color get primaryTextColor => colors.primaryText;
  static Color get secondaryTextColor => colors.secondaryText;
  static Color get disabledColor => colors.disabled;

  // Schedule specific colors
  static Color get scheduleTextColor => colors.scheduleText;
  static Color get scheduleIconColor => colors.scheduleIcon;
  static Color get scheduleHeaderColor => colors.scheduleHeader;
  static Color get scheduleSubtextColor => colors.scheduleSubtext;
  static Color get scheduleBackgroundColor => colors.scheduleBackground;
  static Color get scheduleCardColor => colors.scheduleCard;
  static Color get scheduleSelectedItemColor => colors.scheduleSelectedItem;
  static Color get scheduleHighlightColor => colors.scheduleHighlight;
  static Color get dividerColor => colors.divider;
  static Color get borderColor => colors.border;
}

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color success;
  final Color warning;
  final Color error;
  final Color surface;
  final Color cardSurface;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color disabled;
  final Color scheduleText;
  final Color scheduleIcon;
  final Color scheduleHeader;
  final Color scheduleSubtext;
  final Color scheduleBackground;
  final Color scheduleCard;
  final Color scheduleSelectedItem;
  final Color scheduleHighlight;
  final Color divider;
  final Color border;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
    required this.error,
    required this.surface,
    required this.cardSurface,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.disabled,
    required this.scheduleText,
    required this.scheduleIcon,
    required this.scheduleHeader,
    required this.scheduleSubtext,
    required this.scheduleBackground,
    required this.scheduleCard,
    required this.scheduleSelectedItem,
    required this.scheduleHighlight,
    required this.divider,
    required this.border,
  });
}
