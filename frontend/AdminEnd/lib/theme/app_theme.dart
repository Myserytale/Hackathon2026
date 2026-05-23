import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // WCAG 2.1 AA compliant colors
  static const Color primaryColor = Color(0xFF1A1A1A); // Dark Charcoal
  static const Color backgroundColor = Color(0xFFF5F7F9); // Light Grey
  static const Color surfaceColor = Colors.white;
  static const Color accentColor = Color(0xFF0D47A1); // Deep Blue

  static const Color successColor = Color(0xFF2E7D32); // Deep Green
  static const Color errorColor = Color(0xFFC62828); // Dark Red
  static const Color pendingColor = Color(0xFF0277BD); // Blue

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        surface: backgroundColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: primaryColor),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: primaryColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      extensions: const [
        SidebarTheme(backgroundColor: primaryColor, selectedColor: accentColor),
      ],
    );
  }
}

class SidebarTheme extends ThemeExtension<SidebarTheme> {
  final Color backgroundColor;
  final Color selectedColor;

  const SidebarTheme({
    required this.backgroundColor,
    required this.selectedColor,
  });

  @override
  ThemeExtension<SidebarTheme> copyWith({
    Color? backgroundColor,
    Color? selectedColor,
  }) {
    return SidebarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  @override
  ThemeExtension<SidebarTheme> lerp(
    ThemeExtension<SidebarTheme>? other,
    double t,
  ) {
    if (other is! SidebarTheme) return this;
    return SidebarTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
    );
  }
}
