import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// CORES — MODO ESCURO
// ============================================================
class AppColors {
  static const background    = Color(0xFF07001B);
  static const card          = Color(0xFF10042A);
  static const input         = Color(0xFF1C0F3A);
  static const blue          = Color(0xFF00A3FF);
  static const purple        = Color(0xFF9C27FF);
  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFFB3B3CC);

  static const success       = Color(0xFF00C853);
  static const successBg     = Color(0x1A00C853);
  static const danger        = Color(0xFFFF5252);
  static const dangerBg      = Color(0x1AFF5252);
}

// ============================================================
// CORES — MODO CLARO
// ============================================================
class AppColorsLight {
  static const background    = Color(0xFFF0F2FF);
  static const card          = Color(0xFFFFFFFF);
  static const input         = Color(0xFFE8ECFF);
  static const blue          = Color(0xFF0066BB);
  static const purple        = Color(0xFF6A0DAD);
  static const textPrimary   = Color(0xFF0D0D1A);
  static const textSecondary = Color(0xFF444466);

  static const success       = Color(0xFF1B8A3E);
  static const successBg     = Color(0xFFD4EDDA);
  static const danger        = Color(0xFFB71C1C);
  static const dangerBg      = Color(0xFFFFDADA);
}

// ============================================================
// HELPER — retorna cor correta conforme o tema atual
// ============================================================
class AppColorHelper {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color success(BuildContext context) =>
      isDark(context) ? AppColors.success : AppColorsLight.success;

  static Color successBg(BuildContext context) =>
      isDark(context) ? AppColors.successBg : AppColorsLight.successBg;

  static Color danger(BuildContext context) =>
      isDark(context) ? AppColors.danger : AppColorsLight.danger;

  static Color dangerBg(BuildContext context) =>
      isDark(context) ? AppColors.dangerBg : AppColorsLight.dangerBg;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppColors.textPrimary : AppColorsLight.textPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? AppColors.textSecondary : AppColorsLight.textSecondary;

  static Color card(BuildContext context) =>
      isDark(context) ? AppColors.card : AppColorsLight.card;

  static Color input(BuildContext context) =>
      isDark(context) ? AppColors.input : AppColorsLight.input;

  static Color blue(BuildContext context) =>
      isDark(context) ? AppColors.blue : AppColorsLight.blue;
}

// ============================================================
// TEMA ESCURO
// ============================================================
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.blue,
      secondary: AppColors.purple,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    cardColor: AppColors.card,
    dividerColor: AppColors.textSecondary.withOpacity(0.2),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.blue,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.blue,
    ),
  );
}

// ============================================================
// TEMA CLARO
// ============================================================
ThemeData buildAppThemeLight() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColorsLight.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColorsLight.blue,
      secondary: AppColorsLight.purple,
      surface: AppColorsLight.card,
      onSurface: AppColorsLight.textPrimary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColorsLight.textPrimary,
      displayColor: AppColorsLight.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.card,
      foregroundColor: AppColorsLight.textPrimary,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: AppColorsLight.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColorsLight.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(
            color: AppColorsLight.textSecondary, width: 0.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColorsLight.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      labelStyle: const TextStyle(
          color: AppColorsLight.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColorsLight.textSecondary),
    ),
    cardColor: AppColorsLight.card,
    dividerColor: AppColorsLight.textSecondary.withOpacity(0.15),
    iconTheme: const IconThemeData(color: AppColorsLight.textPrimary),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColorsLight.blue,
      unselectedLabelColor: AppColorsLight.textSecondary,
      indicatorColor: AppColorsLight.blue,
    ),
  );
}