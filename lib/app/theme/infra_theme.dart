import 'package:flutter/material.dart';

/// Navdream Infra premium design system colors and theme.
class InfraColors {
  const InfraColors._();

  static const navy = Color(0xFF03152E); // deep navy header
  static const royalBlue = Color(0xFF1D74F5); // primary action
  static const gold = Color(0xFFD6A83A); // accent
  static const green = Color(0xFF138A4A); // success / received
  static const orange = Color(0xFFF59E0B); // warning
  static const red = Color(0xFFDC2626); // danger
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF101828);
  static const textSecondary = Color(0xFF667085);
  static const border = Color(0xFFE4E7EC);
}

class InfraTheme {
  const InfraTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: InfraColors.royalBlue,
      brightness: Brightness.light,
      primary: InfraColors.royalBlue,
      secondary: InfraColors.gold,
      surface: InfraColors.surface,
      error: InfraColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: InfraColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: InfraColors.navy,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: InfraColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: InfraColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: InfraColors.royalBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: InfraColors.border),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: InfraColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: InfraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: InfraColors.royalBlue,
            width: 1.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: InfraColors.navy,
        indicatorColor: InfraColors.royalBlue.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? InfraColors.gold
                : Colors.white70,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            color: states.contains(WidgetState.selected)
                ? InfraColors.gold
                : Colors.white70,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Status color mapping for project statuses and fund statuses.
  static Color statusColor(String status) {
    switch (status) {
      case 'active':
      case 'fully_received':
        return InfraColors.green;
      case 'planning':
      case 'sanctioned':
        return InfraColors.royalBlue;
      case 'completed':
        return InfraColors.royalBlue;
      case 'on_hold':
      case 'delayed':
      case 'partially_received':
        return InfraColors.orange;
      case 'cancelled':
        return InfraColors.red;
      default:
        return InfraColors.textSecondary;
    }
  }
}
