import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/infra_theme.dart';
import 'navdream_logo.dart';

/// Styling scoped to the entry screens; the workspace theme stays independent.
class AuthPalette {
  const AuthPalette._();

  static const ink = Color(0xFF102B3F);
  static const midnight = Color(0xFF071C2C);
  static const gold = Color(0xFFDCC18A);
  static const ivory = Color(0xFFF5F3EE);
  static const muted = Color(0xFF657583);
  static const line = Color(0xFFE3E7E9);
}

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AuthPalette.line),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(primary: AuthPalette.ink),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AuthPalette.ink,
            selectionColor: AuthPalette.gold.withValues(alpha: 0.35),
            selectionHandleColor: AuthPalette.ink,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: outline,
            enabledBorder: outline,
            focusedBorder: outline.copyWith(
              borderSide: const BorderSide(color: AuthPalette.ink, width: 1.6),
            ),
            errorBorder: outline.copyWith(
              borderSide: const BorderSide(color: InfraColors.red),
            ),
            focusedErrorBorder: outline.copyWith(
              borderSide: const BorderSide(color: InfraColors.red, width: 1.6),
            ),
            prefixIconColor: AuthPalette.muted,
            suffixIconColor: AuthPalette.muted,
            hintStyle: const TextStyle(
              color: AuthPalette.muted,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: dark ? AuthPalette.midnight : AuthPalette.ivory,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _ArchitecturePainter(dark)),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final padding = constraints.maxWidth < 360 ? 20.0 : 28.0;
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(padding, 28, padding, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (constraints.maxHeight - 52).clamp(
                            0,
                            double.infinity,
                          ),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: SizedBox(
                              width: double.infinity,
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NavdreamLogo(
          size: 54,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          showBorder: true,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: dark ? Colors.white : AuthPalette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'INFRASTRUCTURE',
                style: TextStyle(
                  color: dark ? AuthPalette.gold : AuthPalette.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AuthPalette.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          color: AuthPalette.ink,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AuthPalette.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AuthPalette.ink.withValues(alpha: 0.7),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (loading)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AuthPalette.gold,
                  semanticsLabel: 'Please wait',
                ),
              )
            else
              Icon(icon, size: 20, color: AuthPalette.gold),
          ],
        ),
      ),
    );
  }
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key, required this.text, this.dark = false});

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? const Color(0xFFA3B5C2) : AuthPalette.muted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 15, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 12, height: 1.5),
          ),
        ),
      ],
    );
  }
}

/// Quiet architectural linework, drawn locally with no network or image load.
class _ArchitecturePainter extends CustomPainter {
  const _ArchitecturePainter(this.dark);

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.88, size.height * 0.16);
    canvas.drawCircle(
      origin,
      size.width * 0.75,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                (dark ? const Color(0xFF31556A) : AuthPalette.gold).withValues(
                  alpha: dark ? 0.28 : 0.12,
                ),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: origin, radius: size.width * 0.75),
            ),
    );
    final paint = Paint()
      ..color = (dark ? AuthPalette.gold : AuthPalette.ink).withValues(
        alpha: dark ? 0.09 : 0.04,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final right = size.width;
    for (var i = 0; i < 4; i++) {
      final x = right - 38 - i * 42;
      final y = 65.0 + i * 36;
      canvas.drawRect(Rect.fromLTWH(x, y, 64, 280), paint);
      canvas.drawLine(Offset(x + 32, y), Offset(x + 32, y + 280), paint);
    }
    canvas.drawLine(Offset(right * 0.45, 375), Offset(right, 375), paint);
  }

  @override
  bool shouldRepaint(_ArchitecturePainter oldDelegate) =>
      oldDelegate.dark != dark;
}
