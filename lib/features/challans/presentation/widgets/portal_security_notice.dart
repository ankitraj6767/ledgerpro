import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';

/// The mandatory disclosure shown wherever the government portal is reachable.
///
/// Two jobs: make the real government domain unmistakable (anti-phishing), and
/// state plainly that LedgerPro neither stores credentials nor touches CAPTCHA.
class PortalSecurityNotice extends StatelessWidget {
  const PortalSecurityNotice({
    super.key,
    required this.host,
    this.dense = false,
  });

  /// The full government domain, displayed prominently.
  final String host;

  final bool dense;

  static const message =
      'You are viewing the Bihar Government portal. Complete CAPTCHA or login '
      'manually. LedgerPro never stores your government credentials.';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 10 : 14),
      decoration: BoxDecoration(
        color: InfraColors.royalBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InfraColors.royalBlue.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: InfraColors.royalBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: InfraColors.royalBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: dense ? 4 : 6),
          Text(
            message,
            style: TextStyle(
              fontSize: dense ? 11 : 12,
              height: 1.35,
              color: InfraColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner used when the device cannot host the in-app portal WebView, or when
/// the device is offline. Explains the fallback and what it means for the saved
/// record's verification status.
class PortalFallbackNotice extends StatelessWidget {
  const PortalFallbackNotice({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.color = InfraColors.orange,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: InfraColors.textSecondary,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
