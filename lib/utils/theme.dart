import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color surfaceGreen = Color(0xFFE8F5E8);
  
  static const Color backgroundLight = Color(0xFFF1F8E9);
  static const Color backgroundDark = Color(0xFF1C1C1C);
  
  static const Color textPrimary = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF388E3C);
  static const Color textLight = Color(0xFFFFFFFF);
  
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  static const Color success = Color(0xFF388E3C);

  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(primaryGreen.value, {
      50: const Color(0xFFE8F5E8),
      100: const Color(0xFFC8E6C9),
      200: const Color(0xFFA5D6A7),
      300: const Color(0xFF81C784),
      400: const Color(0xFF66BB6A),
      500: primaryGreen,
      600: const Color(0xFF43A047),
      700: const Color(0xFF388E3C),
      800: const Color(0xFF2E7D32),
      900: const Color(0xFF1B5E20),
    }),
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGreen,
      surface: surfaceGreen,
      background: backgroundLight,
      error: error,
      onPrimary: textLight,
      onSecondary: textLight,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: textLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: textLight,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: textLight,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGreen),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textPrimary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryGreen,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: primaryGreen,
    ),
    dividerTheme: const DividerThemeData(
      color: lightGreen,
      thickness: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: MaterialColor(primaryGreen.value, {
      50: const Color(0xFFE8F5E8),
      100: const Color(0xFFC8E6C9),
      200: const Color(0xFFA5D6A7),
      300: const Color(0xFF81C784),
      400: const Color(0xFF66BB6A),
      500: primaryGreen,
      600: const Color(0xFF43A047),
      700: const Color(0xFF388E3C),
      800: const Color(0xFF2E7D32),
      900: const Color(0xFF1B5E20),
    }),
    colorScheme: const ColorScheme.dark(
      primary: lightGreen,
      secondary: accentGreen,
      surface: Color(0xFF2C2C2C),
      background: backgroundDark,
      error: error,
      onPrimary: textLight,
      onSecondary: textLight,
      onSurface: textLight,
      onBackground: textLight,
      onError: textLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGreen,
      foregroundColor: textLight,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightGreen,
      foregroundColor: textLight,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGreen),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: accentGreen),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textLight,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textLight,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textLight,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textLight,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: accentGreen,
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: lightGreen,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: lightGreen,
    ),
    dividerTheme: const DividerThemeData(
      color: lightGreen,
      thickness: 1,
    ),
  );
}