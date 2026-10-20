import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';

/// Visual treatment scoped to the challan workspace, including all five steps.
class ChallanWorkspaceTheme extends StatelessWidget {
  const ChallanWorkspaceTheme({super.key, required this.child});

  static const background = Color(0xFFF3F5F7);
  static const field = Color(0xFFF8FAFC);
  static const gold = Color(0xFFDEC592);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: InfraColors.border),
    );
    final label = base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(primary: InfraColors.navy),
        scaffoldBackgroundColor: background,
        textTheme: base.textTheme.copyWith(
          titleMedium: base.textTheme.titleMedium?.copyWith(
            color: InfraColors.navy,
            fontSize: 15,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            color: InfraColors.navy,
            fontSize: 15,
          ),
        ),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: InfraColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 68,
          titleSpacing: 20,
          titleTextStyle: base.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: InfraColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: field,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: outline,
          enabledBorder: outline,
          focusedBorder: outline.copyWith(
            borderSide: const BorderSide(color: InfraColors.navy, width: 1.5),
          ),
          errorBorder: outline.copyWith(
            borderSide: const BorderSide(color: InfraColors.red),
          ),
          prefixIconColor: InfraColors.textSecondary,
          suffixIconColor: InfraColors.textSecondary,
          hintStyle: const TextStyle(
            color: InfraColors.textSecondary,
            fontSize: 14,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: InfraColors.navy,
            foregroundColor: Colors.white,
            minimumSize: const Size(56, 54),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: label?.copyWith(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: InfraColors.navy,
            minimumSize: const Size(56, 52),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            side: const BorderSide(color: InfraColors.border),
            textStyle: label?.copyWith(color: InfraColors.navy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          side: const BorderSide(color: Color(0xFF98A2B3), width: 1.5),
          fillColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? InfraColors.navy : null,
          ),
          checkColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      child: child,
    );
  }
}

class ChallanPanel extends StatelessWidget {
  const ChallanPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InfraColors.border),
        boxShadow: [
          BoxShadow(
            color: InfraColors.navy.withValues(alpha: 0.025),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: InfraColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: InfraColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
