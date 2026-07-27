import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/data/epass_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/data/portal_markup_reader.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';

import 'fixtures/portal_result_fixtures.dart';

/// Stands in for a platform WebView.
///
/// [asJsonString] mirrors WKWebView / WebView2, which hand JavaScript strings
/// back JSON-quoted; Android returns them raw. [maxResultLength] reproduces the
/// WebView2 behaviour that broke Windows capture: a result larger than the
/// transport can carry comes back with nothing usable in it.
class _FakeWebView {
  _FakeWebView({
    required this.markup,
    this.asJsonString = false,
    this.maxResultLength,
  });

  final String markup;
  final bool asJsonString;
  final int? maxResultLength;

  String? staged;
  final calls = <String>[];
  int sliceCalls = 0;

  Future<Object?> evaluate(String javaScript) async {
    calls.add(javaScript);

    if (javaScript == PortalMarkupReader.cleanupScript) {
      staged = null;
      return _wrap('');
    }

    if (javaScript.contains('value.substring')) {
      sliceCalls++;
      final value = staged ?? '';
      final start = int.parse(
        RegExp(r'var start = (\d+);').firstMatch(javaScript)!.group(1)!,
      );
      final size = int.parse(
        RegExp(r'start \+ (\d+),').firstMatch(javaScript)!.group(1)!,
      );
      if (start >= value.length) return _wrap('');
      final end = (start + size).clamp(0, value.length);
      return _wrap(value.substring(start, end));
    }

    if (javaScript.contains('${PortalMarkupReader.stagingSlot} = (')) {
      staged = markup;
      return staged!.length;
    }

    // Whole-page read.
    return _wrap(markup);
  }

  Object _wrap(String value) {
    if (maxResultLength != null && value.length > maxResultLength!) {
      // What WebView2 does with an oversized result: nothing usable comes back.
      return asJsonString ? '""' : '';
    }
    return asJsonString ? jsonEncode(value) : value;
  }
}

/// Markup shaped like the portal's result table, sized by [rows].
String buildMarkup(int rows) {
  final buffer = StringBuffer('<table>');
  for (var i = 0; i < rows; i++) {
    buffer.write('<tr><td>Challan No.</td><td>24138126060312385316$i</td></tr>');
  }
  buffer.write('</table>');
  return buffer.toString();
}

void main() {
  group('platform support', () {
    test('Windows now hosts the in-app portal WebView', () {
      expect(
        ChallanPortalSupport.supportsInAppWebView(TargetPlatform.windows),
        isTrue,
      );
      expect(
        ChallanPortalSupport.usesFloatingWebView(TargetPlatform.windows),
        isTrue,
      );
    });

    test('mobile and macOS keep the composited WebView path', () {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ]) {
        expect(ChallanPortalSupport.supportsInAppWebView(platform), isTrue);
        expect(ChallanPortalSupport.usesFloatingWebView(platform), isFalse);
      }
    });

    test('Linux still falls back to the browser plus manual entry', () {
      expect(
        ChallanPortalSupport.supportsInAppWebView(TargetPlatform.linux),
        isFalse,
      );
      expect(
        ChallanPortalSupport.usesFloatingWebView(TargetPlatform.linux),
        isFalse,
      );
    });
  });

  group('whole-page transport (Android, iOS, macOS)', () {
    test('reads raw string results unchanged', () async {
      final markup = buildMarkup(4);
      final webView = _FakeWebView(markup: markup);
      final reader = PortalMarkupReader(
        evaluate: webView.evaluate,
        sliced: false,
      );

      expect(await reader.read(), markup);
      expect(webView.calls, hasLength(1), reason: 'exactly one hop');
      expect(webView.sliceCalls, 0);
    });

    test('unwraps JSON-quoted results', () async {
      final markup = buildMarkup(4);
      final reader = PortalMarkupReader(
        evaluate: _FakeWebView(markup: markup, asJsonString: true).evaluate,
        sliced: false,
      );

      expect(await reader.read(), markup);
    });

    test('a throwing WebView reports unreadable rather than crashing', () async {
      final reader = PortalMarkupReader(
        evaluate: (_) => Future.error(StateError('channel closed')),
        sliced: false,
      );

      expect(await reader.read(), isNull);
    });
  });

  group('sliced transport (Windows / WebView2)', () {
    test('reassembles markup that is too large for one hop', () async {
      final markup = buildMarkup(1200);
      expect(markup.length, greaterThan(60000));

      // Baseline: the single-hop transport loses the page entirely, which is the
      // Windows capture failure being fixed.
      final wholeRead = _FakeWebView(
        markup: markup,
        asJsonString: true,
        maxResultLength: 20000,
      );
      expect(
        await PortalMarkupReader(
          evaluate: wholeRead.evaluate,
          sliced: false,
        ).read(),
        isEmpty,
      );

      final sliced = _FakeWebView(
        markup: markup,
        asJsonString: true,
        maxResultLength: 20000,
      );
      final result = await PortalMarkupReader(
        evaluate: sliced.evaluate,
        sliced: true,
        sliceLength: 15000,
      ).read();

      expect(result, markup);
      expect(sliced.sliceCalls, greaterThan(3));
    });

    test('produces the same markup as the whole-page transport', () async {
      final markup = buildMarkup(300);

      final whole = await PortalMarkupReader(
        evaluate: _FakeWebView(markup: markup).evaluate,
        sliced: false,
      ).read();
      final sliced = await PortalMarkupReader(
        evaluate: _FakeWebView(markup: markup, asJsonString: true).evaluate,
        sliced: true,
        sliceLength: 1000,
      ).read();

      expect(sliced, markup);
      expect(sliced, whole);
    });

    test('clears the staging slot after reading', () async {
      final webView = _FakeWebView(markup: buildMarkup(50), asJsonString: true);
      await PortalMarkupReader(
        evaluate: webView.evaluate,
        sliced: true,
      ).read();

      expect(webView.staged, isNull);
      expect(webView.calls.last, PortalMarkupReader.cleanupScript);
    });

    test('an empty page reads as unreadable', () async {
      final reader = PortalMarkupReader(
        evaluate: _FakeWebView(markup: '', asJsonString: true).evaluate,
        sliced: true,
      );

      expect(await reader.read(), isNull);
    });

    test('never returns partial markup when a slice fails', () async {
      final webView = _FakeWebView(
        markup: buildMarkup(200),
        asJsonString: true,
      );

      final reader = PortalMarkupReader(
        evaluate: (javaScript) async {
          // Drop the third slice mid-read.
          if (javaScript.contains('value.substring') &&
              webView.sliceCalls == 2) {
            webView.sliceCalls++;
            return '""';
          }
          return webView.evaluate(javaScript);
        },
        sliced: true,
        sliceLength: 500,
      );

      expect(await reader.read(), isNull);
    });

    test('a runaway page cannot spin forever', () async {
      final reader = PortalMarkupReader(
        // Always claims a huge length but only ever yields one character.
        evaluate: (javaScript) async {
          if (javaScript.contains('value.substring')) return '"x"';
          if (javaScript.contains('${PortalMarkupReader.stagingSlot} = (')) {
            return 1000000;
          }
          return '""';
        },
        sliced: true,
        maxSlices: 5,
      );

      expect(await reader.read(), isNull);
    });
  });

  group('extraction script', () {
    test('strips everything that could carry credential or CAPTCHA data', () {
      const script = PortalMarkupReader.extractionFunction;
      for (final selector in [
        'script',
        'style',
        'noscript',
        'img',
        'iframe',
        'input[type=password]',
        'input[type=hidden]',
      ]) {
        expect(script, contains(selector));
      }
    });

    test('the staging slot is page-local and namespaced', () {
      expect(PortalMarkupReader.stagingSlot, startsWith('window.__ledgerPro'));
      expect(PortalMarkupReader.cleanupScript, contains('null'));
    });
  });

  _endToEnd();
}

/// End-to-end proof that the Windows transport feeds the capture pipeline with
/// exactly what the mobile transport does, using markup taken off the live
/// Bihar e-Pass page.
void _endToEnd() {
  final adapter = EPassWebViewAdapter(ChallanPortal.bihar);
  const request = ChallanCaptureRequest(
    challanNumber: '2413812606031238531',
    financialYear: '2026-2027',
  );

  group('capture pipeline parity', () {
    test('a sliced Windows read captures the same challan as one hop', () async {
      final mobile = await adapter.capture(
        request: request,
        readHtml: PortalMarkupReader(
          evaluate: _FakeWebView(
            markup: PortalFixtures.realPortalFilled,
          ).evaluate,
          sliced: false,
        ).read,
      );

      final windows = await adapter.capture(
        request: request,
        readHtml: PortalMarkupReader(
          evaluate: _FakeWebView(
            markup: PortalFixtures.realPortalFilled,
            asJsonString: true,
            // Anything bigger than this is lost in a single hop, so this read
            // only succeeds because it is sliced.
            maxResultLength: 900,
          ).evaluate,
          sliced: true,
          sliceLength: 800,
        ).read,
      );

      expect(mobile.success, isTrue);
      expect(windows.success, isTrue);
      expect(windows.payload!.challanNumber, '2413812606031238531');
      expect(windows.payload!.vehicleNumber, 'BR06GA1234');
      expect(windows.payload!.quantityText, '2.000');
      expect(windows.payload!.quantityUnit, 'MT');
      expect(windows.status, ChallanVerificationStatus.portalCaptured);
      // The response hash covers the normalized field set, so equality here
      // means both transports produced identical captured data.
      expect(windows.payload!.responseHash, mobile.payload!.responseHash);
    });

    test('an un-searched page still fails cleanly on the Windows transport', () async {
      final result = await adapter.capture(
        request: request,
        readHtml: PortalMarkupReader(
          evaluate: _FakeWebView(
            markup: PortalFixtures.realPortalUnsearched,
            asJsonString: true,
          ).evaluate,
          sliced: true,
          sliceLength: 800,
        ).read,
      );

      expect(result.success, isFalse);
      expect(result.status, ChallanVerificationStatus.manualUnverified);
    });
  });
}
