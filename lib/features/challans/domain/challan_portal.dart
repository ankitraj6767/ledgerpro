/// A state government e-Pass portal that LedgerPro can capture challans from.
///
/// Everything portal-specific — URL, host allow-list, whether a CAPTCHA is
/// shown, whether the portal has its own financial-year selector, which input
/// carries the challan number — is declared here so the flow, the WebView screen
/// and the parser stay portal-agnostic. Adding a state means adding a value here
/// plus its control-id map in the parser; no UI or repository code changes.
///
/// `dbValue` is persisted to `epass_challans.source_portal`, which is part of
/// the duplicate uniqueness key. The same challan number can therefore exist
/// once per portal without colliding.
enum ChallanPortal {
  bihar,
  jharkhand,
  madhyaPradesh;

  /// Default portal for new entries and for records saved before multi-portal
  /// support existed.
  static const fallback = ChallanPortal.bihar;
}

/// A mode selector the portal requires *before* it renders its number field.
///
/// MP's e-Khanij page ships with neither "eTP No" nor "Vehicle No" chosen, and
/// the eTP textbox simply does not exist until one is picked — the choice fires
/// an ASP.NET postback. Selecting a search *mode* is not human verification, so
/// LedgerPro may set it; the CAPTCHA and the Verify button always stay with the
/// user.
class PortalSearchMode {
  const PortalSearchMode({required this.idToken, required this.value});

  /// Substring matched against the radio group's id/name.
  final String idToken;

  /// The radio `value` that means "search by challan / eTP number".
  final String value;
}

extension ChallanPortalMapping on ChallanPortal {
  /// Value stored in `epass_challans.source_portal`.
  ///
  /// Never change an existing value: it is part of the duplicate key and is
  /// already persisted on live rows.
  String get dbValue => switch (this) {
    ChallanPortal.bihar => 'bihar_khanan_soft',
    ChallanPortal.jharkhand => 'jharkhand_minerals_portal',
    ChallanPortal.madhyaPradesh => 'mp_ekhanij_etp',
  };

  /// Unknown values fall back to Bihar, which is what every pre-existing row
  /// holds.
  static ChallanPortal fromDb(String? value) => switch (value) {
    'jharkhand_minerals_portal' => ChallanPortal.jharkhand,
    'mp_ekhanij_etp' => ChallanPortal.madhyaPradesh,
    _ => ChallanPortal.bihar,
  };

  /// Short name for the selector, e.g. "Bihar".
  String get stateName => switch (this) {
    ChallanPortal.bihar => 'Bihar',
    ChallanPortal.jharkhand => 'Jharkhand',
    ChallanPortal.madhyaPradesh => 'Madhya Pradesh',
  };

  /// Full name shown on the saved record.
  String get displayName => switch (this) {
    ChallanPortal.bihar => 'Bihar Khanan Soft (e-Pass)',
    ChallanPortal.jharkhand => 'Jharkhand Minerals Portal (e-Pass)',
    ChallanPortal.madhyaPradesh => 'MP e-Khanij (eTP)',
  };

  /// Wording used for a successful capture. Deliberately says "captured from",
  /// never "verified", because the data comes from a user-driven session.
  String get capturedStatusLabel =>
      'Captured from $stateName Government Portal';

  String get url => switch (this) {
    ChallanPortal.bihar =>
      'https://khanansoft.bihar.gov.in/portal/ePass/ViewPassDetailsNew.aspx',
    ChallanPortal.jharkhand =>
      'https://mineralsportal.jharkhand.gov.in/portal/epass/ViewPassDetailsNew.aspx',
    ChallanPortal.madhyaPradesh =>
      'https://ekhanij.mp.gov.in/appPrevious/Verify_eTP.aspx',
  };

  /// Host the in-app WebView is allowed to navigate to (plus its subdomains).
  String get host => switch (this) {
    ChallanPortal.bihar => 'khanansoft.bihar.gov.in',
    ChallanPortal.jharkhand => 'mineralsportal.jharkhand.gov.in',
    ChallanPortal.madhyaPradesh => 'ekhanij.mp.gov.in',
  };

  /// Whether the portal presents a CAPTCHA the user must solve themselves.
  ///
  /// Jharkhand shows one (`imgCaptcha`/`txtCaptcha`) and MP shows one
  /// (`txtCaptcha` beside `captcha.aspx`); Bihar's page currently does not.
  /// LedgerPro never solves any of them — this only drives the instructions
  /// shown to the user.
  bool get requiresCaptcha => switch (this) {
    ChallanPortal.bihar => false,
    ChallanPortal.jharkhand => true,
    ChallanPortal.madhyaPradesh => true,
  };

  /// Whether the portal itself has a financial-year selector to prefill.
  ///
  /// Only Bihar has one. LedgerPro still records a financial year against every
  /// challan for its own bookkeeping and duplicate key.
  bool get hasFinancialYearSelector => switch (this) {
    ChallanPortal.bihar => true,
    ChallanPortal.jharkhand => false,
    ChallanPortal.madhyaPradesh => false,
  };

  /// What the portal calls the challan identifier, used in field labels and
  /// hints so the wording matches what the user sees on the portal.
  String get challanNumberLabel => switch (this) {
    ChallanPortal.bihar => 'Challan number',
    ChallanPortal.jharkhand => 'Pass number',
    ChallanPortal.madhyaPradesh => 'eTP number',
  };

  /// Example challan number shown as an input hint.
  String get challanNumberHint => switch (this) {
    ChallanPortal.bihar => 'e.g. 2413812606031238531',
    ChallanPortal.jharkhand => 'e.g. JH/2026/001234',
    ChallanPortal.madhyaPradesh => 'e.g. 1234567890',
  };

  /// What the portal's own submit button is labelled, so the instructions match
  /// the button the user actually has to press.
  String get searchButtonLabel => switch (this) {
    ChallanPortal.bihar || ChallanPortal.jharkhand => 'Search',
    ChallanPortal.madhyaPradesh => 'Verify',
  };

  /// Id/name substrings identifying the text input that takes the challan
  /// number, used by the prefill script.
  ///
  /// Declared per portal rather than guessed globally: MP's control is `txtetp`,
  /// which shares no token with Bihar's `txtChallanNo`, and a merged token list
  /// would risk typing a challan number into an unrelated field on another
  /// portal.
  List<String> get challanInputTokens => switch (this) {
    ChallanPortal.bihar || ChallanPortal.jharkhand => const [
      'challan',
      'pass',
    ],
    ChallanPortal.madhyaPradesh => const ['etp'],
  };

  /// Whether the portal pre-renders every detail field as the literal `NA`
  /// before a search returns.
  ///
  /// Bihar and Jharkhand do, which is why users must be told to wait for real
  /// values. MP renders nothing at all until its grid is populated, so the same
  /// warning would be confusing there.
  bool get showsPlaceholdersBeforeSearch => switch (this) {
    ChallanPortal.bihar || ChallanPortal.jharkhand => true,
    ChallanPortal.madhyaPradesh => false,
  };

  /// The search-mode radio that has to be selected before the number field
  /// exists, or null when the portal shows the field straight away.
  PortalSearchMode? get searchMode => switch (this) {
    ChallanPortal.bihar || ChallanPortal.jharkhand => null,
    ChallanPortal.madhyaPradesh => const PortalSearchMode(
      idToken: 'rbsearchtype',
      // value="1" is "eTP No:"; value="2" is "Vehicle No:".
      value: '1',
    ),
  };
}
