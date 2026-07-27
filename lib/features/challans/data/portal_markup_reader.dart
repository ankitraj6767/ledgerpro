import 'dart:convert';

/// Runs one JavaScript expression in the live portal page and returns its value.
///
/// Implemented by the portal screen on top of the platform WebView. Values come
/// back in whatever shape the platform uses: a raw string (Android), a
/// JSON-quoted string (WKWebView, WebView2) or a number.
typedef PortalScriptEvaluator = Future<Object?> Function(String javaScript);

/// Reads the rendered result markup out of a live government portal page.
///
/// One extraction script serves every platform, so the parser always receives
/// identical markup. Only the *transport* differs:
///
///   * **Whole** (Android, iOS, macOS) — one call returns the markup.
///   * **Sliced** (Windows / WebView2) — `ExecuteScript` marshals its result as
///     a JSON string across a COM boundary, and a full ASP.NET result page,
///     once JSON-escaped, is large enough to come back truncated or as `null`.
///     That is precisely why a Windows capture read nothing while the same
///     challan captured fine on Android. The markup is therefore staged once in
///     a page-local variable and pulled back in bounded slices, which makes the
///     transport independent of page size.
///
/// Nothing but the sanitized markup ever crosses back: scripts, styles, images
/// (including the CAPTCHA image), iframes, password fields and hidden inputs are
/// removed inside the page before the string is produced.
class PortalMarkupReader {
  const PortalMarkupReader({
    required this.evaluate,
    required this.sliced,
    this.sliceLength = 48000,
    this.maxSlices = 400,
  });

  final PortalScriptEvaluator evaluate;

  /// True on platforms whose WebView cannot return a large string in one hop.
  final bool sliced;

  /// UTF-16 code units per slice. Small enough that a JSON-encoded result always
  /// survives the platform hop, large enough to finish a full portal page in a
  /// handful of calls.
  final int sliceLength;

  /// Hard stop on the slice loop so a misbehaving page can never spin forever.
  final int maxSlices;

  /// Page-local staging slot, cleared as soon as the read finishes so the markup
  /// is never left sitting in the portal's JavaScript context.
  static const stagingSlot = 'window.__ledgerProPortalCapture';

  /// The single extraction capability exposed to the page, as a JavaScript
  /// function expression so the same code can be invoked directly or staged.
  static const extractionFunction = '''
function() {
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
}
''';

  /// Returns the sanitized markup, or null when the page could not be read.
  ///
  /// Never throws and never returns partial markup: half a page could parse into
  /// a payload that looks complete but is not what the portal displayed, so a
  /// truncated read is reported as "not readable" instead.
  Future<String?> read() => sliced ? _readSliced() : _readWhole();

  Future<String?> _readWhole() async {
    try {
      return decode(await evaluate('($extractionFunction)();'));
    } catch (_) {
      return null;
    }
  }

  Future<String?> _readSliced() async {
    try {
      final total = int.tryParse(decode(await evaluate(stageScript))?.trim() ?? '');
      if (total == null || total <= 0) return null;

      final buffer = StringBuffer();
      var slices = 0;
      while (buffer.length < total && slices < maxSlices) {
        slices++;
        final slice = decode(await evaluate(sliceScript(buffer.length)));
        if (slice == null || slice.isEmpty) return null;
        buffer.write(slice);
      }

      if (buffer.length < total) return null;
      return buffer.toString();
    } catch (_) {
      return null;
    } finally {
      try {
        await evaluate(cleanupScript);
      } catch (_) {
        // Best effort: the page is discarded when the portal screen closes.
      }
    }
  }

  /// Stages the markup and returns its length in UTF-16 code units.
  static const stageScript =
      '''
(function() {
  try {
    $stagingSlot = ($extractionFunction)() || '';
    return $stagingSlot.length;
  } catch (e) {
    return -1;
  }
})();
''';

  /// Returns the staged markup from [start] up to at most [sliceLength] units.
  String sliceScript(int start) =>
      '''
(function() {
  try {
    var value = $stagingSlot || '';
    var start = $start;
    if (start >= value.length) return '';
    var end = Math.min(start + $sliceLength, value.length);
    // Never split a surrogate pair: a lone half would not survive the JSON hop.
    var last = value.charCodeAt(end - 1);
    if (last >= 0xD800 && last <= 0xDBFF && end < value.length) end++;
    return value.substring(start, end);
  } catch (e) {
    return '';
  }
})();
''';

  static const cleanupScript = 'try { $stagingSlot = null; } catch (e) {}';

  /// Normalizes a platform result value to a Dart string.
  ///
  /// Platform WebViews return JavaScript strings either raw (Android) or
  /// JSON-quoted (WKWebView, WebView2), so both shapes are folded here.
  static String? decode(Object? result) {
    if (result == null) return null;
    final raw = result is String ? result : result.toString();
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
}
