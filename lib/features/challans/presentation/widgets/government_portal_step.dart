import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../shared/components/infra_components.dart';
import '../../application/challan_providers.dart';
import '../../data/bihar_epass_portal_adapter.dart';
import '../../data/challan_portal_adapter.dart';
import 'portal_security_notice.dart';

/// Step 2 — hand off to the government portal.
///
/// On Android, iOS and macOS this opens the in-app WebView. On Windows and Linux
/// there is no WebView implementation, so the portal opens in the OS browser and
/// the user is told the resulting entry will be `manual_unverified`.
class GovernmentPortalStep extends ConsumerWidget {
  const GovernmentPortalStep({
    super.key,
    required this.onOpenPortal,
    required this.onManualEntry,
    required this.onBack,
  });

  final VoidCallback onOpenPortal;
  final VoidCallback onManualEntry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challanFlowControllerProvider);
    final online = ref.watch(networkOnlineProvider);
    final webViewSupported = ChallanPortalSupport.supportsInAppWebView();

    return SectionCard(
      title: 'Government Portal',
      icon: Icons.account_balance_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PortalSecurityNotice(host: BiharEPassWebViewAdapter.host),
          const SizedBox(height: 14),

          _summaryRow('Challan number', state.challanNumber),
          _summaryRow('Financial year', state.financialYear),
          const SizedBox(height: 14),

          const Text(
            'What happens next',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const _Steps(
            items: [
              'The portal opens with your financial year and challan number '
                  'filled in.',
              'You complete the CAPTCHA (and login, if the portal asks).',
              'You press the portal\'s own Search button.',
              'Once the result is on screen, press "Capture displayed details".',
            ],
          ),
          const SizedBox(height: 16),

          if (!online)
            PortalFallbackNotice(
              title: 'Internet required',
              message:
                  'Government portal verification needs an internet connection. '
                  'Reconnect to open the portal. You can still browse challans '
                  'you already saved.',
              icon: Icons.wifi_off_outlined,
              color: InfraColors.red,
              action: OutlinedButton.icon(
                onPressed: onManualEntry,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Add as manual entry instead'),
              ),
            )
          else if (!webViewSupported)
            PortalFallbackNotice(
              title: 'Desktop fallback',
              message: ChallanPortalSupport.unsupportedPlatformNotice,
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _openExternally,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open portal in browser'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onManualEntry,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Add manual entry'),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenPortal,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Government Portal'),
              ),
            ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: InfraColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(BiharEPassWebViewAdapter.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    color: InfraColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
