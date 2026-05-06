import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Main App Colors
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.grey,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.grey,
        fontSize: 12,
      ),
      titleLarge: TextStyle(
        color: AppColors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input / TextField Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      hintStyle: const TextStyle(color: AppColors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 2,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.iconInactive,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
  );

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF121212),

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: const Color(0xFF1E1E1E),
      error: AppColors.error,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input / TextField Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 2,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFF757575),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF333333),
      thickness: 1,
    ),
  );
}