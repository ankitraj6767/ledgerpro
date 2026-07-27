import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Android-only settings. `webview_flutter_android` defaults `useWideViewPort` to
// false, so a portal that needs desktop width has to switch it on explicitly.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Windows-only creation params. The package is a `webview_flutter` platform
// implementation, so importing it costs nothing on mobile — nothing below is
// reachable unless `usesFloatingWebView()` is true.
import 'package:webview_win_floating/webview.dart' as win_webview;

import '../../../app/theme/infra_theme.dart';
import '../application/challan_providers.dart';
import '../data/challan_portal_adapter.dart';
import '../data/portal_markup_reader.dart';
import '../data/portal_prefill.dart';
import '../domain/challan_portal.dart';
import 'widgets/portal_security_notice.dart';

/// Top-level in-app WebView for the state government e-Pass portals.
///
/// Runs on Android, iOS, macOS and Windows. Every platform goes through the same
/// `webview_flutter` API, the same navigation policy and the same extraction
/// script, so a capture on Windows produces byte-identical payloads to Android.
/// Two Windows details are handled explicitly, because WebView2 is hosted as a
/// native floating window rather than a composited platform view:
///   * Flutter widgets cannot paint above the WebView, so the progress bar and
///     the overflow actions are laid out beside it instead of over it.
///   * A JavaScript string result is marshalled as JSON across a COM boundary,
///     so the result markup is pulled in slices rather than one large hop.
///
/// Security model:
///   * Navigation is restricted to HTTPS on the portal's own host (and its
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
  String? _engineError;

  /// Bounded prefill retries for the current page load. ASP.NET pages render
  /// their inputs after a postback, so the field is not always there the instant
  /// the page reports finished.
  int _prefillAttempts = 0;
  static const _maxPrefillAttempts = 6;

  /// True when the platform hosts the WebView as a native floating window.
  bool get _floating => ChallanPortalSupport.usesFloatingWebView();

  /// True when this portal has to be forced to desktop width on this platform.
  bool get _emulatesDesktop =>
      widget.portal.prefersDesktopViewport &&
      ChallanPortalSupport.needsDesktopViewportEmulation();

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

    // Windows has to resolve a writable WebView2 user-data folder first, so its
    // controller is created asynchronously. Mobile and macOS keep the immediate
    // path, which is what the first frame renders.
    if (_floating) {
      unawaited(_initFloatingController());
      return;
    }

    final WebViewController controller;
    try {
      controller = WebViewController();
    } catch (_) {
      _engineError = ChallanPortalSupport.webViewEngineErrorNotice;
      _loading = false;
      return;
    }
    // Assigned before configuring so the very first frame already shows the
    // WebView, exactly as it did before Windows support was added.
    _controller = controller;
    unawaited(_configureController(controller));
  }

  /// Creates the Windows (WebView2) controller.
  ///
  /// WebView2 needs a writable user-data folder. Its default is the folder the
  /// executable sits in, which fails outright for a portable copy extracted to
  /// `C:\Program Files` or any other read-only location — so it is pointed at
  /// the app's own support directory instead.
  Future<void> _initFloatingController() async {
    String? userDataFolder;
    try {
      final directory = await getApplicationSupportDirectory();
      userDataFolder = p.join(directory.path, 'portal_webview');
    } catch (_) {
      // Fall back to the platform default rather than failing the whole screen.
      userDataFolder = null;
    }
    if (!mounted) return;

    final WebViewController controller;
    try {
      // The generated Dart plugin registrant already does this on Windows.
      // Repeating it is idempotent and keeps the portal working regardless of
      // how the host app was bootstrapped.
      win_webview.WindowsWebViewPlatform.registerWith();
      controller = WebViewController.fromPlatformCreationParams(
        win_webview.WindowsWebViewControllerCreationParams(
          userDataFolder: userDataFolder,
        ),
      );
    } catch (_) {
      _reportEngineFailure();
      return;
    }

    // The WebView2 widget is only mounted once the engine has actually accepted
    // the configuration. Mounting it first would attach a native window to a
    // controller that may never come up. The timeout covers an engine that
    // neither succeeds nor reports an error, so the user gets the browser
    // fallback instead of an endless spinner.
    final bool started;
    try {
      started = await _configureController(
        controller,
      ).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      _reportEngineFailure();
      return;
    }
    if (!started || !mounted) return;
    setState(() => _controller = controller);
  }

  /// Applies the shared configuration. Identical on every platform.
  ///
  /// Returns false when the platform WebView rejected it, which means the
  /// OS-level engine never came up.
  Future<bool> _configureController(WebViewController controller) async {
    try {
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.white);
      await controller.setNavigationDelegate(_navigationDelegate(controller));
      // Desktop emulation has to be in place before the first request, so the
      // portal serves its desktop layout from the start rather than swapping
      // themes after load.
      if (_emulatesDesktop) await _applyDesktopSettings(controller);
      await controller.loadRequest(Uri.parse(widget.portal.url));
      return true;
    } catch (_) {
      // On Windows this is almost always a missing Microsoft Edge WebView2
      // runtime. Surface it instead of leaving a blank rectangle.
      _reportEngineFailure();
      return false;
    }
  }

  /// Makes a phone-sized WebView behave like a desktop browser.
  ///
  /// Three things are needed together, and each is load-bearing:
  ///   * a desktop user agent, so the portal's responsive CSS picks its desktop
  ///     layout instead of the collapsed mobile theme;
  ///   * Android's wide-viewport mode, because `webview_flutter_android`
  ///     deliberately defaults `useWideViewPort` to false, which makes the
  ///     WebView ignore the page's viewport width entirely; and
  ///   * zoom, so the user can pinch into a wide result grid.
  ///
  /// The matching `width=1280` viewport is injected per page load in
  /// [_applyDesktopViewport]; `setLoadWithOverviewMode` (already on by default)
  /// then scales that width down to fit the screen.
  Future<void> _applyDesktopSettings(WebViewController controller) async {
    try {
      await controller.setUserAgent(ChallanPortalSupport.desktopUserAgent);
      await controller.enableZoom(true);
      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        await platform.setUseWideViewPort(true);
      }
    } catch (_) {
      // Desktop emulation is a readability improvement, not a requirement: the
      // portal still loads at mobile width if any of this is unsupported.
    }
  }

  /// Lays the page out at a fixed desktop width and scales it to fit.
  Future<void> _applyDesktopViewport(WebViewController controller) async {
    if (!_emulatesDesktop) return;
    const width = ChallanPortalSupport.desktopViewportWidth;
    try {
      await controller.runJavaScript('''
(function() {
  try {
    // Measured before the meta is replaced, so the scale is relative to the
    // real screen rather than to the width we are about to ask for.
    var available = window.innerWidth || document.documentElement.clientWidth || $width;
    var meta = document.querySelector('meta[name=viewport]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.setAttribute('name', 'viewport');
      (document.head || document.documentElement).appendChild(meta);
    }
    var scale = Math.min(1, available / $width);
    meta.setAttribute(
      'content',
      'width=$width, initial-scale=' + scale +
      ', minimum-scale=0.2, maximum-scale=4.0, user-scalable=yes'
    );
    return 'desktop';
  } catch (e) {
    return 'skip';
  }
})();
''');
    } catch (_) {
      // Best effort, exactly as above.
    }
  }

  void _reportEngineFailure() {
    if (!mounted) return;
    setState(() {
      _controller = null;
      _loading = false;
      _engineError = ChallanPortalSupport.webViewEngineErrorNotice;
    });
  }

  /// The delegate closes over [controller] rather than reading `_controller`, so
  /// prefill still runs when the page finishes loading before the WebView widget
  /// has been mounted — which is the normal ordering on Windows.
  NavigationDelegate _navigationDelegate(WebViewController controller) {
    return NavigationDelegate(
      onNavigationRequest: (request) {
        final action = _navigationPolicy.decide(
          url: request.url,
          isMainFrame: request.isMainFrame,
        );
        switch (action) {
          case PortalNavigationAction.allow:
            return NavigationDecision.navigate;
          case PortalNavigationAction.openExternally:
            // Unrelated or non-HTTPS destinations leave the app entirely.
            _openExternally(request.url);
            return NavigationDecision.prevent;
          case PortalNavigationAction.block:
            // A sub-frame the portal loaded itself. Refused quietly — opening
            // the browser for it produced the "that link points outside the
            // government portal" banner on every single MP page load.
            return NavigationDecision.prevent;
        }
      },
      onPageStarted: (url) {
        if (!mounted) return;
        setState(() {
          _loading = true;
          _currentUrl = url;
          _prefilled = false;
          _prefillAttempts = 0;
          _tlsError = null;
        });
      },
      onPageFinished: (url) async {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _currentUrl = url;
        });
        await _applyDesktopViewport(controller);
        await _prefillFormFields(controller);
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
    );
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
  /// CAPTCHA field and never clicks Search or Verify — the user stays in
  /// control, and the values remain editable.
  ///
  /// Where the portal declares a [PortalSearchMode] (MP), the search-mode radio
  /// is selected first, because the number field does not exist until it is. The
  /// radio fires an ASP.NET postback, which reloads the page and re-runs this
  /// method; the `checked` guard means the second pass selects nothing and fills
  /// the number instead, so it converges rather than looping.
  ///
  /// The script reports what it actually did, and only a confirmed fill marks the
  /// page as prefilled. That distinction matters: marking the page prefilled
  /// after merely selecting the search mode raced the postback's own
  /// `onPageStarted`, so the flag could be set back to true *after* the reload
  /// reset it — and the reloaded page, which finally had the input, was then
  /// skipped. That is why the MP eTP box arrived empty. When the field is not
  /// there yet, the attempt is retried a bounded number of times instead of
  /// giving up on the first miss.
  Future<void> _prefillFormFields(WebViewController controller) async {
    if (_prefilled) return;
    if (_prefillAttempts >= _maxPrefillAttempts) return;
    _prefillAttempts++;

    final script = PortalPrefillScript(
      portal: widget.portal,
      challanNumber: widget.challanNumber,
      financialYear: widget.financialYear,
    ).build();

    final PortalPrefillOutcome outcome;
    try {
      outcome = PortalPrefillOutcome.from(
        PortalMarkupReader.decode(
          await controller.runJavaScriptReturningResult(script),
        ),
      );
    } catch (_) {
      // Prefill is a convenience only. If the portal's markup changed, the user
      // simply types the values themselves.
      return;
    }

    if (!mounted) return;

    if (outcome == PortalPrefillOutcome.filled) {
      setState(() => _prefilled = true);
      return;
    }

    // 'mode'   — the portal is posting back to render its number field.
    // anything else — the input is not in the DOM yet, which happens while an
    //                 ASP.NET page is still settling.
    //
    // Either way the postback normally triggers a fresh page load, which resets
    // the attempt counter and runs this again. The delayed retry covers the case
    // where no navigation follows, so a portal that renders its field in place
    // still gets filled instead of silently staying empty.
    await Future<void>.delayed(
      outcome == PortalPrefillOutcome.searchModeSelected
          ? const Duration(milliseconds: 900)
          : const Duration(milliseconds: 450),
    );
    if (!mounted || _prefilled) return;
    await _prefillFormFields(controller);
  }

  // ---------------------------------------------------------------------------
  // Extraction
  // ---------------------------------------------------------------------------

  /// The single extraction capability exposed to the page.
  ///
  /// Returns the rendered markup of the result region so the parser (in Dart,
  /// where it is unit-testable) can read it. Scripts, styles, inputs and any
  /// CAPTCHA image are stripped before the markup leaves the page, so no
  /// credential or challenge data is ever handed back.
  ///
  /// The transport is chosen by platform — one hop everywhere except Windows,
  /// which stages the markup and reads it in slices. See [PortalMarkupReader].
  Future<String?> readResultHtml() async {
    final controller = _controller;
    if (controller == null) return null;
    return PortalMarkupReader(
      evaluate: controller.runJavaScriptReturningResult,
      sliced: _floating,
    ).read();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

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
    // Windows clears cookies through the profile-wide cache wipe below; the
    // cookie manager itself is a no-op there.
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
          // A popup menu opens inside the WebView's rectangle, and Flutter
          // cannot paint above a native floating WebView — so Windows gets
          // plain buttons instead of an overflow menu.
          if (_floating) ...[
            IconButton(
              tooltip: 'Open externally',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openExternally(widget.portal.url),
            ),
            IconButton(
              tooltip: 'Clear portal session',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: controller == null ? null : _clearSession,
            ),
          ] else
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
                PopupMenuItem(
                  value: 'external',
                  child: Text('Open externally'),
                ),
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
          Expanded(child: _portalArea(controller)),
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

  Widget _portalArea(WebViewController? controller) {
    if (_engineError != null) {
      return _CentredNotice(
        icon: Icons.desktop_access_disabled_outlined,
        message: _engineError!,
        action: OutlinedButton.icon(
          onPressed: () => _openExternally(widget.portal.url),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Open portal in browser'),
        ),
      );
    }

    if (!ChallanPortalSupport.supportsInAppWebView()) {
      return const _CentredNotice(
        icon: Icons.devices_other_outlined,
        message: ChallanPortalSupport.unsupportedPlatformNotice,
      );
    }

    if (controller == null) {
      // Only reachable while the Windows controller is being created.
      return const Center(child: CircularProgressIndicator());
    }

    final webView = WebViewWidget(controller: controller);
    if (_floating) {
      // Nothing Flutter draws can appear above a native floating WebView, so
      // the progress bar is stacked beside it rather than over it.
      return Column(
        children: [
          SizedBox(
            height: 3,
            child: _loading ? const LinearProgressIndicator(minHeight: 3) : null,
          ),
          Expanded(child: webView),
        ],
      );
    }
    return Stack(
      children: [
        webView,
        if (_loading) const LinearProgressIndicator(minHeight: 3),
      ],
    );
  }
}

class _CentredNotice extends StatelessWidget {
  const _CentredNotice({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: InfraColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
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
