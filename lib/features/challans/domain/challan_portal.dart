/// A state government e-Pass portal that LedgerPro can capture challans from.
///
/// Everything portal-specific — URL, host allow-list, whether a CAPTCHA is
/// shown, whether the portal has its own financial-year selector — is declared
/// here so the flow, the WebView screen and the parser stay portal-agnostic.
///
/// `dbValue` is persisted to `epass_challans.source_portal`, which is part of
/// the duplicate uniqueness key. The same challan number can therefore exist
/// once per portal without colliding.
enum ChallanPortal {
  bihar,
  jharkhand;

  /// Default portal for new entries and for records saved before multi-portal
  /// support existed.
  static const fallback = ChallanPortal.bihar;
}

extension ChallanPortalMapping on ChallanPortal {
  /// Value stored in `epass_challans.source_portal`.
  String get dbValue => switch (this) {
    ChallanPortal.bihar => 'bihar_khanan_soft',
    ChallanPortal.jharkhand => 'jharkhand_minerals_portal',
  };

  /// Unknown values fall back to Bihar, which is what every pre-existing row
  /// holds.
  static ChallanPortal fromDb(String? value) => switch (value) {
    'jharkhand_minerals_portal' => ChallanPortal.jharkhand,
    _ => ChallanPortal.bihar,
  };

  /// Short name for the selector, e.g. "Bihar".
  String get stateName => switch (this) {
    ChallanPortal.bihar => 'Bihar',
    ChallanPortal.jharkhand => 'Jharkhand',
  };

  /// Full name shown on the saved record.
  String get displayName => switch (this) {
    ChallanPortal.bihar => 'Bihar Khanan Soft (e-Pass)',
    ChallanPortal.jharkhand => 'Jharkhand Minerals Portal (e-Pass)',
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
  };

  /// Host the in-app WebView is allowed to navigate to (plus its subdomains).
  String get host => switch (this) {
    ChallanPortal.bihar => 'khanansoft.bihar.gov.in',
    ChallanPortal.jharkhand => 'mineralsportal.jharkhand.gov.in',
  };

  /// Whether the portal presents a CAPTCHA the user must solve themselves.
  ///
  /// Jharkhand shows one (`imgCaptcha`/`txtCaptcha`); Bihar's page currently
  /// does not. LedgerPro never solves either way — this only drives the
  /// instructions shown to the user.
  bool get requiresCaptcha => switch (this) {
    ChallanPortal.bihar => false,
    ChallanPortal.jharkhand => true,
  };

  /// Whether the portal itself has a financial-year selector to prefill.
  ///
  /// Jharkhand has none. LedgerPro still records a financial year against the
  /// challan for its own bookkeeping and duplicate key.
  bool get hasFinancialYearSelector => switch (this) {
    ChallanPortal.bihar => true,
    ChallanPortal.jharkhand => false,
  };

  /// What the portal calls the challan identifier, used in field labels and
  /// hints so the wording matches what the user sees on the portal.
  String get challanNumberLabel => switch (this) {
    ChallanPortal.bihar => 'Challan number',
    ChallanPortal.jharkhand => 'Pass number',
  };

  /// Example challan number shown as an input hint.
  String get challanNumberHint => switch (this) {
    ChallanPortal.bihar => 'e.g. 2413812606031238531',
    ChallanPortal.jharkhand => 'e.g. JH/2026/001234',
  };
}
