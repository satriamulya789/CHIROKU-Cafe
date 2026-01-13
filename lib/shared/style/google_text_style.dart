import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // ==================== Display Text (Extra Large) ====================

  /// Display Large - For hero sections and splash screens
  static TextStyle displayLarge = GoogleFonts.montserrat(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  /// Display Medium - For prominent headers
  static TextStyle displayMedium = GoogleFonts.montserrat(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Display Small - For section headers
  static TextStyle displaySmall = GoogleFonts.montserrat(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  // ==================== Headings ====================

  /// Heading 1 - Main page titles
  static TextStyle h1 = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Heading 2 - Section titles
  static TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Heading 3 - Subsection titles
  static TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Heading 4 - Card titles
  static TextStyle h4 = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  /// Heading 5 - List item titles
  static TextStyle h5 = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  /// Heading 6 - Small section headers
  static TextStyle h6 = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  // ==================== Subtitle Text ====================

  /// Subtitle Large - For secondary headers
  static TextStyle subtitleLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  /// Subtitle Medium - For supporting text under headers
  static TextStyle subtitleMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Subtitle Small - For small supporting text
  static TextStyle subtitleSmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // ==================== Body Text ====================

  /// Body Large - Main content text
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - Standard body text
  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  /// Body Small - Compact body text
  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // ==================== Body Text Bold Variants ====================

  /// Body Large Bold - Emphasized content
  static TextStyle bodyLargeBold = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium Bold - Emphasized standard text
  static TextStyle bodyMediumBold = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.5,
  );

  /// Body Small Bold - Emphasized compact text
  static TextStyle bodySmallBold = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // ==================== Button Text ====================

  /// Button Large - For prominent CTAs
  static TextStyle buttonLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Button Medium - Standard buttons
  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Button Small - Compact buttons
  static TextStyle buttonSmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Button Text - Text buttons
  static TextStyle buttonText = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ==================== Caption / Label ====================

  /// Label Large - Form labels
  static TextStyle labelLarge = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Label Medium - Standard labels
  static TextStyle label = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Label Small - Compact labels
  static TextStyle labelSmall = GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Caption - Supplementary text
  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  /// Caption Small - Very small supplementary text
  static TextStyle captionSmall = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // ==================== Overline ====================

  /// Overline - For category labels and tags
  static TextStyle overline = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  /// Overline Large - Larger category labels
  static TextStyle overlineLarge = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  // ==================== Link Text ====================

  /// Link - Standard hyperlinks
  static TextStyle link = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    decoration: TextDecoration.underline,
  );

  /// Link Small - Compact hyperlinks
  static TextStyle linkSmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    decoration: TextDecoration.underline,
  );

  // ==================== Specialized Styles ====================

  /// Price Large - For prominent prices
  static TextStyle priceLarge = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Price Medium - Standard prices
  static TextStyle priceMedium = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Price Small - Compact prices
  static TextStyle priceSmall = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Number Large - For statistics and metrics
  static TextStyle numberLarge = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Number Medium - Standard numbers
  static TextStyle numberMedium = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Timestamp - For date and time
  static TextStyle timestamp = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // ==================== Status Text ====================

  /// Error Text - For error messages
  static TextStyle error = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  /// Success Text - For success messages
  static TextStyle success = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  /// Warning Text - For warning messages
  static TextStyle warning = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  /// Info Text - For informational messages
  static TextStyle info = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  // ==================== Input Text ====================

  /// Input Text - For text fields
  static TextStyle input = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  /// Input Hint - For placeholder text
  static TextStyle inputHint = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  /// Input Error - For error text in forms
  static TextStyle inputError = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // ==================== Badge & Chip Text ====================

  /// Badge - For notification badges
  static TextStyle badge = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Chip - For filter chips and tags
  static TextStyle chip = GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
  );

  // ==================== Tab Text ====================

  /// Tab Active - For active tab labels
  static TextStyle tabActive = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Tab Inactive - For inactive tab labels
  static TextStyle tabInactive = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ==================== Menu Text ====================

  /// Menu Item - For menu items
  static TextStyle menuItem = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  /// Menu Title - For menu section titles
  static TextStyle menuTitle = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ==================== AppBar Text ====================

  /// AppBar Title Large - For large app bar titles
  static TextStyle appBarTitleLarge = GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// AppBar Title - Standard app bar title
  static TextStyle appBarTitle = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  /// AppBar Title Small - Compact app bar title
  static TextStyle appBarTitleSmall = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  /// AppBar Subtitle - For app bar subtitles
  static TextStyle appBarSubtitle = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  /// AppBar Action - For app bar action text
  static TextStyle appBarAction = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// AppBar Action Small - For compact app bar actions
  static TextStyle appBarActionSmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
