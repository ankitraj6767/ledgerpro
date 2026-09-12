import 'package:flutter/material.dart';

import '../../app/theme/infra_theme.dart';

/// Shared presentation primitives for the LedgerPro workspace.
///
/// These widgets deliberately contain no business logic. They standardize
/// page rhythm, hierarchy, and operational states so feature screens can keep
/// their existing providers and callbacks while adopting one visual system.
class LedgerProSpacing {
  const LedgerProSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const section = 40.0;
}

class LedgerProPage extends StatelessWidget {
  const LedgerProPage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 1480,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < 700 ? 16.0 : 28.0;
    return ColoredBox(
      color: backgroundColor ?? InfraColors.porcelain,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding:
                padding ?? EdgeInsets.fromLTRB(horizontal, 24, horizontal, 32),
            child: child,
          ),
        ),
      ),
    );
  }
}

class LedgerProEyebrow extends StatelessWidget {
  const LedgerProEyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color ?? InfraColors.slate,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.15,
      ),
    );
  }
}

class LedgerProPageHeader extends StatelessWidget {
  const LedgerProPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LedgerProEyebrow(eyebrow),
              const SizedBox(height: LedgerProSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: LedgerProSpacing.sm),
                Text(subtitle!),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: LedgerProSpacing.lg),
          trailing!,
        ],
      ],
    );
  }
}

class LedgerProSurface extends StatelessWidget {
  const LedgerProSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.radius = 14,
    this.shadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? InfraColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: InfraColors.ink.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class LedgerProMetric extends StatelessWidget {
  const LedgerProMetric({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.accent = InfraColors.royalBlue,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData? icon;
  final Color accent;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return LedgerProSurface(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 18, color: accent),
              if (icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasis ? accent : InfraColors.ink,
              fontSize: emphasis ? 26 : 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 5),
            Text(detail!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class LedgerProStatus extends StatelessWidget {
  const LedgerProStatus({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class LedgerProSectionHeader extends StatelessWidget {
  const LedgerProSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class LedgerProSearchField extends StatelessWidget {
  const LedgerProSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class LedgerProEmptyState extends StatelessWidget {
  const LedgerProEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: InfraColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: InfraColors.slate),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!, textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
