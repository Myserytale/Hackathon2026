import 'package:flutter/material.dart';
import 'roeid_theme.dart';

/// Backward-compatible accessors for existing Vet screens.
class AppTheme {
  static ThemeData get lightTheme => RoeidTheme.light();

  static const Color background = RoeidTheme.background;
  static const Color textMain = RoeidTheme.textPrimary;
  static const Color primaryAction = Color(0xFF1565C0);
  static const Color secondaryAction = RoeidTheme.error;
  static const Color accentBlue = Color(0xFF0D47A1);
  static const Color charcoal = RoeidTheme.textPrimary;
  static const Color ledgerGreen = RoeidTheme.success;
}
