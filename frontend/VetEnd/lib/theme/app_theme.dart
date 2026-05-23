import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF121212);
  static const Color primaryAction = Color(0xFF007A33); // Vibrant Deep Green
  static const Color secondaryAction = Color(0xFFD32F2F); // Vibrant Red for Reject
  static const Color accentBlue = Color(0xFF005EB8); // Bright Blue for ROeID
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color ledgerGreen = Color(0xFF2E7D32);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAction,
        primary: primaryAction,
        secondary: accentBlue,
        surface: background,
        onSurface: textMain,
      ),
      textTheme: GoogleFonts.openSansTextTheme().copyWith(
        displayLarge: GoogleFonts.openSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textMain,
        ),
        headlineMedium: GoogleFonts.openSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        bodyLarge: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textMain,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 18,
          color: textMain,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAction,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 60),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
