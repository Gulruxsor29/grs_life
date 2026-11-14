import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0B0D);
  static const Color backgroundSecondary = Color(0xFF151518);
  static const Color card = Color(0xFF1D1D21);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color copper = Color(0xFFB87333);
  static const Color textPrimary = Color(0xFFF5F3F0);
  static const Color textSecondary = Color(0xFF929096);

  static const Color success = Color(0xFF6FCF97);
  static const Color danger = Color(0xFFEB6B6B);
  static const Color warning = Color(0xFFE2B93B);
  static const Color info = Color(0xFF6B9FE8);
  static const Color violet = Color(0xFF9B7EDE);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [roseGold, copper],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  static const LinearGradient glowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1AB76E79),
      Color(0x000B0B0D),
    ],
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.roseGold,
      secondary: AppColors.copper,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    ),
  );
  return base.copyWith(
    cardColor: AppColors.card,
    dividerColor: Colors.white.withOpacity(0.06),
    splashColor: Colors.white.withOpacity(0.04),
    highlightColor: Colors.white.withOpacity(0.03),
    textTheme: buildTextTheme(base.textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textPrimary,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      modalBackgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.roseGold, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.roseGold,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.roseGold,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: Colors.white.withOpacity(0.14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(64, 48),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.roseGold : AppColors.textSecondary),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? AppColors.roseGold.withOpacity(0.35)
              : AppColors.card),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.roseGold : Colors.transparent),
      side: BorderSide(color: AppColors.textSecondary.withOpacity(0.6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      headerBackgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.roseGold,
      thumbColor: AppColors.roseGold,
      inactiveTrackColor: AppColors.card,
    ),
  );
}

TextTheme buildTextTheme(TextTheme base) {
  const family = 'sans-serif';
  TextStyle t(double size, FontWeight weight, Color color, [double spacing = 0]) => TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
      );
  return base.copyWith(
    displayLarge: t(34, FontWeight.w700, AppColors.textPrimary, -0.5),
    displayMedium: t(28, FontWeight.w700, AppColors.textPrimary, -0.4),
    displaySmall: t(24, FontWeight.w700, AppColors.textPrimary, -0.3),
    headlineMedium: t(20, FontWeight.w700, AppColors.textPrimary, -0.2),
    headlineSmall: t(18, FontWeight.w700, AppColors.textPrimary),
    titleLarge: t(17, FontWeight.w700, AppColors.textPrimary),
    titleMedium: t(15, FontWeight.w600, AppColors.textPrimary),
    titleSmall: t(13, FontWeight.w600, AppColors.textPrimary),
    bodyLarge: t(15, FontWeight.w400, AppColors.textPrimary),
    bodyMedium: t(14, FontWeight.w400, AppColors.textPrimary),
    bodySmall: t(12, FontWeight.w400, AppColors.textSecondary),
    labelLarge: t(14, FontWeight.w700, AppColors.textPrimary),
    labelMedium: t(12, FontWeight.w600, AppColors.textSecondary),
    labelSmall: t(10, FontWeight.w600, AppColors.textSecondary),
  );
}
