import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RoeidPortal { farmer, vet, admin }

/// Which portal this app instance is — change only this line per app copy.
const RoeidPortal kPortal = RoeidPortal.admin;

class RoeidPortalConfig {
  const RoeidPortalConfig({
    required this.primary,
    required this.primaryDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final Color primary;
  final Color primaryDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
}

class RoeidBrand extends ThemeExtension<RoeidBrand> {
  const RoeidBrand(this.config);

  final RoeidPortalConfig config;

  Color get primary => config.primary;
  Color get primaryDark => config.primaryDark;

  @override
  RoeidBrand copyWith({RoeidPortalConfig? config}) => RoeidBrand(config ?? this.config);

  @override
  RoeidBrand lerp(covariant ThemeExtension<RoeidBrand>? other, double t) {
    if (other is! RoeidBrand) return this;
    return RoeidBrand(config);
  }
}

extension RoeidContext on BuildContext {
  RoeidBrand get roeid => Theme.of(this).extension<RoeidBrand>()!;
}

class RoeidTheme {
  static const background = Color(0xFFF4F7FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A2332);
  static const textSecondary = Color(0xFF64748B);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
  static const border = Color(0xFFE2E8F0);

  static const double radiusCard = 16;
  static const double radiusButton = 12;
  static const double radiusInput = 12;

  static const Map<RoeidPortal, RoeidPortalConfig> configs = {
    RoeidPortal.farmer: RoeidPortalConfig(
      primary: Color(0xFF2E7D32),
      primaryDark: Color(0xFF1B5E20),
      icon: Icons.agriculture_rounded,
      title: 'Farmer Portal',
      subtitle: 'Digital wallet, animals & subsidy status',
      badge: 'FARMER',
    ),
    RoeidPortal.vet: RoeidPortalConfig(
      primary: Color(0xFF1565C0),
      primaryDark: Color(0xFF0D47A1),
      icon: Icons.medical_services_rounded,
      title: 'Veterinary Portal',
      subtitle: 'Health certificates & incident tracking',
      badge: 'VET',
    ),
    RoeidPortal.admin: RoeidPortalConfig(
      primary: Color(0xFF5E35B1),
      primaryDark: Color(0xFF4527A0),
      icon: Icons.admin_panel_settings_rounded,
      title: 'APIA Admin Portal',
      subtitle: 'Subsidy validation & transparency ledger',
      badge: 'ADMIN',
    ),
  };

  static RoeidPortalConfig config([RoeidPortal? portal]) =>
      configs[portal ?? kPortal]!;

  static ThemeData light([RoeidPortal? portal]) {
    final p = config(portal);
    final baseText = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.primary,
        primary: p.primary,
        onPrimary: Colors.white,
        secondary: p.primaryDark,
        surface: surface,
        onSurface: textPrimary,
        error: error,
      ),
      textTheme: baseText.copyWith(
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        shape: const Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      extensions: [RoeidBrand(p)],
    );
  }
}
