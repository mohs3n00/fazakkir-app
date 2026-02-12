import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.islamicBrown,
        secondary: AppColors.islamicGold,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.lightText,
        onSurface: AppColors.lightText,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.lightText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.lightTextSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightText,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.islamicBrown.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      dividerColor: AppColors.lightDivider,
      dividerTheme: DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.islamicGold,
        secondary: AppColors.lightGold,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkText,
        onSurface: AppColors.darkText,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.darkText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.darkTextSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.islamicGold.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      dividerColor: AppColors.darkDivider,
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
    );
  }
}
