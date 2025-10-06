import 'package:flutter/material.dart';

/// Blue and Peach color scheme based on the visual prototype
class AppColors {
  // Primary Blue - vibrant medium blue for top bar, pet card borders, FAB
  static const Color primaryBlue = Color(0xFF1E90FF);
  
  // Primary Orange/Peach - warm medium orange for upcoming bar, dashed borders
  static const Color primaryOrange = Color(0xFFFFA500);
  
  // Secondary Orange - faded/lighter version for text elements
  static const Color secondaryOrange = Color(0xFFFFB84D);
  
  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color onBackground = Color(0xFF2C2C2C);
  static const Color onSurface = Color(0xFF2C2C2C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Error and success colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
  
  // Border colors
  static const Color borderBlue = Color(0xFF1E90FF);
  static const Color borderOrange = Color(0xFFFFA500);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.primaryOrange,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurface,
      onError: AppColors.onPrimary,
    ),
    
    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderBlue, width: 1),
      ),
    ),
    
    // FloatingActionButton theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
    ),
    
    // ElevatedButton theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // FilledButton theme
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // TextButton theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderBlue),
      ),
    ),
    
    // SnackBar theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.onBackground,
      contentTextStyle: TextStyle(color: AppColors.background),
      actionTextColor: AppColors.primaryBlue,
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: AppColors.primaryBlue,
    ),
    
    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.onBackground,
      ),
      bodyMedium: TextStyle(
        color: AppColors.onBackground,
      ),
      bodySmall: TextStyle(
        color: AppColors.onBackground,
      ),
      labelLarge: TextStyle(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: AppColors.onBackground,
      ),
      labelSmall: TextStyle(
        color: AppColors.onBackground,
      ),
    ),
  );
}
