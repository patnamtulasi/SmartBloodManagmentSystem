import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Palette - Clean Blood Red & iOS Sky Blue
  static const Color primaryRed = Color(0xFFDC2626); // Vibrant crimson red
  static const Color primaryRedDark = Color(0xFF991B1B);
  static const Color primaryRedLight = Color(0xFFFEF2F2);

  // iOS-inspired Sky Blue & Healthcare Accents
  static const Color skyBlue = Color(0xFF0284C7); // Crisp iOS Sky Blue
  static const Color skyBlueLight = Color(0xFFF0F9FF);
  static const Color skyBlueDark = Color(0xFF0369A1);

  // Pure Bright Whites & Crisp Black Text
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure bright white
  static const Color backgroundSoft = Color(0xFFFFFFFF); // Pure white surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white cards
  
  static const Color borderSubtle = Color(0xFFE2E8F0); // iOS style soft border
  static const Color borderLight = Color(0xFFF1F5F9);

  static const Color textPrimaryLight = Color(0xFF000000); // Pure solid black
  static const Color textSecondaryLight = Color(0xFF1F2937); // Very dark slate / near black
  static const Color textMuted = Color(0xFF4B5563); // Clear dark grey

  // Dark Mode
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444); // SOS Critical
  static const Color emergencyGlow = Color(0xFFFF2A2A);

  // iOS Border Radius standard
  static const double borderRadius = 18.0;
  static const double smallRadius = 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: skyBlue,
        surface: surfaceLight,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimaryLight,
        displayColor: textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1.0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: borderSubtle, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: borderSubtle, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: skyBlue, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: skyBlue,
        surface: surfaceDark,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textPrimaryDark,
        displayColor: textPrimaryDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
