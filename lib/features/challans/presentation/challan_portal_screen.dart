import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/theme/infra_theme.dart';
import '../application/challan_providers.dart';
import '../data/challan_portal_adapter.dart';
import '../domain/challan_portal.dart';
import 'widgets/portal_security_notice.dart';

/// Top-level in-app WebView for the Bihar Government e-Pass portal.
///
/// Security model:
///   * Navigation is restricted to HTTPS on `khanansoft.bihar.gov.in` (and its
///     subdomains). Anything else opens in the OS browser.
///   * Invalid TLS certificates are rejected — the error is surfaced, never
///     bypassed.
///   * No generic JavaScript bridge is installed. There is exactly one
///     injected capability: read the rendered result markup on demand.
///   * File access and file-URL navigation are never enabled.
///   * CAPTCHA, login and the portal's Search button are operated only by the
///     user. This screen never fills a CAPTCHA, never submits credentials and
///     never auto-submits a form guarded by human verification.
///   * Nothing from the session — cookies, credentials, CAPTCHA values or page
///     HTML — is logged or persisted.
class ChallanPortalScreen extends ConsumerStatefulWidget {
  const ChallanPortalScreen({
    super.key,
    required this.portal,
    required this.challanNumber,
    required this.financialYear,
  });

  /// Which state government portal to open.
  final ChallanPortal portal;

  final String challanNumber;
  final String financialYear;

  @override
  ConsumerState<ChallanPortalScreen> createState() =>
      _ChallanPortalScreenState();
}

class _ChallanPortalScreenState extends ConsumerState<ChallanPortalScreen> {
  WebViewController? _controller;
  bool _loading = true;
  bool _prefilled = false;
  late String _currentUrl = widget.portal.url;
  String? _blockedNotice;
  String? _tlsError;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  /// Host allow-list for the portal currently being shown.
  PortalNavigationPolicy get _navigationPolicy =>
      PortalNavigationPolicy(allowedHost: widget.portal.host);

  void _initController() {
    if (!ChallanPortalSupport.supportsInAppWebView()) return;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_navigationPolicy.allowsInApp(request.url)) {
              return NavigationDecision.navigate;
            }
            // Unrelated or non-HTTPS destinations leave the app entirely.
            _openExternally(request.url);
            return NavigationDecision.prevent;
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _currentUrl = url;
              _prefilled = false;
              _tlsError = null;
            });
          },
          onPageFinished: (url) async {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _currentUrl = url;
            });
            await _prefillFormFields();
          },
          onHttpError: (error) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          // Invalid certificates are never accepted: an untrusted chain on a
          // government portal is a hard stop, not a warning to click through.
          onSslAuthError: (error) {
            error.cancel();
            if (!mounted) return;
            setState(() {
              _loading = false;
              _tlsError =
                  'The portal presented an invalid security certificate. '
                  'The connection was blocked. Do not enter any credentials.';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.portal.url));

    _controller = controller;
  }

  Future<void> _openExternally(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (mounted) {
      setState(() {
        _blockedNotice =
            'That link points outside the government portal, so it opened in '
            'your browser instead.';
      });
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Fills the financial year and challan number after the page loads.
  ///
  /// Dispatches the `input`/`change` events ASP.NET WebForms controls listen for
  /// so postback validation sees the values. It deliberately does not touch the
  /// CAPTCHA field and never clicks Search — the user stays in control, and the
  /// values remain editable.
  Future<void> _prefillFormFields() async {
    final controller = _controller;
    if (controller == null || _prefilled) return;

    final script =
        '''
(function() {
  try {
    var year = ${jsonEncode(widget.financialYear)};
    var challan = ${jsonEncode(widget.challanNumber)};
    // Jharkhand's page has no financial-year selector at all.
    var fillYear = ${widget.portal.hasFinancialYearSelector};

    function fire(el) {
      el.dispatchEvent(new Event('input', { bubbles: true }));
      el.dispatchEvent(new Event('change', { bubbles: true }));
    }

    // Never touch anything that looks like a CAPTCHA or a credential field.
    function isProtected(el) {
      var key = ((el.id || '') + ' ' + (el.name || '')).toLowerCase();
      return key.indexOf('captcha') >= 0 || key.indexOf('capcha') >= 0 ||
             key.indexOf('password') >= 0 || key.indexOf('pwd') >= 0 ||
             key.indexOf('otp') >= 0 || el.type === 'password';
    }

    var selects = fillYear ? document.querySelectorAll('select') : [];
    for (var i = 0; i < selects.length; i++) {
      var sel = selects[i];
      if (isProtected(sel)) continue;
      for (var j = 0; j < sel.options.length; j++) {
        var text = (sel.options[j].text || '').replace(/\\s/g, '');
        var val = (sel.options[j].value || '').replace(/\\s/g, '');
        var want = year.replace(/\\s/g, '');
        var wantShort = want.replace(/-\\d{2}(\\d{2})\$/, '-\$1');
        if (text === want || val === want || text === wantShort || val === wantShort) {
          sel.selectedIndex = j;
          fire(sel);
          break;
        }
      }
    }

    var inputs = document.querySelectorAll('input[type=text], input:not([type])');
    for (var k = 0; k < inputs.length; k++) {
      var input = inputs[k];
      if (isProtected(input)) continue;
      var id = ((input.id || '') + ' ' + (input.name || '')).toLowerCase();
      if (id.indexOf('challan') >= 0 || id.indexOf('pass') >= 0) {
        input.value = challan;
        fire(input);
        break;
      }
    }
    return 'ok';
  } catch (e) {
    return 'skip';
  }
})();
''';

    try {
      await controller.runJavaScript(script);
      if (mounted) setState(() => _prefilled = true);
    } catch (_) {
      // Prefill is a convenience only. If the portal's markup changed, the user
      // simply types the values themselves.
    }
  }

  /// The single extraction capability exposed to the page.
  ///
  /// Returns the rendered markup of the result region so the parser (in Dart,
  /// where it is unit-testable) can read it. Scripts, styles, inputs and any
  /// CAPTCHA image are stripped before the markup leaves the page, so no
  /// credential or challenge data is ever handed back.
  Future<String?> readResultHtml() async {
    final controller = _controller;
    if (controller == null) return null;

    const script = '''
(function() {
  try {
    var root = document.body;
    if (!root) return '';
    var clone = root.cloneNode(true);
    var strip = clone.querySelectorAll(
      'script, style, noscript, img, iframe, input[type=password], input[type=hidden]'
    );
    for (var i = 0; i < strip.length; i++) {
      strip[i].parentNode && strip[i].parentNode.removeChild(strip[i]);
    }
    return clone.innerHTML;
  } catch (e) {
    return '';
  }
})();
''';

    try {
      final result = await controller.runJavaScriptReturningResult(script);
      final raw = result is String ? result : result.toString();
      return _unwrapJsString(raw);
    } catch (_) {
      return null;
    }
  }

  /// Platform WebViews return JS strings either raw (Android) or JSON-quoted
  /// (WKWebView), so normalize both shapes.
  static String _unwrapJsString(String raw) {
    if (raw.length >= 2 && raw.startsWith('"') && raw.endsWith('"')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is String) return decoded;
      } catch (_) {
        // Fall through to the raw value.
      }
    }
    return raw;
  }

  Future<void> _capture() async {
    final controller = ref.read(challanFlowControllerProvider.notifier);
    final captured = await controller.captureFromPortal(readResultHtml);
    if (!mounted) return;
    // Returning either way hands control back to the flow screen, which renders
    // the preview on success or the actionable error on failure.
    Navigator.of(context).pop(captured);
  }

  Future<void> _clearSession() async {
    final controller = _controller;
    if (controller == null) return;
    await WebViewCookieManager().clearCookies();
    await controller.clearCache();
    await controller.clearLocalStorage();
    await controller.loadRequest(Uri.parse(widget.portal.url));
    if (!mounted) return;
    setState(() {
      _prefilled = false;
      _blockedNotice = 'Portal session cleared.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final state = ref.watch(challanFlowControllerProvider);
    final host = Uri.tryParse(_currentUrl)?.host ?? widget.portal.host;

    return Scaffold(
      backgroundColor: InfraColors.background,
      appBar: AppBar(
        title: Text('${widget.portal.stateName} Government Portal'),
        actions: [
          IconButton(
            tooltip: 'Refresh portal',
            icon: const Icon(Icons.refresh),
            onPressed: controller == null ? null : () => controller.reload(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'external':
                  _openExternally(widget.portal.url);
                case 'clear':
                  _clearSession();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'external', child: Text('Open externally')),
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear portal session'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: PortalSecurityNotice(
              host: host,
              stateName: widget.portal.stateName,
              dense: true,
            ),
          ),
          if (_tlsError != null)
            _Banner(
              text: _tlsError!,
              color: InfraColors.red,
              icon: Icons.gpp_bad_outlined,
              onDismiss: () => setState(() => _tlsError = null),
            ),
          if (_blockedNotice != null)
            _Banner(
              text: _blockedNotice!,
              color: InfraColors.orange,
              icon: Icons.info_outline,
              onDismiss: () => setState(() => _blockedNotice = null),
            ),
          Expanded(
            child: controller == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        ChallanPortalSupport.unsupportedPlatformNotice,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      WebViewWidget(controller: controller),
                      if (_loading) const LinearProgressIndicator(minHeight: 3),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: InfraColors.surface,
                border: Border(top: BorderSide(color: InfraColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back to LedgerPro'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: controller == null || state.isCapturing
                          ? null
                          : _capture,
                      icon: state.isCapturing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_done_outlined, size: 18),
                      label: const Text('Capture displayed details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11.5))),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 16),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
