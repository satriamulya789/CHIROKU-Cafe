import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Color Palette
class AppColors {
  // Brown Palette
  static const Color brownLight = Color(0xfff5f2f1);
  static const Color brownLightHover = Color(0xffeceaea);
  static const Color brownLightActive = Color(0xffded7d5);

  static const Color brownNormal = Color(0xff967676);
  static const Color brownNormalHover = Color(0xff87716a);
  static const Color brownNormalActive = Color(0xff78655e);

  static const Color brownDark = Color(0xff715559);
  static const Color brownDarkHover = Color(0xff5a4c47);
  static const Color brownDarkActive = Color(0xff443935);

  static const Color brownDarker = Color(0xff352c29);

  // White Palette
  static const Color white = Color(0xffffffff);
  static const Color whiteHover = Color(0xfff2f2f2);
  static const Color whiteActive = Color(0xffe6e6e6);

  // Black / Dark Palette
  static const Color black = Color(0xff000000);
  static const Color blackHover = Color(0xff0d0d0d);
  static const Color blackActive = Color(0xff1a1a1a);
}

/// App Theme Configuration
class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brownNormal,
      brightness: Brightness.light,
      primary: AppColors.brownNormal,
      secondary: AppColors.brownDark,
      surface: AppColors.white,
    ),
    textTheme: GoogleFonts.montserratTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.brownNormal,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownNormal,
        foregroundColor: AppColors.white,
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColors.white,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brownNormal,
      brightness: Brightness.dark,
      primary: AppColors.brownNormal,
      secondary: AppColors.brownLight,
      surface: AppColors.brownDarker,
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.brownDarker,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownNormal,
        foregroundColor: AppColors.white,
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.brownDarker,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColors.brownDarker,
    ),
  );
}
