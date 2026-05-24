import 'package:flutter/material.dart';
import 'roeid_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => RoeidTheme.light();

  static Color get primaryColor => RoeidTheme.config().primaryDark;
  static Color get backgroundColor => RoeidTheme.background;
  static Color get surfaceColor => RoeidTheme.surface;
  static Color get accentColor => RoeidTheme.config().primary;
  static Color get successColor => RoeidTheme.success;
  static Color get errorColor => RoeidTheme.error;
  static Color get pendingColor => RoeidTheme.config().primary;
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
