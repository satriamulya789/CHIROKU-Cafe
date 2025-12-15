import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Headings
  static TextStyle h1 = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h4 = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h5 = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static TextStyle h6 = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Body Text
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Button Text
  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Caption / Label
  static TextStyle label = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
