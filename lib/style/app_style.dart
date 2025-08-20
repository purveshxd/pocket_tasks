import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

final isDarkTheme = StateProvider((ref) {
  return true;
});

class AppColors {
  // Shared brand colors
  static const primary = Color(0xFF8E7CFF); // soft violet accent
  static const secondary = Color(0xFF6C63FF);
  static const accent = Color(0xFFB388FF);

  // Dark mode
  static const darkBackground = Color(0xFF1B0033); // deep purple
  static const darkSurface = Color(0xFF2A003F);
  static const darkOutline = Color(0xFF9A8FBF);
  static const darkText = Colors.white;

  // Light mode (softer for eyes, not pure white)
  static const lightBackground = Color(
    0xFFF5F3FF,
  ); // off-white with violet tint
  static const lightSurface = Color(0xFFEDE7FF); // very soft lavender
  static const lightOutline = Color(0xFFB5A9D9);
  static const lightText = Color(0xFF1A1A1A);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      outline: AppColors.darkOutline,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
      titleLarge: TextStyle(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkOutline),
      ),
      hintStyle: const TextStyle(color: AppColors.darkOutline),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    fontFamily: 'Poppins',
  );

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      outline: AppColors.lightOutline,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
      titleLarge: TextStyle(
        color: AppColors.lightText,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface.withValues(alpha: 0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightOutline),
      ),
      hintStyle: const TextStyle(color: AppColors.lightOutline),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
