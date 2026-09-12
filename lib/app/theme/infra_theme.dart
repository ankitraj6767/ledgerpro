import 'package:flutter/material.dart';

/// LedgerPro visual language.
///
/// The names remain intentionally stable because presentation widgets across
/// the app use these tokens. The palette is semantic: cobalt for action,
/// emerald for healthy money movement, amber for attention, and crimson for
/// destructive or negative states.
class InfraColors {
  const InfraColors._();

  static const ink = Color(0xFF101719);
  static const graphite = Color(0xFF172125);
  static const graphiteSoft = Color(0xFF223037);
  static const porcelain = Color(0xFFF6F7F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEEF1F0);
  static const slate = Color(0xFF667479);
  static const slateLight = Color(0xFF94A0A3);
  static const border = Color(0xFFDDE4E2);
  static const royalBlue = Color(0xFF2457E6);
  static const sapphire = Color(0xFF153CA8);
  static const gold = Color(0xFFB8833D);
  static const green = Color(0xFF12805A);
  static const orange = Color(0xFFC47A16);
  static const red = Color(0xFFC23B42);

  // Compatibility aliases used by existing presentation code.
  static const navy = graphite;
  static const background = porcelain;
  static const textPrimary = ink;
  static const textSecondary = slate;
}

class InfraTheme {
  const InfraTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: InfraColors.royalBlue,
      brightness: Brightness.light,
      primary: InfraColors.royalBlue,
      onPrimary: Colors.white,
      secondary: InfraColors.gold,
      onSecondary: Colors.white,
      surface: InfraColors.surface,
      onSurface: InfraColors.ink,
      error: InfraColors.red,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: InfraColors.porcelain,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
    );
    final text = base.textTheme;

    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: text.displayLarge?.copyWith(
          color: InfraColors.ink,
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: InfraColors.ink,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: InfraColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: InfraColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: text.bodyLarge?.copyWith(
          color: InfraColors.ink,
          fontSize: 15,
          height: 1.45,
        ),
        bodyMedium: text.bodyMedium?.copyWith(
          color: InfraColors.slate,
          fontSize: 13,
          height: 1.4,
        ),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: InfraColors.graphite,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 19,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: InfraColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(
        color: InfraColors.border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: InfraColors.royalBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: InfraColors.ink,
          minimumSize: const Size(56, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: InfraColors.border),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: InfraColors.royalBlue,
          minimumSize: const Size(48, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: InfraColors.slate,
          minimumSize: const Size(44, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: InfraColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(color: InfraColors.slateLight),
        labelStyle: const TextStyle(color: InfraColors.slate),
        prefixIconColor: InfraColors.slate,
        suffixIconColor: InfraColors.slate,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: InfraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: InfraColors.royalBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: InfraColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: InfraColors.red, width: 1.5),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: InfraColors.surfaceMuted,
        selectedColor: InfraColors.royalBlue.withValues(alpha: 0.12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(
          color: InfraColors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: InfraColors.graphite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.white.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.white60,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.white60,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: InfraColors.graphite,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white60),
        selectedLabelTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.white60,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: InfraColors.graphite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(color: Colors.white),
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
