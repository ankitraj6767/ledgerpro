import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../domain/challan_models.dart';

/// Canonical fields the parser knows how to recognize on the Bihar e-Pass
/// "View Pass Details" result page.
enum ChallanField {
  challanNumber,
  uidNumber,
  challanDate,
  validUntil,
  consignorName,
  generatedFrom,
  sourceLocation,
  destination,
  vehicleType,
  vehicleNumber,
  mineralName,
  quantity,
  consigneeName,
  royaltyAmount,
}

/// Resilient extractor for the government e-Pass result page.
///
/// Three independent layers run in order; each only fills fields the previous
/// layers left empty. This is deliberate: a single ASP.NET control id, a CSS
/// position or an nth-child selector is never load-bearing on its own, so a
/// cosmetic portal redesign degrades to a partial capture (surfaced as "portal
/// layout changed") instead of silently saving wrong data.
///
///   * Layer 1 — element ids/names whose suffix matches a known ASP.NET label
///     control. Suffix matching survives master-page prefix churn such as
///     `ctl00_ContentPlaceHolder1_`.
///   * Layer 2 — table rows / definition lists keyed by normalized bilingual
///     labels (English + Hindi).
///   * Layer 3 — `Label : Value` pairs recovered from the page's visible text.
class ChallanDomParser {
  const ChallanDomParser();

  /// Bilingual labels per field. All comparisons run through [_normalizeLabel],
  /// so punctuation, casing, `no.`/`no` and whitespace differences are ignored.
  static const _labels = <ChallanField, List<String>>{
    ChallanField.challanNumber: [
      'challan no',
      'challan number',
      'challan',
      'चालान नंबर',
      'चालान संख्या',
      'चालान क्रमांक',
    ],
    ChallanField.uidNumber: [
      'uid no',
      'uid number',
      'uid',
      'यूआईडी नंबर',
      'यूआईडी संख्या',
    ],
    ChallanField.challanDate: [
      'challan date',
      'date of challan',
      'चालान की तिथि',
      'चालान तिथि',
      'चालान दिनांक',
    ],
    ChallanField.validUntil: [
      'challan validity',
      'validity',
      'valid upto',
      'valid up to',
      'valid till',
      'valid until',
      'चालान की वैधता',
      'वैधता',
    ],
    ChallanField.consignorName: [
      'consignor name',
      'consignor',
      'कंसाइनर का नाम',
      'प्रेषक का नाम',
      'प्रेषक',
    ],
    ChallanField.generatedFrom: [
      'challan generate from',
      'challan generated from',
      'generated from',
      'generate from',
      'चालान जनरेट',
    ],
    ChallanField.sourceLocation: [
      'location',
      'source location',
      'source',
      'from',
      'स्थान',
      'स्रोत',
    ],
    ChallanField.destination: [
      'destination',
      'destination location',
      'to',
      'गंतव्य',
      'गंतव्य स्थान',
    ],
    ChallanField.vehicleType: [
      'vehicle type',
      'type of vehicle',
      'वाहन का प्रकार',
      'वाहन प्रकार',
    ],
    ChallanField.vehicleNumber: [
      'vehicle no',
      'vehicle number',
      'vehicle registration no',
      'truck no',
      'वाहन नंबर',
      'वाहन संख्या',
      'गाड़ी नंबर',
    ],
    ChallanField.mineralName: [
      'mineral name',
      'mineral',
      'material name',
      'खनिज का नाम',
      'खनिज नाम',
      'खनिज',
    ],
    ChallanField.quantity: ['quantity', 'qty', 'मात्रा', 'परिमाण'],
    ChallanField.consigneeName: [
      'consignee name',
      'consignee',
      'प्राप्तकर्ता का नाम',
      'प्राप्तकर्ता',
      'परेषिती का नाम',
    ],
    ChallanField.royaltyAmount: [
      'royalty amount',
      'royalty',
      'रॉयल्टी राशि',
      'स्वामित्व राशि',
    ],
  };

  /// Known ASP.NET label-control id suffixes, checked case-insensitively.
  static const _idSuffixes = <ChallanField, List<String>>{
    ChallanField.challanNumber: [
      'lblchallanno',
      'lblchallannumber',
      'lblchallan',
      'txtchallanno',
    ],
    ChallanField.uidNumber: ['lbluidno', 'lbluid', 'lbluidnumber'],
    ChallanField.challanDate: ['lblchallandate', 'lbldate', 'lblchallandt'],
    ChallanField.validUntil: [
      'lblvalidity',
      'lblchallanvalidity',
      'lblvalidupto',
    ],
    ChallanField.consignorName: ['lblconsignorname', 'lblconsignor'],
    ChallanField.generatedFrom: ['lblgeneratefrom', 'lblgeneratedfrom'],
    ChallanField.sourceLocation: ['lbllocation', 'lblsource', 'lblsourceloc'],
    ChallanField.destination: ['lbldestination', 'lbldestinationloc'],
    ChallanField.vehicleType: ['lblvehicletype'],
    ChallanField.vehicleNumber: ['lblvehicleno', 'lblvehiclenumber'],
    ChallanField.mineralName: ['lblmineralname', 'lblmineral'],
    ChallanField.quantity: ['lblquantity', 'lblqty'],
    ChallanField.consigneeName: ['lblconsigneename', 'lblconsignee'],
    ChallanField.royaltyAmount: ['lblroyaltyamount', 'lblroyalty'],
  };

  /// Markers proving the page is actually showing an e-Pass result section.
  static const _resultMarkers = <String>[
    'e-pass details',
    'epass details',
    'e pass details',
    'pass details',
    'challan details',
    'ई-पास विवरण',
    'चालान विवरण',
  ];

  /// Phrases the portal uses when a challan does not exist.
  static const _noRecordMarkers = <String>[
    'no record found',
    'no records found',
    'record not found',
    'no data found',
    'invalid challan',
    'कोई रिकॉर्ड नहीं',
    'रिकॉर्ड नहीं मिला',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// True when the page explicitly says there is no such challan.
  bool reportsNoRecord(String rawHtml) {
    final text = _normalizeLabel(_visibleText(html_parser.parse(rawHtml)));
    // Only trust a no-record banner when no challan value was rendered.
    if (_noRecordMarkers.any(text.contains)) {
      final probe = parse(rawHtml);
      return probe.challanNumber == null;
    }
    return false;
  }

  /// True when the page is actually showing rendered challan *values*.
  ///
  /// A heading alone is never enough: the portal's own search form is titled
  /// "View Pass Details", so matching that text would make an un-searched page
  /// look like a result. Extracted field evidence is always required.
  bool hasResultSection(String rawHtml) {
    final document = html_parser.parse(rawHtml);
    final found = _collect(document);
    if (found.length < 3) return false;
    if (found.containsKey(ChallanField.challanNumber)) return true;
    final text = _normalizeLabel(_visibleText(document));
    return _resultMarkers.any(text.contains);
  }

  /// Extracts a payload from [rawHtml]. Never throws on malformed input: an
  /// unreadable page yields an empty payload whose `missingMandatoryFields`
  /// drives the error the user sees.
  CapturedPortalPayload parse(String rawHtml, {DateTime? capturedAt}) {
    late final dom.Document document;
    try {
      document = html_parser.parse(rawHtml);
    } catch (_) {
      return const CapturedPortalPayload();
    }

    final found = _collect(document);

    final rawFields = <String, String>{
      for (final entry in found.entries) entry.key.name: entry.value,
    };

    final quantityRaw = found[ChallanField.quantity];
    final quantity = _parseQuantity(quantityRaw);
    final unit = _parseQuantityUnit(quantityRaw);

    final payload = CapturedPortalPayload(
      challanNumber: ChallanText.cleanOrNull(found[ChallanField.challanNumber]),
      uidNumber: ChallanText.cleanOrNull(found[ChallanField.uidNumber]),
      challanDate: parsePortalDate(found[ChallanField.challanDate]),
      validUntil: parsePortalDate(found[ChallanField.validUntil]),
      consignorName: ChallanText.cleanOrNull(found[ChallanField.consignorName]),
      consigneeName: ChallanText.cleanOrNull(found[ChallanField.consigneeName]),
      generatedFrom: ChallanText.cleanOrNull(found[ChallanField.generatedFrom]),
      sourceLocation: ChallanText.cleanOrNull(
        found[ChallanField.sourceLocation],
      ),
      destination: ChallanText.cleanOrNull(found[ChallanField.destination]),
      vehicleType: ChallanText.cleanOrNull(found[ChallanField.vehicleType]),
      vehicleNumber: _normalizeVehicleDisplay(
        found[ChallanField.vehicleNumber],
      ),
      mineralName: ChallanText.cleanOrNull(found[ChallanField.mineralName]),
      quantity: quantity,
      quantityText: _parseQuantityText(quantityRaw),
      quantityUnit: unit,
      royaltyAmountPaise: parseRupeesToPaise(found[ChallanField.royaltyAmount]),
      rawFields: rawFields,
      capturedAt: capturedAt ?? DateTime.now(),
    );

    return payload.copyWith(responseHash: hashPayload(payload));
  }

  /// Stable SHA-256 over the normalized field set. Never covers the page HTML,
  /// so no incidental government content or session data is retained.
  String hashPayload(CapturedPortalPayload payload) {
    final keys = payload.rawFields.keys.toList()..sort();
    final canonical = keys
        .map((k) => '$k=${payload.rawFields[k]}')
        .join('\u001f');
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  // ---------------------------------------------------------------------------
  // Layered collection
  // ---------------------------------------------------------------------------

  Map<ChallanField, String> _collect(dom.Document document) {
    final found = <ChallanField, String>{};
    _layer1ElementIds(document, found);
    _layer2LabelledContainers(document, found);
    _layer3VisibleTextPairs(document, found);
    return found;
  }

  /// Layer 1: ids/names ending with a known ASP.NET label control name.
  void _layer1ElementIds(dom.Document document, Map<ChallanField, String> out) {
    for (final element in document.querySelectorAll('[id],[name]')) {
      final identifier =
          (element.attributes['id'] ?? element.attributes['name'] ?? '')
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (identifier.isEmpty) continue;

      for (final entry in _idSuffixes.entries) {
        if (out.containsKey(entry.key)) continue;
        if (!entry.value.any(identifier.endsWith)) continue;
        final value = _valueOf(element);
        if (value != null) out[entry.key] = value;
      }
    }
  }

  /// Layer 2: table rows, definition lists and label/value element pairs.
  void _layer2LabelledContainers(
    dom.Document document,
    Map<ChallanField, String> out,
  ) {
    // Table rows: pair adjacent cells, tolerating a ":" separator cell and
    // rows that pack several label/value pairs side by side.
    for (final row in document.querySelectorAll('tr')) {
      final cells = row.children
          .where((c) => c.localName == 'td' || c.localName == 'th')
          .toList();
      if (cells.length < 2) continue;

      final texts = cells.map(_cellText).toList();
      for (var i = 0; i < texts.length - 1; i++) {
        final field = _fieldForLabel(texts[i]);
        if (field == null) continue;

        // Skip a lone ":" separator cell.
        var valueIndex = i + 1;
        if (_stripSeparators(texts[valueIndex]).isEmpty &&
            valueIndex + 1 < texts.length) {
          valueIndex++;
        }
        final value = ChallanText.cleanOrNull(texts[valueIndex]);
        if (value == null) continue;
        // A value cell that is *exactly* a known label means the row is a
        // header pair. Fuzzy matching must not be used here: real values like
        // "UID-55010" contain label words and would be discarded.
        if (_isExactLabel(texts[valueIndex])) continue;
        out.putIfAbsent(field, () => value);
      }
    }

    // Definition lists.
    for (final list in document.querySelectorAll('dl')) {
      final items = list.children;
      for (var i = 0; i < items.length - 1; i++) {
        if (items[i].localName != 'dt') continue;
        final field = _fieldForLabel(_cellText(items[i]));
        if (field == null) continue;
        if (items[i + 1].localName != 'dd') continue;
        final value = ChallanText.cleanOrNull(_cellText(items[i + 1]));
        if (value != null) out.putIfAbsent(field, () => value);
      }
    }

    // Generic "label element followed by value element" markup used by the
    // portal's newer Bootstrap layout.
    //
    // Only leaf elements qualify. A container such as `<div class="row">` holds
    // both the label and the value, so treating it as a label would pair it with
    // the *next row* and read a completely wrong value.
    for (final label in document.querySelectorAll('label,strong,b,span')) {
      if (label.children.isNotEmpty) continue;
      final field = _fieldForLabel(_cellText(label));
      if (field == null || out.containsKey(field)) continue;
      final sibling = label.nextElementSibling;
      if (sibling == null) continue;
      final value = ChallanText.cleanOrNull(_cellText(sibling));
      if (value == null || _isExactLabel(value)) continue;
      out[field] = value;
    }
  }

  /// Layer 3: `Label : Value` pairs recovered from visible text.
  void _layer3VisibleTextPairs(
    dom.Document document,
    Map<ChallanField, String> out,
  ) {
    if (out.length == ChallanField.values.length) return;

    final lines = _visibleText(document)
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      // Support several pairs on one line: "Challan No.: X   Vehicle No.: Y".
      final matches = RegExp(
        r'([^:\r\n]{2,60}?)\s*[:：]\s*([^:\r\n]{1,120}?)(?=\s{2,}[^:\r\n]{2,60}\s*[:：]|$)',
      ).allMatches(line);

      for (final match in matches) {
        final field = _fieldForLabel(match.group(1) ?? '');
        if (field == null || out.containsKey(field)) continue;
        final value = ChallanText.cleanOrNull(match.group(2));
        if (value != null) out[field] = value;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Value normalization
  // ---------------------------------------------------------------------------

  /// Parses the portal's date formats as Indian Standard Time and returns UTC.
  ///
  /// The portal renders wall-clock IST with no offset, so interpreting it in the
  /// device's local zone would shift the date for users outside India.
  static DateTime? parsePortalDate(String? raw) {
    final text = ChallanText.cleanOrNull(raw);
    if (text == null) return null;

    final match = RegExp(
      r'(\d{1,4})\s*[/\-.]\s*(\d{1,2})\s*[/\-.]\s*(\d{2,4})'
      r'(?:[\sT]+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])?)?',
    ).firstMatch(text);
    if (match == null) return null;

    var first = int.parse(match.group(1)!);
    final second = int.parse(match.group(2)!);
    var third = int.parse(match.group(3)!);

    int day;
    int month;
    int year;
    if (match.group(1)!.length == 4) {
      // ISO-ish yyyy-MM-dd.
      year = first;
      month = second;
      day = third;
    } else {
      day = first;
      month = second;
      year = third;
    }
    if (year < 100) year += 2000;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    var hour = int.tryParse(match.group(4) ?? '') ?? 0;
    final minute = int.tryParse(match.group(5) ?? '') ?? 0;
    final second2 = int.tryParse(match.group(6) ?? '') ?? 0;
    final meridiem = match.group(7)?.toLowerCase();
    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    if (hour > 23 || minute > 59 || second2 > 59) return null;

    // Build the instant as IST (UTC+05:30) and hand back UTC.
    const istOffset = Duration(hours: 5, minutes: 30);
    final asUtcWallClock = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second2,
    );
    return asUtcWallClock.subtract(istOffset);
  }

  /// Exact decimal text for the quantity, e.g. `"12.500"`. Kept as a string so
  /// the value reaches Postgres `numeric` without a binary-float round trip.
  static String? _parseQuantityText(String? raw) {
    final text = ChallanText.cleanOrNull(raw);
    if (text == null) return null;
    final match = RegExp(r'(\d+(?:,\d{2,3})*(?:\.\d+)?)').firstMatch(text);
    if (match == null) return null;
    final digits = match.group(1)!.replaceAll(',', '');
    if (digits.isEmpty) return null;
    return digits;
  }

  static double? _parseQuantity(String? raw) {
    final text = _parseQuantityText(raw);
    if (text == null) return null;
    final value = double.tryParse(text);
    if (value == null || value <= 0) return null;
    return value;
  }

  /// Returns the unit only when the portal actually printed one.
  static String? _parseQuantityUnit(String? raw) {
    final text = ChallanText.cleanOrNull(raw);
    if (text == null) return null;
    final match = RegExp(
      r'\b(MT|M\.T\.?|METRIC\s*TON(?:NE)?S?|TONNES?|TONS?|CUM|CBM|M3|M\^3|CFT|KG|QUINTAL)\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final unit = match.group(1)!.toUpperCase().replaceAll(RegExp(r'[\s.]'), '');
    return switch (unit) {
      'MT' || 'MT.' || 'METRICTON' || 'METRICTONS' => 'MT',
      'METRICTONNE' || 'METRICTONNES' || 'TONNE' || 'TONNES' => 'MT',
      'TON' || 'TONS' => 'MT',
      'CUM' || 'CBM' || 'M3' || 'M^3' => 'CUM',
      _ => unit,
    };
  }

  /// Rupee text → integer paise using string math, so no float rounding.
  static int? parseRupeesToPaise(String? raw) {
    final text = ChallanText.cleanOrNull(raw);
    if (text == null) return null;
    final match = RegExp(r'(\d+(?:,\d{2,3})*(?:\.\d{1,2})?)').firstMatch(text);
    if (match == null) return null;
    final digits = match.group(1)!.replaceAll(',', '');
    final parts = digits.split('.');
    final rupees = int.tryParse(parts.first);
    if (rupees == null) return null;
    var paise = 0;
    if (parts.length > 1) {
      paise = int.tryParse(parts[1].padRight(2, '0').substring(0, 2)) ?? 0;
    }
    return rupees * 100 + paise;
  }

  /// Display form of a vehicle number: uppercase, internal spacing collapsed.
  /// The strict comparison key is produced by [ChallanText.normalizeToken].
  static String? _normalizeVehicleDisplay(String? raw) {
    final text = ChallanText.cleanOrNull(raw);
    if (text == null) return null;
    return text.toUpperCase();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// True only when the text *is* a known label, not merely contains one.
  bool _isExactLabel(String rawText) {
    final normalized = _normalizeLabel(_stripSeparators(rawText));
    if (normalized.isEmpty) return false;
    for (final candidates in _labels.values) {
      for (final candidate in candidates) {
        if (normalized == _normalizeLabel(candidate)) return true;
      }
    }
    return false;
  }

  ChallanField? _fieldForLabel(String rawLabel) {
    final normalized = _normalizeLabel(_stripSeparators(rawLabel));
    if (normalized.isEmpty || normalized.length > 60) return null;

    // Exact match wins.
    for (final entry in _labels.entries) {
      for (final candidate in entry.value) {
        if (normalized == _normalizeLabel(candidate)) return entry.key;
      }
    }
    // Then longest containing match, so "vehicle number" beats "vehicle".
    ChallanField? best;
    var bestLength = 0;
    for (final entry in _labels.entries) {
      for (final candidate in entry.value) {
        final needle = _normalizeLabel(candidate);
        if (needle.length > bestLength && normalized.contains(needle)) {
          best = entry.key;
          bestLength = needle.length;
        }
      }
    }
    return best;
  }

  /// Lowercase, HTML-entity-decoded, punctuation-folded label key.
  static String _normalizeLabel(String raw) {
    var text = _decodeEntities(raw).toLowerCase();
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Fold "no." / "no" / "number" and drop trailing punctuation.
    text = text.replaceAll(RegExp(r'[.:*()\[\]]'), ' ');
    text = text.replaceAll(RegExp(r'\bnumber\b'), 'no');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  static String _stripSeparators(String raw) =>
      raw.replaceAll(RegExp(r'^[\s:：*-]+|[\s:：*-]+$'), '');

  /// Text of an element with entities decoded and whitespace collapsed.
  static String _cellText(dom.Element element) =>
      _decodeEntities(element.text).replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Reads a displayed value from a label span, input or select.
  static String? _valueOf(dom.Element element) {
    if (element.localName == 'input') {
      final type = (element.attributes['type'] ?? 'text').toLowerCase();
      if (type == 'hidden') return null;
      return ChallanText.cleanOrNull(element.attributes['value']);
    }
    if (element.localName == 'select') {
      for (final option in element.querySelectorAll('option')) {
        if (option.attributes.containsKey('selected')) {
          return ChallanText.cleanOrNull(_cellText(option));
        }
      }
      return null;
    }
    return ChallanText.cleanOrNull(_cellText(element));
  }

  /// Visible text of the document with script/style content removed.
  static String _visibleText(dom.Document document) {
    final body = document.body ?? document.documentElement;
    if (body == null) return '';
    final clone = body.clone(true);
    for (final node in clone.querySelectorAll('script,style,noscript')) {
      node.remove();
    }
    // Force line breaks at block boundaries so layer 3 sees one pair per line.
    for (final node in clone.querySelectorAll('br,tr,div,p,li,td,th')) {
      node.append(dom.Text('\n'));
    }
    return _decodeEntities(clone.text)
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t\u00a0]+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  /// Decodes the entity forms the portal emits. The `html` package already
  /// decodes entities while parsing; this also covers values that arrive
  /// double-encoded from `innerHTML` round-trips.
  static String _decodeEntities(String raw) {
    if (!raw.contains('&')) return raw.replaceAll('\u00a0', ' ');
    return raw
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAllMapped(
          RegExp(r'&#(\d{1,6});'),
          (m) => String.fromCharCode(int.parse(m.group(1)!)),
        )
        .replaceAll('\u00a0', ' ');
  }
}
