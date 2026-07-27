import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/data/portal_prefill.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';

/// The prefill contract.
///
/// Prefill has broken twice — once because MP's input token was not declared,
/// once because an attempt that had only selected the search mode reported
/// itself as done and raced the portal's postback — so the outcome decoding and
/// the generated script are pinned here rather than left inside the widget.
void main() {
  String scriptFor(ChallanPortal portal, {String number = '2610622675'}) {
    return PortalPrefillScript(
      portal: portal,
      challanNumber: number,
      financialYear: '2026-2027',
    ).build();
  }

  group('outcome decoding', () {
    test('only a confirmed fill counts as filled', () {
      expect(PortalPrefillOutcome.from('filled'), PortalPrefillOutcome.filled);
      expect(
        PortalPrefillOutcome.from(' filled '),
        PortalPrefillOutcome.filled,
      );
    });

    test('selecting the search mode is not a fill', () {
      // This is the regression that left MP's eTP box empty: treating "mode" as
      // done meant the reloaded page — the one that finally had the input — was
      // skipped.
      expect(
        PortalPrefillOutcome.from('mode'),
        PortalPrefillOutcome.searchModeSelected,
      );
      expect(
        PortalPrefillOutcome.from('mode'),
        isNot(PortalPrefillOutcome.filled),
      );
    });

    test('anything unproven is retried, never assumed filled', () {
      for (final status in ['nofield', 'skip', 'ok', '', 'undefined', null]) {
        expect(
          PortalPrefillOutcome.from(status),
          PortalPrefillOutcome.notReady,
          reason: 'status: $status',
        );
      }
    });
  });

  group('generated script', () {
    test('targets each portal\'s own number input', () {
      expect(scriptFor(ChallanPortal.madhyaPradesh), contains('"etp"'));
      expect(scriptFor(ChallanPortal.bihar), contains('"challan"'));
      expect(scriptFor(ChallanPortal.bihar), contains('"pass"'));
      // MP's txtetp shares no token with Bihar's txtChallanNo, so the MP script
      // must not carry Bihar's tokens.
      expect(
        scriptFor(ChallanPortal.madhyaPradesh),
        isNot(contains('"challan"')),
      );
    });

    test('only MP selects a search mode, and only the eTP one', () {
      final mp = scriptFor(ChallanPortal.madhyaPradesh);
      expect(mp, contains('rbsearchtype'));
      expect(mp, contains('modeValue = "1"'));
      expect(mp, contains("return 'mode'"));

      for (final portal in [ChallanPortal.bihar, ChallanPortal.jharkhand]) {
        expect(scriptFor(portal), contains('modeToken = null'));
      }
    });

    test('only Bihar fills a financial year', () {
      expect(scriptFor(ChallanPortal.bihar), contains('fillYear = true'));
      expect(
        scriptFor(ChallanPortal.jharkhand),
        contains('fillYear = false'),
      );
      expect(
        scriptFor(ChallanPortal.madhyaPradesh),
        contains('fillYear = false'),
      );
    });

    test('the number is confirmed from the DOM before reporting success', () {
      expect(
        scriptFor(ChallanPortal.madhyaPradesh),
        contains("input.value === challan ? 'filled' : 'nofield'"),
      );
    });

    test('the value is JSON-encoded, so a quote cannot break out', () {
      final script = scriptFor(
        ChallanPortal.bihar,
        number: 'BR"; alert(1); //',
      );

      expect(script, contains(r'"BR\"; alert(1); //"'));
    });

    for (final portal in ChallanPortal.values) {
      test('${portal.stateName}: never touches a CAPTCHA or credential field',
          () {
        final script = scriptFor(portal);

        expect(script, contains('captcha'));
        expect(script, contains('isProtected'));
        expect(script, contains('password'));
        expect(script, contains('otp'));
      });

      test('${portal.stateName}: never submits the portal\'s form', () {
        final script = scriptFor(portal);

        // No form submission and no pressing of Search / Verify: the user always
        // completes human verification and presses the button themselves.
        expect(script, isNot(contains('.submit(')));
        expect(script, isNot(contains('__doPostBack')));
        expect(script, isNot(contains('btnSearch')));
        expect(script, isNot(contains('type=submit')));
        // Exactly one click exists in the script and it is the search-mode
        // radio, which is gated on the portal declaring one — so for Bihar and
        // Jharkhand (modeToken null) it can never run.
        final clicks = RegExp(r'(\w+)\.click\(\)').allMatches(script).toList();
        expect(clicks, hasLength(1));
        expect(clicks.single.group(1), 'radio');
      });
    }
  });

  group('navigation decisions', () {
    const policy = PortalNavigationPolicy(allowedHost: 'ekhanij.mp.gov.in');

    test('the portal itself loads in the app', () {
      expect(
        policy.decide(
          url: ChallanPortal.madhyaPradesh.url,
          isMainFrame: true,
        ),
        PortalNavigationAction.allow,
      );
      // A sub-resource on the same host is fine too.
      expect(
        policy.decide(
          url: 'https://ekhanij.mp.gov.in/AppPrevious/captcha.aspx',
          isMainFrame: false,
        ),
        PortalNavigationAction.allow,
      );
    });

    test('a link the user follows off-host opens in the browser', () {
      expect(
        policy.decide(url: 'https://mp.gov.in/', isMainFrame: true),
        PortalNavigationAction.openExternally,
      );
    });

    test('a sub-frame the portal loads itself is refused quietly', () {
      // The regression: launching the OS browser for the portal's own embedded
      // frames put a "points outside the government portal" banner on every MP
      // page load and threatened to pull the user out mid-task.
      for (final url in [
        'https://www.facebook.com/plugins/page.php',
        'http://ekhanij.mp.gov.in/legacy/widget.aspx',
        'https://ekhanij.mp.gov.in.evil.test/',
      ]) {
        expect(
          policy.decide(url: url, isMainFrame: false),
          PortalNavigationAction.block,
          reason: url,
        );
      }
    });

    test('plain HTTP is never loaded, whoever asked', () {
      const url = 'http://ekhanij.mp.gov.in/appPrevious/Verify_eTP.aspx';

      expect(
        policy.decide(url: url, isMainFrame: true),
        PortalNavigationAction.openExternally,
      );
      expect(
        policy.decide(url: url, isMainFrame: false),
        PortalNavigationAction.block,
      );
    });
  });

  group('desktop rendering', () {
    test('only MP asks to be rendered at desktop width', () {
      expect(ChallanPortal.madhyaPradesh.prefersDesktopViewport, isTrue);
      // Bihar and Jharkhand render the same at any width and are left alone.
      expect(ChallanPortal.bihar.prefersDesktopViewport, isFalse);
      expect(ChallanPortal.jharkhand.prefersDesktopViewport, isFalse);
    });

    test('only phone-sized platforms need the emulation', () {
      expect(
        ChallanPortalSupport.needsDesktopViewportEmulation(
          TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        ChallanPortalSupport.needsDesktopViewportEmulation(TargetPlatform.iOS),
        isTrue,
      );
      // macOS and Windows already host the WebView in a desktop-sized window.
      for (final platform in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ]) {
        expect(
          ChallanPortalSupport.needsDesktopViewportEmulation(platform),
          isFalse,
          reason: '$platform',
        );
      }
    });

    test('the desktop user agent is a plain desktop Chrome string', () {
      const agent = ChallanPortalSupport.desktopUserAgent;

      expect(agent, contains('Windows NT'));
      expect(agent, contains('Chrome/'));
      // Nothing that would make a portal serve its mobile theme.
      expect(agent, isNot(contains('Mobile')));
      expect(agent, isNot(contains('Android')));
      expect(ChallanPortalSupport.desktopViewportWidth, greaterThanOrEqualTo(1024));
    });
  });
}
