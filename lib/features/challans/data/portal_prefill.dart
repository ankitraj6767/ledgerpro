import 'dart:convert';

import '../domain/challan_portal.dart';

/// What one prefill attempt achieved.
enum PortalPrefillOutcome {
  /// The challan / eTP number is confirmed present in the portal's own input.
  filled,

  /// The portal's search-mode radio was selected. Its number field does not
  /// exist until then, and selecting it fires the portal's own postback, so the
  /// fill happens on the next attempt.
  searchModeSelected,

  /// The input is not in the DOM yet — normal while an ASP.NET page settles
  /// after a postback — or the portal's markup no longer matches.
  notReady;

  /// Decodes the status the injected script reports.
  ///
  /// Unknown values are [notReady] rather than [filled]: a prefill that cannot
  /// prove it worked must never be treated as done, because the user would be
  /// left staring at an empty field with no retry coming.
  static PortalPrefillOutcome from(String? status) {
    return switch (status?.trim()) {
      'filled' => PortalPrefillOutcome.filled,
      'mode' => PortalPrefillOutcome.searchModeSelected,
      _ => PortalPrefillOutcome.notReady,
    };
  }
}

/// Builds the JavaScript that fills a government portal's search form.
///
/// What it will do:
///   * select the portal's search-mode radio when it declares one, because the
///     number field is not rendered until a mode is chosen (MP);
///   * pick the financial year, where the portal has such a selector (Bihar);
///   * type the challan / eTP number into the input the portal declares, and
///     confirm from the DOM that the value stuck.
///
/// What it will never do:
///   * touch a CAPTCHA, password or OTP field; or
///   * submit the form. Search / Verify is always pressed by the user, so a
///     human-verification challenge is never bypassed.
class PortalPrefillScript {
  const PortalPrefillScript({
    required this.portal,
    required this.challanNumber,
    required this.financialYear,
  });

  final ChallanPortal portal;
  final String challanNumber;
  final String financialYear;

  /// The script to evaluate. Returns one of `filled`, `mode`, `nofield`, `skip`.
  String build() {
    return '''
(function() {
  try {
    var year = ${jsonEncode(financialYear)};
    var challan = ${jsonEncode(challanNumber)};
    // Only Bihar's page has a financial-year selector.
    var fillYear = ${portal.hasFinancialYearSelector};
    // Id/name tokens for this portal's challan / eTP input.
    var numberTokens = ${jsonEncode(portal.challanInputTokens)};
    // Search-mode radio, or null when the portal needs none.
    var modeToken = ${jsonEncode(portal.searchMode?.idToken)};
    var modeValue = ${jsonEncode(portal.searchMode?.value)};

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

    // Search mode. Selecting it triggers the portal's own postback, after which
    // this script runs again and takes the branch below instead.
    if (modeToken) {
      var radios = document.querySelectorAll('input[type=radio]');
      for (var r = 0; r < radios.length; r++) {
        var radio = radios[r];
        var radioKey = ((radio.id || '') + ' ' + (radio.name || '')).toLowerCase();
        if (radioKey.indexOf(modeToken) < 0) continue;
        if (radio.value !== modeValue) continue;
        if (!radio.checked) {
          radio.click();
          return 'mode';
        }
        break;
      }
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
      var matched = false;
      for (var t = 0; t < numberTokens.length; t++) {
        if (id.indexOf(numberTokens[t]) >= 0) { matched = true; break; }
      }
      if (matched) {
        input.value = challan;
        fire(input);
        // Confirmed from the DOM: a field the page then clears or rejects must
        // not be reported as filled.
        return input.value === challan ? 'filled' : 'nofield';
      }
    }
    return 'nofield';
  } catch (e) {
    return 'skip';
  }
})();
''';
  }
}
