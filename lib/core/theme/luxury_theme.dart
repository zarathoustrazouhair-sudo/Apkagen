import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkNavy = Color(0xFF0A192F);
  static const Color gold = Color(0xFFD4AF37);
  static const Color offWhite = Color(0xFFF8F8F8);
  static const Color errorRed = Color(0xFFCF6679);

  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkNavy,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: gold,
        surface: darkNavy,
        background: darkNavy,
        error: errorRed,
        onPrimary: darkNavy,
        onSecondary: darkNavy,
        onSurface: offWhite,
        onBackground: offWhite,
        onError: darkNavy,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          color: gold,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: gold,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          color: gold,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: offWhite,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.lato(
          color: offWhite,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.lato(
          color: offWhite.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkNavy.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: gold.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: gold),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(color: gold.withOpacity(0.8)),
        hintStyle: TextStyle(color: offWhite.withOpacity(0.5)),
      ),
    );
  }
}
