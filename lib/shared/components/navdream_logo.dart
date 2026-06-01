import 'package:flutter/material.dart';

import '../../app/theme/infra_theme.dart';

class NavdreamLogo extends StatelessWidget {
  const NavdreamLogo({
    super.key,
    this.size = 48,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.showBorder = false,
    this.showShadow = false,
  });

  static const assetPath = 'assets/branding/navdream_logo.png';

  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF020814),
        borderRadius: radius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.26),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      foregroundDecoration: showBorder
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: InfraColors.gold.withValues(alpha: 0.34),
                width: 1,
              ),
            )
          : null,
      child: Image.asset(
        assetPath,
        fit: fit,
        filterQuality: FilterQuality.high,
        semanticLabel: 'NAVDREAM logo',
      ),
    );
  }
}
